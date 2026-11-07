// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';

/// Simulasi database Supabase in-memory yang menerapkan kebijakan Row Level Security (RLS)
/// sesuai dengan aturan:
/// - courses_select_authenticated
/// - courses_insert_instructor_admin
/// - courses_update_instructor_admin
/// - courses_delete_instructor_admin
class SimulatedRlsCourseSupabaseService extends CourseSupabaseService {
  final List<Course> _database;
  String? simulatedUserId;
  String? simulatedUserRole;

  SimulatedRlsCourseSupabaseService({
    required List<Course> initialData,
    this.simulatedUserId,
    this.simulatedUserRole,
  })  : _database = List<Course>.from(initialData);

  void setSession({String? userId, String? role}) {
    simulatedUserId = userId;
    simulatedUserRole = role?.toLowerCase().trim();
  }

  void clearSession() {
    simulatedUserId = null;
    simulatedUserRole = null;
  }

  bool get isAuthenticated => simulatedUserId != null && simulatedUserId!.isNotEmpty;

  @override
  Future<List<Course>> getCourses() async {
    // Policy: courses_select_authenticated (TO authenticated USING (true))
    if (!isAuthenticated) {
      throw const PostgrestException(
        message: 'Akses ditolak: Membaca daftar course memerlukan autentikasi aktif.',
        code: '42501',
      );
    }
    return List<Course>.from(_database);
  }

  @override
  Future<void> createCourse(Course course) async {
    validateCourse(course);

    // 1. Cek autentikasi (TO authenticated)
    if (!isAuthenticated) {
      throw const PostgrestException(
        message: 'Pengguna belum terautentikasi. Penambahan course memerlukan autentikasi aktif sesuai kebijakan RLS.',
        code: '42501',
      );
    }

    // 2. Policy: courses_insert_instructor_admin
    // Student dilarang membuat course
    if (simulatedUserRole != 'instructor' && simulatedUserRole != 'admin') {
      throw const PostgrestException(
        message: 'new row violates row-level security policy for table "courses" (Role student dilarang INSERT)',
        code: '42501',
      );
    }

    // 3. Stamping user_id milik pengguna yang sedang login
    final newId = (_database.isEmpty
            ? 0
            : _database.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b)) +
        1;

    final stampedCourse = course.copyWith(
      id: newId,
      supabaseUserId: simulatedUserId,
    );

