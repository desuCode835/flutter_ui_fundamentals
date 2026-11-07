// =============================================================================
// Nama : Gede Supadma
// NIM  : 2415051014
// WORKSHEET 9 - PRAKTIK 6: SECURITY TESTING (CROSS-INSTRUCTOR RLS ENFORCEMENT)
// =============================================================================
// Menguji implementasi keamanan dan Row Level Security (RLS) pada tabel courses
// menggunakan dua sesi akun Instructor yang berbeda (Instructor A dan Instructor B):
//
// Kasus A (Instructor A):
// 1. Instructor A membuat course pengujian (CREATE/INSERT).
// 2. Pastikan course memiliki user_id yang cocok dengan UUID Instructor A.
// 3. Instructor A dapat melihat course miliknya (READ/SELECT).
// 4. Instructor A dapat mengedit course miliknya (UPDATE).
//
// Kasus B (Instructor B):
// 5. Instructor B login menggunakan akun yang berbeda dari Instructor A.
// 6. Instructor B dapat melihat course milik Instructor A (policy SELECT diizinkan).
// 7. Instructor B mencoba mengedit course milik Instructor A -> DITOLAK oleh RLS.
// 8. Instructor B mencoba menghapus course milik Instructor A -> DITOLAK oleh RLS.
// 9. Instructor B mencoba membuat course dengan user_id milik Instructor A -> DITOLAK oleh RLS.
//
// Cleanup:
// 10. Course pengujian dibersihkan oleh Instructor A (pemilik sah).
//
// Arsitektur: Test -> Provider -> Repository -> Service -> Supabase.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_ui_fundamentals/config/supabase_config.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';

// =============================================================================
// SIMULATED DATABASE SERVICE DENGAN PENERAPAN KEBIJAKAN RLS PRAKTIK 5 & 6
// =============================================================================
class MockMultiUserRlsDatabaseService extends CourseSupabaseService {
  final List<Course> _database;
  String? _activeUserId;
  String? _activeUserRole;

  MockMultiUserRlsDatabaseService({
    required List<Course> initialData,
  })  : _database = List<Course>.from(initialData),
        super();

  void switchSession({required String userId, required String role}) {
    _activeUserId = userId;
    _activeUserRole = role.toLowerCase().trim();
  }

  void clearSession() {
    _activeUserId = null;
    _activeUserRole = null;
  }

