// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/courses_page.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:provider/provider.dart';

/// Mock service Supabase in-memory untuk pengujian sinkronisasi data
class MockSupabaseService extends CourseSupabaseService {
  final List<Course> _database = [
    const Course(
      id: 1,
      code: 'CS101',
      title: 'Pemrograman Berorientasi Objek',
      credits: 3,
      status: 'active',
    ),
    const Course(
      id: 2,
      code: 'CS102',
      title: 'Struktur Data & Algoritma',
      credits: 4,
      status: 'planned',
    ),
  ];

  @override
  Future<List<Course>> getCourses() async {
    return List<Course>.from(_database);
  }

  @override
  Future<void> createCourse(Course course) async {
    validateCourse(course);
    final newId = (_database.isEmpty ? 0 : _database.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b)) + 1;
    _database.insert(0, course.copyWith(id: newId));
  }

  @override
  Future<void> updateCourse(Course course, {int? id}) async {
    validateCourse(course, isUpdate: true);
    final targetId = id ?? course.id;
    final index = _database.indexWhere((c) => c.id == targetId);
    if (index != -1) {
      _database[index] = course;
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    _database.removeWhere((c) => c.id == id);
  }

  void clearDatabase() {
    _database.clear();
  }
}

void main() {
  group('Perbaikan Sinkronisasi Data Halaman Courses & Supabase', () {
    late MockSupabaseService mockSupabase;
    late CourseRepository repository;
    late CourseProvider provider;

    setUp(() {
      mockSupabase = MockSupabaseService();
      repository = CourseRepository(
        CourseService(),
        CourseApiService(),
        mockSupabase,
      );
      provider = CourseProvider(repository);
    });

    test('1. fetchSupabaseCourses menyinkronkan data ke supabaseCourses DAN courses', () async {
      expect(provider.courses, isEmpty);
      expect(provider.supabaseCourses, isEmpty);

      await provider.fetchSupabaseCourses();

      expect(provider.supabaseCourses.length, 2);
      expect(provider.courses.length, 2);
      expect(provider.courses.first.code, 'CS101');
      expect(provider.courses.first.title, 'Pemrograman Berorientasi Objek');
      expect(provider.hasFetchedSupabase, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.isSupabaseLoading, isFalse);
    });

    test('2. loadCourses() memanggil fetchSupabaseCourses secara default', () async {
      await provider.loadCourses();

      expect(provider.courses.length, 2);
      expect(provider.supabaseCourses.length, 2);
      expect(provider.courses.map((c) => c.code), containsAll(['CS101', 'CS102']));
    });

    test('3. createSupabaseCourse memperbarui data di Home (supabaseCourses) dan Courses (courses)', () async {
      await provider.fetchSupabaseCourses();
      expect(provider.courses.length, 2);

      const newCourse = Course(
        code: 'CS103',
        title: 'Pengembangan Aplikasi Mobile',
        credits: 3,
        status: 'active',
      );

      final success = await provider.createSupabaseCourse(newCourse);
      expect(success, isTrue);

      // Pastikan kedua state terupdate secara konsisten
      expect(provider.supabaseCourses.length, 3);
      expect(provider.courses.length, 3);
      expect(provider.courses.first.code, 'CS103');
      expect(provider.supabaseCourses.first.code, 'CS103');
    });

    test('4. updateSupabaseCourse menyinkronkan pembaruan data ke kedua state', () async {
      await provider.fetchSupabaseCourses();

      final existing = provider.courses.first;
      final updated = existing.copyWith(
        title: 'Pemrograman Berorientasi Objek Lanjutan',
        credits: 4,
      );

      final success = await provider.updateSupabaseCourse(updated, id: existing.id);
      expect(success, isTrue);

      expect(provider.courses.first.title, 'Pemrograman Berorientasi Objek Lanjutan');
      expect(provider.courses.first.credits, 4);
      expect(provider.supabaseCourses.first.title, 'Pemrograman Berorientasi Objek Lanjutan');
    });

    test('5. deleteSupabaseCourse menyinkronkan penghapusan data ke kedua state', () async {
      await provider.fetchSupabaseCourses();
      expect(provider.courses.length, 2);

      final targetId = provider.courses.first.id!;
      final success = await provider.deleteSupabaseCourse(targetId);
      expect(success, isTrue);

      expect(provider.courses.length, 1);
      expect(provider.supabaseCourses.length, 1);
      expect(provider.courses.any((c) => c.id == targetId), isFalse);
      expect(provider.supabaseCourses.any((c) => c.id == targetId), isFalse);
    });

    test('6. Favorite functionality bekerja dengan data Supabase yang tersinkron', () async {
      await provider.fetchSupabaseCourses();

      expect(provider.isFavorite('CS101'), isFalse);
      expect(provider.favoriteCourses, isEmpty);

      provider.toggleFavorite('CS101');
      expect(provider.isFavorite('CS101'), isTrue);
      expect(provider.favoriteCourses.length, 1);
      expect(provider.favoriteCourses.first.title, 'Pemrograman Berorientasi Objek');

      provider.toggleFavorite('CS101');
      expect(provider.isFavorite('CS101'), isFalse);
      expect(provider.favoriteCourses, isEmpty);
    });

    testWidgets('7. CoursesPage menampilkan data Supabase dan statistik yang sesuai', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ChangeNotifierProvider<CourseProvider>.value(
          value: provider,
          child: const MaterialApp(home: CoursesPage()),
        ),
      );

      // Tunggu async loadCourses() selesai
      await tester.pumpAndSettle();

      // Cek header mahasiswa
      expect(find.text('2415051014 • Gede Supadma'), findsOneWidget);

      // Cek counter statistik
      expect(find.text('Courses (Supabase)'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Cek nama course dari mock database Supabase
      expect(find.text('Pemrograman Berorientasi Objek'), findsOneWidget);
      expect(find.text('Struktur Data & Algoritma'), findsOneWidget);
      expect(find.text('CS101'), findsOneWidget);
      expect(find.text('CS102'), findsOneWidget);
    });

    testWidgets('8. CoursesPage menampilkan Empty State saat database Supabase kosong', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      mockSupabase.clearDatabase();

      await tester.pumpWidget(
        ChangeNotifierProvider<CourseProvider>.value(
          value: provider,
          child: const MaterialApp(home: CoursesPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Course di Supabase'), findsOneWidget);
      expect(find.text('Tambahkan course baru melalui menu Home untuk melihat daftar di sini.'), findsOneWidget);
      expect(find.text('Segarkan'), findsOneWidget);
    });

    testWidgets('9. CoursesPage memiliki tombol refresh pada AppBar', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ChangeNotifierProvider<CourseProvider>.value(
          value: provider,
          child: const MaterialApp(home: CoursesPage()),
        ),
      );

      await tester.pumpAndSettle();

      final refreshBtn = find.byTooltip('Segarkan Course Supabase');
      expect(refreshBtn, findsOneWidget);

      // Tap tombol refresh
      await tester.tap(refreshBtn);
      await tester.pumpAndSettle();

      expect(find.text('Pemrograman Berorientasi Objek'), findsOneWidget);
    });
  });
}