    _database.insert(0, stampedCourse);
  }

  @override
  Future<void> updateCourse(Course course, {int? id}) async {
    final targetId = id ?? course.id;
    final courseToValidate = course.copyWith(id: targetId);
    validateCourse(courseToValidate, isUpdate: true);

    // 1. Cek autentikasi
    if (!isAuthenticated) {
      throw const PostgrestException(
        message: 'Pengguna belum terautentikasi. Pembaruan course memerlukan autentikasi aktif sesuai kebijakan RLS.',
        code: '42501',
      );
    }

    // 2. Cari data course yang ingin di-update
    final index = _database.indexWhere((c) => c.id == targetId);
    if (index == -1) {
      throw const PostgrestException(
        message: 'Operasi UPDATE ditolak: data course tidak ditemukan.',
        code: '42501',
      );
    }

    final existingCourse = _database[index];

    // 3. Policy: courses_update_instructor_admin
    // Student: ditolak
    if (simulatedUserRole != 'instructor' && simulatedUserRole != 'admin') {
      throw const PostgrestException(
        message: 'Akses ditolak oleh kebijakan keamanan RLS: Role student tidak memiliki izin UPDATE.',
        code: '42501',
      );
    }

    // Instructor: HANYA diizinkan jika course miliknya sendiri (user_id = auth.uid())
    if (simulatedUserRole == 'instructor') {
      if (existingCourse.supabaseUserId != simulatedUserId) {
        // PostgREST mengembalikan 0 baris terpengaruh jika filter USING tidak cocok
        throw const PostgrestException(
          message: 'Operasi UPDATE ditolak oleh kebijakan keamanan RLS: Instructor tidak dapat mengubah course milik pengguna lain.',
          code: '42501',
        );
      }
    }

    // Admin atau Instructor pemilik sah: berhasil memperbarui data
    _database[index] = existingCourse.copyWith(
      title: course.title,
      credits: course.credits,
      status: course.status,
    );
  }

  @override
  Future<void> deleteCourse(int id) async {
    if (id <= 0) {
      throw ArgumentError('ID course tidak valid untuk penghapusan: $id');
    }

    // 1. Cek autentikasi
    if (!isAuthenticated) {
      throw const PostgrestException(
        message: 'Pengguna belum terautentikasi. Penghapusan course memerlukan autentikasi aktif sesuai kebijakan RLS.',
        code: '42501',
      );
    }

    final index = _database.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw const PostgrestException(
        message: 'Operasi DELETE ditolak: data course tidak ditemukan.',
        code: '42501',
      );
    }

    final existingCourse = _database[index];

    // 2. Policy: courses_delete_instructor_admin
    // Student: ditolak
    if (simulatedUserRole != 'instructor' && simulatedUserRole != 'admin') {
      throw const PostgrestException(
        message: 'Akses ditolak oleh kebijakan keamanan RLS: Role student tidak memiliki izin DELETE.',
        code: '42501',
      );
    }

    // Instructor: HANYA diizinkan jika course miliknya sendiri
    if (simulatedUserRole == 'instructor') {
      if (existingCourse.supabaseUserId != simulatedUserId) {
        throw const PostgrestException(
          message: 'Operasi DELETE ditolak oleh kebijakan keamanan RLS: Instructor tidak dapat menghapus course milik pengguna lain.',
          code: '42501',
        );
      }
    }

    _database.removeAt(index);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SimulatedRlsCourseSupabaseService rlsService;
  late CourseRepository repository;
  late CourseProvider provider;

  const String instructorAId = 'uuid-instructor-aaa-111';
  const String instructorBId = 'uuid-instructor-bbb-222';
  const String studentId = 'uuid-student-sss-333';
  const String adminId = 'uuid-admin-zzz-999';

  setUp(() {
    final initialCourses = [
      const Course(
        id: 10,
        code: 'MOB10',
        title: 'Flutter UI Fundamentals',
        credits: 3,
        status: 'active',
        supabaseUserId: instructorAId, // Milik Instructor A
      ),
      const Course(
        id: 20,
        code: 'MOB20',
        title: 'Advanced State Management',
        credits: 4,
        status: 'planned',
        supabaseUserId: instructorBId, // Milik Instructor B
      ),
      const Course(
        id: 30,
        code: 'MOB30',
        title: 'Legacy Public Course',
        credits: 2,
        status: 'done',
        supabaseUserId: null, // Course lama tanpa kepemilikan
      ),
    ];

    rlsService = SimulatedRlsCourseSupabaseService(initialData: initialCourses);
    repository = CourseRepository(
      CourseService(),
      CourseApiService(),
      rlsService,
    );
    provider = CourseProvider(repository);
  });

  group('Worksheet 9 Praktik 5 — Row Level Security (RLS) Authorization Rules', () {
    test('1. Student BERHASIL membaca daftar course dari Supabase (Policy courses_select_authenticated)', () async {
      rlsService.setSession(userId: studentId, role: 'student');

      final courses = await rlsService.getCourses();

      expect(courses, isNotEmpty);
      expect(courses.length, 3);
      expect(courses.any((c) => c.code == 'MOB10'), isTrue);
    });

    test('2. Student DITOLAK ketika mencoba membuat course baru (INSERT)', () async {
      rlsService.setSession(userId: studentId, role: 'student');

      const newCourse = Course(
        code: 'MOB99',
        title: 'Illegal Student Course',
        credits: 3,
        status: 'active',
      );

      // Verifikasi langsung pada service layer
      expect(
        () => rlsService.createCourse(newCourse),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString().toLowerCase(),
            'message',
            anyOf([
              contains('rls'),
              contains('dilarang insert'),
              contains('ditolak'),
            ]),
          ),
        ),
      );

      // Verifikasi penanganan state pada Provider
      final success = await provider.createSupabaseCourse(newCourse);
      expect(success, isFalse);
      expect(provider.createSupabaseCourseError, isNotNull);
      expect(
        provider.createSupabaseCourseError!.toLowerCase(),
        anyOf([
          contains('row-level security'),
          contains('rls'),
          contains('ditolak'),
          contains('tidak diizinkan'),
          contains('dilarang insert'),
        ]),
      );
    });

    test('3. Instructor BERHASIL membuat course baru dan user_id otomatis terisi UUID miliknya', () async {
      rlsService.setSession(userId: instructorAId, role: 'instructor');

      const newCourse = Course(
        code: 'MOB11',
        title: 'Networking & Supabase',
        credits: 3,
        status: 'active',
      );

      final success = await provider.createSupabaseCourse(newCourse);
      expect(success, isTrue);

      final created = provider.supabaseCourses.firstWhere((c) => c.code == 'MOB11');
      expect(created.supabaseUserId, instructorAId);
      expect(created.id, isNotNull);
    });

    test('4. Instructor BERHASIL mengubah course miliknya sendiri (UPDATE)', () async {
      rlsService.setSession(userId: instructorAId, role: 'instructor');

      // Course ID 10 adalah milik Instructor A
      const updatedCourse = Course(
        id: 10,
        code: 'MOB10',
        title: 'Flutter UI Fundamentals (Updated by Owner)',
        credits: 4,
        status: 'done',
        supabaseUserId: instructorAId,
      );

      final success = await provider.updateSupabaseCourse(updatedCourse, id: 10);
      expect(success, isTrue);

      final found = provider.supabaseCourses.firstWhere((c) => c.id == 10);
      expect(found.title, 'Flutter UI Fundamentals (Updated by Owner)');
      expect(found.credits, 4);
    });

    test('5. Instructor DITOLAK ketika mencoba mengubah course milik instructor lain', () async {
      // Login sebagai Instructor A
      rlsService.setSession(userId: instructorAId, role: 'instructor');

      // Course ID 20 adalah milik Instructor B
      const unauthorizedUpdate = Course(
        id: 20,
        code: 'MOB20',
        title: 'Hacked by Instructor A',
        credits: 2,
        status: 'done',
      );

      final success = await provider.updateSupabaseCourse(unauthorizedUpdate, id: 20);
      expect(success, isFalse);
      expect(provider.updateSupabaseCourseError, isNotNull);
      expect(
        provider.updateSupabaseCourseError!.toLowerCase(),
        anyOf([
          contains('rls'),
          contains('ditolak'),
          contains('tidak diizinkan'),
        ]),
      );
    });

    test('6. Instructor DITOLAK ketika mencoba menghapus course milik instructor lain', () async {
      // Login sebagai Instructor A
      rlsService.setSession(userId: instructorAId, role: 'instructor');

      // Course ID 20 adalah milik Instructor B
      final success = await provider.deleteSupabaseCourse(20);
      expect(success, isFalse);
      expect(provider.deleteSupabaseCourseError, isNotNull);
      expect(
        provider.deleteSupabaseCourseError!.toLowerCase(),
        anyOf([
          contains('rls'),
          contains('ditolak'),
          contains('tidak diizinkan'),
        ]),
      );
    });

    test('7. Admin DAPAT mengubah dan menghapus course milik pengguna lain', () async {
      rlsService.setSession(userId: adminId, role: 'admin');

      // Admin meng-update course ID 20 (milik Instructor B)
      const adminUpdate = Course(
        id: 20,
        code: 'MOB20',
        title: 'Admin Verified Course',
        credits: 4,
        status: 'active',
      );

      final updateSuccess = await provider.updateSupabaseCourse(adminUpdate, id: 20);
      expect(updateSuccess, isTrue);

      final updated = provider.supabaseCourses.firstWhere((c) => c.id == 20);
      expect(updated.title, 'Admin Verified Course');

      // Admin menghapus course ID 10 (milik Instructor A)
      final deleteSuccess = await provider.deleteSupabaseCourse(10);
      expect(deleteSuccess, isTrue);

      final remaining = provider.supabaseCourses.where((c) => c.id == 10).toList();
      expect(remaining, isEmpty);
    });

    test('8. Pengguna yang tidak terautentikasi DITOLAK saat mengakses operasi yang memerlukan autentikasi', () async {
      rlsService.clearSession(); // Tidak ada sesi (unauthenticated)

      // A. SELECT
      expect(
        () => rlsService.getCourses(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString().toLowerCase(),
            'message',
            anyOf([
              contains('autentikasi'),
              contains('rls'),
              contains('ditolak'),
            ]),
          ),
        ),
      );

      // B. INSERT
      const testCourse = Course(
        code: 'MOB00',
        title: 'Anon Course',
        credits: 2,
        status: 'planned',
      );
      expect(
        () => rlsService.createCourse(testCourse),
        throwsA(isA<Exception>()),
      );

      // C. UPDATE
      expect(
        () => rlsService.updateCourse(testCourse, id: 30),
        throwsA(isA<Exception>()),
      );

      // D. DELETE
      expect(
        () => rlsService.deleteCourse(30),
        throwsA(isA<Exception>()),
      );
    });
  });
}

