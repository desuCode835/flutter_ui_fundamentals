// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/config/supabase_config.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Tahap 16 - Supabase CRUD Integration Test', () {
    late SupabaseClient client;
    late CourseSupabaseService supabaseService;
    late CourseRepository repository;
    late CourseProvider provider;

    setUpAll(() {
      client = SupabaseClient(
        SupabaseConfig.supabaseUrl,
        SupabaseConfig.supabaseAnonKey,
      );
      supabaseService = CourseSupabaseService(client: client);
      repository = CourseRepository(
        CourseService(),
        CourseApiService(),
        supabaseService,
      );
      provider = CourseProvider(repository);
    });

    test(
      '1. READ: getCourses / fetchSupabaseCourses berhasil membaca data',
      () async {
        await provider.fetchSupabaseCourses();

        expect(provider.isSupabaseLoading, isFalse);
        expect(provider.supabaseError, isNull);
        expect(provider.hasFetchedSupabase, isTrue);
        expect(provider.supabaseCourses, isA<List<Course>>());
      },
    );

    test('2. CREATE, UPDATE, DELETE Full Lifecycle Test di Supabase', () async {
      final testCode =
          'TEST-AUDIT-${DateTime.now().millisecondsSinceEpoch % 10000}';
      final testCourse = Course(
        code: testCode,
        title: 'Audit Course Mini Project',
        credits: 3,
        status: 'planned',
      );

      // --- A. CREATE ---
      final createSuccess = await provider.createSupabaseCourse(testCourse);
      expect(createSuccess, isTrue);
      expect(provider.isCreatingSupabaseCourse, isFalse);
      expect(provider.createSupabaseCourseError, isNull);

      // Pastikan item yang baru dibuat muncul di provider.supabaseCourses
      final createdCourse = provider.supabaseCourses
          .where((c) => c.code == testCode)
          .firstOrNull;
      expect(
        createdCourse,
        isNotNull,
        reason: 'Course yang di-insert harus muncul di Supabase',
      );
      expect(
        createdCourse!.id,
        isNotNull,
        reason: 'ID dari database Supabase harus tersedia',
      );
      final targetId = createdCourse.id!;

      // --- B. UPDATE ---
      final updatedCourse = createdCourse.copyWith(
        title: 'Audit Course Updated Title',
        credits: 4,
        status: 'active',
      );
      final updateSuccess = await provider.updateSupabaseCourse(
        updatedCourse,
        id: targetId,
      );
      expect(updateSuccess, isTrue);
      expect(provider.isUpdatingSupabaseCourse, isFalse);
      expect(provider.updateSupabaseCourseError, isNull);

      final foundAfterUpdate = provider.supabaseCourses
          .where((c) => c.id == targetId)
          .firstOrNull;
      expect(foundAfterUpdate, isNotNull);
      expect(foundAfterUpdate!.title, 'Audit Course Updated Title');
      expect(foundAfterUpdate.credits, 4);
      expect(foundAfterUpdate.status, 'active');

      // --- C. DELETE ---
      final deleteSuccess = await provider.deleteSupabaseCourse(targetId);
      expect(deleteSuccess, isTrue);
      expect(provider.isDeletingSupabaseCourse, isFalse);
      expect(provider.deleteSupabaseCourseError, isNull);

      // Verifikasi item benar-benar terhapus dari Supabase
      final foundAfterDelete = provider.supabaseCourses
          .where((c) => c.id == targetId)
          .firstOrNull;
      expect(
        foundAfterDelete,
        isNull,
        reason: 'Course harus terhapus dari Supabase',
      );
    });

    test('3. Error Handling & Retry Test', () async {
      // Buat client dengan URL yang salah untuk menguji error state
      final brokenClient = SupabaseClient(
        'https://invalid-supabase-url-for-test.supabase.co',
        'invalid-anon-key',
      );
      final brokenService = CourseSupabaseService(client: brokenClient);
      final brokenRepo = CourseRepository(
        CourseService(),
        CourseApiService(),
        brokenService,
      );
      final brokenProvider = CourseProvider(brokenRepo);

      // Panggil fetchSupabaseCourses pada brokenProvider
      await brokenProvider.fetchSupabaseCourses();
      expect(brokenProvider.isSupabaseLoading, isFalse);
      expect(brokenProvider.supabaseError, isNotNull);
      expect(brokenProvider.hasFetchedSupabase, isTrue);

      // Pulihkan kondisi dengan memanggil fetchSupabaseCourses pada provider yang normal
      await provider.fetchSupabaseCourses();
      expect(provider.isSupabaseLoading, isFalse);
      expect(provider.supabaseError, isNull);
    });
  });
}
