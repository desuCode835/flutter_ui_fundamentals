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
  const testEmail = String.fromEnvironment('TEST_EMAIL');
  const testPassword = String.fromEnvironment('TEST_PASSWORD');

  final hasCredentials = testEmail.isNotEmpty && testPassword.isNotEmpty;

  group(
    'Tahap 16 - Supabase CRUD Integration Test',
    skip: !hasCredentials
        ? 'Jalankan dengan TEST_EMAIL dan TEST_PASSWORD.'
        : false,
    () {
      SupabaseClient? client;
      late CourseSupabaseService supabaseService;
      late CourseRepository repository;
      late CourseProvider provider;

      setUpAll(() async {
        client = SupabaseClient(
          SupabaseConfig.supabaseUrl,
          SupabaseConfig.supabaseAnonKey,
        );

        final authenticatedClient = client!;

        // Login menggunakan akun Instructor khusus pengujian.
        await authenticatedClient.auth.signInWithPassword(
          email: testEmail,
          password: testPassword,
        );

        supabaseService = CourseSupabaseService(client: authenticatedClient);

        repository = CourseRepository(
          CourseService(),
          CourseApiService(),
          supabaseService,
        );

        provider = CourseProvider(repository);
      });

      tearDownAll(() async {
        if (client != null) {
          if (client!.auth.currentSession != null) {
            await client!.auth.signOut();
          }

          await client!.dispose();
        }
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

      test(
        '2. CREATE, UPDATE, DELETE Full Lifecycle Test di Supabase',
        () async {
          final currentUserId = client!.auth.currentUser?.id;

          expect(
            currentUserId,
            isNotNull,
            reason: 'Akun Instructor harus berhasil login.',
          );

          final testCode =
              'TEST-AUDIT-${DateTime.now().millisecondsSinceEpoch}';

          final testCourse = Course(
            code: testCode,
            title: 'Audit Course Mini Project',
            credits: 3,
            status: 'planned',
          );

          // A. CREATE
          final createSuccess = await provider.createSupabaseCourse(testCourse);

          expect(createSuccess, isTrue);
          expect(provider.isCreatingSupabaseCourse, isFalse);
          expect(provider.createSupabaseCourseError, isNull);

          final createdCourse = provider.supabaseCourses
              .where((c) => c.code == testCode)
              .firstOrNull;

          expect(
            createdCourse,
            isNotNull,
            reason: 'Course yang di-insert harus muncul di Supabase.',
          );

          expect(createdCourse!.id, isNotNull);

          expect(
            createdCourse.supabaseUserId,
            currentUserId,
            reason: 'user_id harus sesuai dengan UUID Instructor.',
          );

          final targetId = createdCourse.id!;

          // B. UPDATE
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

          // C. DELETE
          final deleteSuccess = await provider.deleteSupabaseCourse(targetId);

          expect(deleteSuccess, isTrue);
          expect(provider.isDeletingSupabaseCourse, isFalse);
          expect(provider.deleteSupabaseCourseError, isNull);

          final foundAfterDelete = provider.supabaseCourses
              .where((c) => c.id == targetId)
              .firstOrNull;

          expect(
            foundAfterDelete,
            isNull,
            reason: 'Course harus terhapus dari Supabase.',
          );
        },
      );

      test('3. Error Handling & Retry Test', () async {
        // Client dengan URL salah untuk menguji penanganan error.
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

        try {
          // Uji kegagalan koneksi.
          await brokenProvider.fetchSupabaseCourses();

          expect(brokenProvider.isSupabaseLoading, isFalse);
          expect(brokenProvider.supabaseError, isNotNull);
          expect(brokenProvider.hasFetchedSupabase, isTrue);

          // Pulihkan kondisi menggunakan client normal.
          await provider.fetchSupabaseCourses();

          expect(provider.isSupabaseLoading, isFalse);
          expect(provider.supabaseError, isNull);
        } finally {
          await brokenClient.dispose();
        }
      });
    },
  );
}