  bool get isAuthenticated => _activeUserId != null && _activeUserId!.isNotEmpty;

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
        message: 'Pengguna belum terautentikasi.',
        code: '42501',
      );
    }

    // 2. Policy: courses_insert_instructor_admin
    if (_activeUserRole != 'instructor' && _activeUserRole != 'admin') {
      throw const PostgrestException(
        message: 'new row violates row-level security policy for table "courses" (Role student dilarang INSERT)',
        code: '42501',
      );
    }

    // 3. Stamping user_id & verifikasi spoofing user_id
    final targetUserId = (course.supabaseUserId != null && course.supabaseUserId!.isNotEmpty)
        ? course.supabaseUserId!
        : _activeUserId!;

    // Policy courses_insert_instructor_admin:
    // Instructor hanya boleh insert jika user_id = auth.uid()
    if (_activeUserRole == 'instructor' && targetUserId != _activeUserId) {
      throw const PostgrestException(
        message: 'new row violates row-level security policy for table "courses" (Instructor dilarang INSERT dengan user_id milik pengguna lain)',
        code: '42501',
      );
    }

    final newId = (_database.isEmpty
            ? 0
            : _database.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b)) +
        1;

    final createdCourse = course.copyWith(
      id: newId,
      supabaseUserId: targetUserId,
    );

    _database.insert(0, createdCourse);
  }

  @override
  Future<void> updateCourse(Course course, {int? id}) async {
    final targetId = id ?? course.id;
    final courseToValidate = course.copyWith(id: targetId);
    validateCourse(courseToValidate, isUpdate: true);

    if (!isAuthenticated) {
      throw const PostgrestException(
        message: 'Pengguna belum terautentikasi.',
        code: '42501',
      );
    }

    final index = _database.indexWhere((c) => c.id == targetId);
    if (index == -1) {
      throw const PostgrestException(
        message: 'Operasi UPDATE ditolak: data course tidak ditemukan.',
        code: '42501',
      );
    }

    final existingCourse = _database[index];

    // Policy: courses_update_instructor_admin
    // Instructor hanya boleh update course miliknya sendiri (user_id = auth.uid())
    if (_activeUserRole == 'instructor') {
      if (existingCourse.supabaseUserId != _activeUserId) {
        throw const PostgrestException(
          message: 'Operasi UPDATE ditolak oleh kebijakan keamanan RLS: Instructor tidak dapat mengubah course milik pengguna lain.',
          code: '42501',
        );
      }
    } else if (_activeUserRole != 'admin') {
      throw const PostgrestException(
        message: 'Operasi UPDATE ditolak oleh kebijakan keamanan RLS.',
        code: '42501',
      );
    }

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

    if (!isAuthenticated) {
      throw const PostgrestException(
        message: 'Pengguna belum terautentikasi.',
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

    // Policy: courses_delete_instructor_admin
    // Instructor hanya boleh delete course miliknya sendiri (user_id = auth.uid())
    if (_activeUserRole == 'instructor') {
      if (existingCourse.supabaseUserId != _activeUserId) {
        throw const PostgrestException(
          message: 'Operasi DELETE ditolak oleh kebijakan keamanan RLS: Instructor tidak dapat menghapus course milik pengguna lain.',
          code: '42501',
        );
      }
    } else if (_activeUserRole != 'admin') {
      throw const PostgrestException(
        message: 'Operasi DELETE ditolak oleh kebijakan keamanan RLS.',
        code: '42501',
      );
    }

    _database.removeAt(index);
  }
}

void main() {
  // UUID pengujian yang membedakan dua akun Instructor
  const instructorAUuid = 'aaaa1111-0000-0000-0000-aaaaaaaaaaaa';
  const instructorBUuid = 'bbbb2222-0000-0000-0000-bbbbbbbbbbbb';

  // ===========================================================================
  // BAGIAN 1: SIMULATED MULTI-INSTRUCTOR SECURITY TESTING
  // ===========================================================================
  // Memverifikasi seluruh 9 skenario keamanan secara deterministik melalui layer
  // arsitektur Provider -> Repository -> Service -> Database Simulation.
  // ===========================================================================
  group('Worksheet 9 Praktik 6 — Security Testing (Simulated Multi-Instructor RLS)', () {
    late MockMultiUserRlsDatabaseService dbService;
    late CourseRepository repository;
    late CourseProvider provider;

    setUp(() {
      dbService = MockMultiUserRlsDatabaseService(
        initialData: [
          const Course(
            id: 1,
            code: 'PRE-01',
            title: 'Sistem Basis Data Terdistribusi',
            credits: 3,
            status: 'active',
            supabaseUserId: 'cccc3333-0000-0000-0000-cccccccccccc',
          ),
        ],
      );

      repository = CourseRepository(
        CourseService(),
        CourseApiService(),
        dbService,
      );

      provider = CourseProvider(repository);
    });

    test('Kasus A — Instructor A: Membuat, memverifikasi user_id, membaca, dan mengedit course miliknya', () async {
      // 1. Sesi aktif sebagai Instructor A
      dbService.switchSession(userId: instructorAUuid, role: 'instructor');

      const testCourse = Course(
        code: 'SEC-A-01',
        title: 'Pengembangan Aplikasi Flutter Lanjut',
        credits: 3,
        status: 'active',
      );

      // A. Instructor A membuat course
      final createSuccess = await provider.createSupabaseCourse(testCourse);
      expect(createSuccess, isTrue);
      expect(provider.createSupabaseCourseError, isNull);

      // B. Pastikan course memiliki user_id yang sama dengan UUID Instructor A
      final created = provider.supabaseCourses.firstWhere((c) => c.code == 'SEC-A-01');
      expect(created.id, isNotNull);
      expect(created.supabaseUserId, instructorAUuid,
          reason: 'user_id course yang baru dibuat harus sesuai dengan UUID Instructor A');

      final targetId = created.id!;

      // C. Instructor A dapat melihat course miliknya
      await provider.fetchSupabaseCourses();
      expect(provider.supabaseCourses.any((c) => c.id == targetId), isTrue);

      // D. Instructor A dapat mengedit course miliknya sendiri
      final editedCourse = created.copyWith(
        title: 'Pengembangan Aplikasi Flutter Lanjut (Revisi Instructor A)',
        credits: 4,
      );

      final updateSuccess = await provider.updateSupabaseCourse(editedCourse, id: targetId);
      expect(updateSuccess, isTrue);
      expect(provider.updateSupabaseCourseError, isNull);

      final verified = provider.supabaseCourses.firstWhere((c) => c.id == targetId);
      expect(verified.title, 'Pengembangan Aplikasi Flutter Lanjut (Revisi Instructor A)');
      expect(verified.credits, 4);
    });

    test('Kasus B — Instructor B: Membaca (diizinkan), UPDATE (ditolak), DELETE (ditolak), INSERT spoofing user_id (ditolak)', () async {
      // 1. Buat course awal oleh Instructor A
      dbService.switchSession(userId: instructorAUuid, role: 'instructor');
      const courseA = Course(
        code: 'SEC-A-OWNED',
        title: 'Materi Asli Milik Instructor A',
        credits: 3,
        status: 'active',
      );
      await provider.createSupabaseCourse(courseA);
      final createdA = provider.supabaseCourses.firstWhere((c) => c.code == 'SEC-A-OWNED');
      final targetCourseId = createdA.id!;
      expect(createdA.supabaseUserId, instructorAUuid);

      // 2. Instructor B login menggunakan akun yang berbeda
      dbService.switchSession(userId: instructorBUuid, role: 'instructor');

      // 6. Instructor B dapat melihat course milik Instructor A (policy SELECT diizinkan)
      await provider.fetchSupabaseCourses();
      expect(provider.supabaseError, isNull);
      final visibleToB = provider.supabaseCourses.where((c) => c.id == targetCourseId).firstOrNull;
      expect(visibleToB, isNotNull,
          reason: 'Policy courses_select_authenticated mengizinkan authenticated user membaca course');
      expect(visibleToB!.supabaseUserId, instructorAUuid);

      // 7. Instructor B mencoba mengedit course milik Instructor A -> Ditolak RLS
      final maliciousEdit = visibleToB.copyWith(
        title: 'Course Ini Dihack oleh Instructor B',
        credits: 1,
      );
      final updateSuccess = await provider.updateSupabaseCourse(maliciousEdit, id: targetCourseId);
      expect(updateSuccess, isFalse,
          reason: 'RLS UPDATE harus menolak pembaruan data milik pengguna lain oleh Instructor B');
      expect(provider.updateSupabaseCourseError, isNotNull);
      expect(
        provider.updateSupabaseCourseError!.toLowerCase(),
        anyOf([
          contains('rls'),
          contains('ditolak'),
          contains('tidak diizinkan'),
          contains('row-level security'),
        ]),
      );

      // 8. Instructor B mencoba menghapus course milik Instructor A -> Ditolak RLS
      final deleteSuccess = await provider.deleteSupabaseCourse(targetCourseId);
      expect(deleteSuccess, isFalse,
          reason: 'RLS DELETE harus menolak penghapusan data milik pengguna lain oleh Instructor B');
      expect(provider.deleteSupabaseCourseError, isNotNull);
      expect(
        provider.deleteSupabaseCourseError!.toLowerCase(),
        anyOf([
          contains('rls'),
          contains('ditolak'),
          contains('tidak diizinkan'),
          contains('row-level security'),
        ]),
      );

      // 9. Instructor B mencoba membuat course dengan user_id milik Instructor A -> Ditolak RLS
      const spoofedCourse = Course(
        code: 'SPOOF-01',
        title: 'Course Palsu Mengatasnamakan Instructor A',
        credits: 3,
        status: 'active',
        supabaseUserId: instructorAUuid, // Upaya memalsukan user_id
      );

      final spoofSuccess = await provider.createSupabaseCourse(spoofedCourse);
      expect(spoofSuccess, isFalse,
          reason: 'RLS INSERT harus menolak pembuatan course dengan user_id milik pengguna lain');
      expect(provider.createSupabaseCourseError, isNotNull);
      expect(
        provider.createSupabaseCourseError!.toLowerCase(),
        anyOf([
          contains('rls'),
          contains('ditolak'),
          contains('dilarang insert'),
          contains('row-level security'),
        ]),
      );
    });

    test('Pembersihan data: Instructor A (pemilik sah) dapat menghapus course miliknya sendiri', () async {
      // 1. Buat course pengujian oleh Instructor A
      dbService.switchSession(userId: instructorAUuid, role: 'instructor');
      const tempCourse = Course(
        code: 'TEMP-CLEANUP',
        title: 'Course Sementara Untuk Uji Hapus',
        credits: 2,
        status: 'planned',
      );
      await provider.createSupabaseCourse(tempCourse);
      final target = provider.supabaseCourses.firstWhere((c) => c.code == 'TEMP-CLEANUP');
      final targetId = target.id!;

      // 2. Instructor A menghapus course miliknya sendiri -> Berhasil
      final deleteSuccess = await provider.deleteSupabaseCourse(targetId);
      expect(deleteSuccess, isTrue);
      expect(provider.deleteSupabaseCourseError, isNull);

      final remaining = provider.supabaseCourses.where((c) => c.id == targetId).toList();
      expect(remaining, isEmpty, reason: 'Course harus terhapus setelah dihapus oleh pemiliknya');
    });
  });

  // ===========================================================================
  // BAGIAN 2: LIVE SUPABASE INTEGRATION SECURITY TEST (DUA SESI INSTRUCTOR TERPISAH)
  // ===========================================================================
  // Pengujian ini berjalan hanya ketika kredensial dua akun Instructor diberikan
  // melalui argument --dart-define. Jika tidak tersedia, pengujian dilewati (skipped).
  //
  // Perintah eksekusi:
  // flutter test test/worksheet9_praktik6_security_test.dart \
  //   --dart-define=INSTRUCTOR_A_EMAIL="instructorA@example.com" \
  //   --dart-define=INSTRUCTOR_A_PASSWORD="passwordA" \
  //   --dart-define=INSTRUCTOR_B_EMAIL="instructorB@example.com" \
  //   --dart-define=INSTRUCTOR_B_PASSWORD="passwordB"
  // ===========================================================================
  const instructorAEmail = String.fromEnvironment('INSTRUCTOR_A_EMAIL');
  const instructorAPassword = String.fromEnvironment('INSTRUCTOR_A_PASSWORD');
  const instructorBEmail = String.fromEnvironment('INSTRUCTOR_B_EMAIL');
  const instructorBPassword = String.fromEnvironment('INSTRUCTOR_B_PASSWORD');

  final hasLiveCredentials = instructorAEmail.isNotEmpty &&
      instructorAPassword.isNotEmpty &&
      instructorBEmail.isNotEmpty &&
      instructorBPassword.isNotEmpty;

  group(
    'Worksheet 9 Praktik 6 — Live Supabase Multi-Instructor Security Test',
    skip: !hasLiveCredentials
        ? 'Dilewati: Jalankan dengan --dart-define INSTRUCTOR_A_EMAIL, INSTRUCTOR_A_PASSWORD, INSTRUCTOR_B_EMAIL, INSTRUCTOR_B_PASSWORD.'
        : false,
    () {
      SupabaseClient? clientA;
      SupabaseClient? clientB;
      late CourseProvider providerA;
      late CourseProvider providerB;
      String? actualInstructorAUuid;
      String? actualInstructorBUuid;
      int? liveCreatedCourseId;
      late String liveTestCode;

      setUpAll(() async {
        // Inisialisasi DUA client Supabase yang terpisah agar sesi A dan B tidak saling menimpa
        clientA = SupabaseClient(
          SupabaseConfig.supabaseUrl,
          SupabaseConfig.supabaseAnonKey,
        );
        clientB = SupabaseClient(
          SupabaseConfig.supabaseUrl,
          SupabaseConfig.supabaseAnonKey,
        );

        // Login Instructor A
        final authA = await clientA!.auth.signInWithPassword(
          email: instructorAEmail,
          password: instructorAPassword,
        );
        actualInstructorAUuid = authA.user?.id;

        // Login Instructor B
        final authB = await clientB!.auth.signInWithPassword(
          email: instructorBEmail,
          password: instructorBPassword,
        );
        actualInstructorBUuid = authB.user?.id;

        expect(actualInstructorAUuid, isNotNull);
        expect(actualInstructorBUuid, isNotNull);
        expect(
          actualInstructorAUuid,
          isNot(equals(actualInstructorBUuid)),
          reason: 'Akun Instructor A dan Instructor B harus merupakan akun yang berbeda.',
        );

        // Siapkan arsitektur CourseProvider untuk masing-masing client
        final serviceA = CourseSupabaseService(client: clientA);
        final repoA = CourseRepository(CourseService(), CourseApiService(), serviceA);
        providerA = CourseProvider(repoA);

        final serviceB = CourseSupabaseService(client: clientB);
        final repoB = CourseRepository(CourseService(), CourseApiService(), serviceB);
        providerB = CourseProvider(repoB);

        liveTestCode = 'SEC-AUDIT-${DateTime.now().millisecondsSinceEpoch}';
      });

      tearDownAll(() async {
        // Cleanup pengujian: Hapus course pengujian menggunakan akun Instructor A jika masih ada
        if (liveCreatedCourseId != null && clientA != null) {
          try {
            await providerA.deleteSupabaseCourse(liveCreatedCourseId!);
          } catch (_) {}
        }

        if (clientA != null) {
          if (clientA!.auth.currentSession != null) {
            await clientA!.auth.signOut();
          }
          await clientA!.dispose();
        }

        if (clientB != null) {
          if (clientB!.auth.currentSession != null) {
            await clientB!.auth.signOut();
          }
          await clientB!.dispose();
        }
      });

      test('Live Kasus A: Instructor A membuat course, verifikasi user_id, baca, dan update', () async {
        final courseA = Course(
          code: liveTestCode,
          title: 'Live Security Test Course Instructor A',
          credits: 3,
          status: 'active',
        );

        // 1. Instructor A membuat course
        final createSuccess = await providerA.createSupabaseCourse(courseA);
        expect(createSuccess, isTrue);
        expect(providerA.createSupabaseCourseError, isNull);

        // 2. Verifikasi course tersimpan di Supabase dengan user_id milik Instructor A
        final createdCourse = providerA.supabaseCourses
            .where((c) => c.code == liveTestCode)
            .firstOrNull;

        expect(createdCourse, isNotNull);
        expect(createdCourse!.id, isNotNull);
        expect(createdCourse.supabaseUserId, actualInstructorAUuid,
            reason: 'user_id di Supabase harus bernilai UUID Instructor A');

        liveCreatedCourseId = createdCourse.id!;

        // 3. Instructor A dapat mengedit course miliknya sendiri
        final updatedCourse = createdCourse.copyWith(
          title: 'Live Security Test Course Instructor A (Updated Title)',
          credits: 4,
        );

        final updateSuccess = await providerA.updateSupabaseCourse(
          updatedCourse,
          id: liveCreatedCourseId,
        );
        expect(updateSuccess, isTrue);
        expect(providerA.updateSupabaseCourseError, isNull);
      });

      test('Live Kasus B: Instructor B membaca (diizinkan), UPDATE (ditolak RLS), DELETE (ditolak RLS), INSERT spoofing user_id (ditolak RLS)', () async {
        expect(liveCreatedCourseId, isNotNull,
            reason: 'Course dari Instructor A harus sudah dibuat terlebih dahulu');

        // 1. Instructor B membaca daftar course
        await providerB.fetchSupabaseCourses();
        expect(providerB.supabaseError, isNull);

        final courseVisibleToB = providerB.supabaseCourses
            .where((c) => c.id == liveCreatedCourseId)
            .firstOrNull;

        expect(courseVisibleToB, isNotNull,
            reason: 'Policy courses_select_authenticated mengizinkan Instructor B membaca seluruh course');
        expect(courseVisibleToB!.supabaseUserId, actualInstructorAUuid);

        // 2. Instructor B mencoba UPDATE course milik Instructor A -> Ditolak RLS database
        final maliciousUpdate = courseVisibleToB.copyWith(
          title: 'Illegally Modified by Instructor B',
          credits: 1,
        );

        final updateSuccess = await providerB.updateSupabaseCourse(
          maliciousUpdate,
          id: liveCreatedCourseId,
        );
        expect(updateSuccess, isFalse,
          reason: 'Database Supabase RLS policy courses_update_instructor_admin harus menolak update lintas pemilik');
        expect(providerB.updateSupabaseCourseError, isNotNull);

        // 3. Instructor B mencoba DELETE course milik Instructor A -> Ditolak RLS database
        final deleteSuccess = await providerB.deleteSupabaseCourse(liveCreatedCourseId!);
        expect(deleteSuccess, isFalse,
          reason: 'Database Supabase RLS policy courses_delete_instructor_admin harus menolak delete lintas pemilik');
        expect(providerB.deleteSupabaseCourseError, isNotNull);

        // 4. Instructor B mencoba INSERT course dengan user_id milik Instructor A -> Ditolak RLS database
        final spoofCode = 'SPOOF-LIVE-${DateTime.now().millisecondsSinceEpoch}';
        final spoofedCourse = Course(
          code: spoofCode,
          title: 'Illegal Spoofed Course',
          credits: 2,
          status: 'planned',
          supabaseUserId: actualInstructorAUuid,
        );

        final spoofSuccess = await providerB.createSupabaseCourse(spoofedCourse);
        expect(spoofSuccess, isFalse,
          reason: 'Database Supabase RLS policy courses_insert_instructor_admin harus menolak insert jika user_id != auth.uid()');
        expect(providerB.createSupabaseCourseError, isNotNull);
      });

      test('Live Cleanup: Instructor A menghapus course miliknya sendiri dari Supabase', () async {
        expect(liveCreatedCourseId, isNotNull);

        // Instructor A menghapus course miliknya sendiri
        final deleteSuccess = await providerA.deleteSupabaseCourse(liveCreatedCourseId!);
        expect(deleteSuccess, isTrue,
            reason: 'Instructor A sebagai pemilik sah harus berhasil menghapus course miliknya sendiri');
        expect(providerA.deleteSupabaseCourseError, isNull);

        // Verifikasi course sudah tidak ada di Supabase
        await providerA.fetchSupabaseCourses();
        final found = providerA.supabaseCourses
            .where((c) => c.id == liveCreatedCourseId)
            .firstOrNull;
        expect(found, isNull, reason: 'Course harus berhasil terhapus dari tabel courses Supabase');

        liveCreatedCourseId = null;
      });
    },
  );
}

