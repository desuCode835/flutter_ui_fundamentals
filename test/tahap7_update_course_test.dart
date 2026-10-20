// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';

void main() {
  group('Tahap 7 - Model Course copyWith Test', () {
    test('copyWith memperbarui field yang ditentukan dan mempertahankan field lainnya', () {
      const original = Course(
        code: 'MOB01',
        title: 'Pemrograman Mobile Dasar',
        credits: 2,
        status: 'active',
        id: 1,
        userId: 1,
        body: 'Deskripsi awal',
      );

      final updated = original.copyWith(
        code: 'MOB01-REV',
        title: 'Pemrograman Mobile Lanjut',
        credits: 4,
      );

      expect(updated.code, 'MOB01-REV');
      expect(updated.title, 'Pemrograman Mobile Lanjut');
      expect(updated.credits, 4);
      expect(updated.status, 'active');
      expect(updated.id, 1);
      expect(updated.userId, 1);
      expect(updated.body, 'Deskripsi awal');
    });
  });

  group('Tahap 7 - Service Layer updateCourse (HTTP PUT / PATCH) Test', () {
    test('updateCourse dengan HTTP PUT berhasil mengembalikan objek Course yang diperbarui', () async {
      final apiService = CourseApiService();
      const courseToUpdate = Course(
        code: 'MOB07-PUT',
        title: 'Praktikum HTTP PUT Flutter',
        credits: 3,
        id: 1,
        userId: 1,
      );

      final result = await apiService.updateCourse(
        courseToUpdate,
        usePatch: false,
      );

      expect(result.id, 1);
      expect(result.code, 'MOB07-PUT');
      expect(result.credits, 3);
      expect(result.title, isNotEmpty);
    });

    test('updateCourse dengan HTTP PATCH berhasil mengembalikan objek Course yang diperbarui', () async {
      final apiService = CourseApiService();
      const courseToPatch = Course(
        code: 'MOB07-PATCH',
        title: 'Praktikum HTTP PATCH Flutter',
        credits: 4,
        id: 2,
        userId: 1,
      );

      final result = await apiService.updateCourse(
        courseToPatch,
        usePatch: true,
      );

      expect(result.id, 2);
      expect(result.code, 'MOB07-PATCH');
      expect(result.credits, 4);
      expect(result.title, isNotEmpty);
    });

    test('updateCourse dengan endpoint salah melempar Exception', () async {
      final apiService = CourseApiService();
      const course = Course(
        code: 'ERR',
        title: 'Error Test',
        credits: 1,
        id: 1,
      );

      expect(
        () => apiService.updateCourse(
          course,
          endpoint: 'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Tahap 7 - Repository Layer updateCourse Test', () {
    test(
      'CourseRepository meneruskan updateCourse ke CourseApiService',
      () async {
        final service = CourseService();
        final apiService = CourseApiService();
        final repository = CourseRepository(service, apiService);

        const course = Course(
          code: 'REPO-PUT',
          title: 'Repository Test',
          credits: 3,
          id: 1,
        );

        final result = await repository.updateCourse(course);
        expect(result.code, 'REPO-PUT');
        expect(result.credits, 3);
      },
    );
  });

  group('Tahap 7 - Provider Layer updateCourse State Test', () {
    test(
      'updateCourse memperbarui item yang tepat dalam daftar posts provider',
      () async {
        final service = CourseService();
        final repository = CourseRepository(service);
        final provider = CourseProvider(repository);

        // Inisialisasi daftar posts dengan data tiruan
        provider.posts = [
          const Course(
            code: 'POST-1',
            title: 'Judul Asli Post 1',
            credits: 1,
            id: 1,
            userId: 1,
          ),
          const Course(
            code: 'POST-2',
            title: 'Judul Asli Post 2',
            credits: 2,
            id: 2,
            userId: 1,
          ),
        ];

        final updatedCourse = const Course(
          code: 'POST-1-EDITED',
          title: 'Judul Post 1 Setelah Diedit',
          credits: 4,
          id: 1,
          userId: 1,
        );

        final success = await provider.updateCourse(
          updatedCourse,
          originalCode: 'POST-1',
          originalId: 1,
        );

        expect(success, isTrue);
        expect(provider.posts.length, 2);
        expect(provider.posts[0].code, 'POST-1-EDITED');
        expect(provider.posts[0].title, 'Judul Post 1 Setelah Diedit');
        expect(provider.posts[0].credits, 4);
        // Item kedua tidak berubah
        expect(provider.posts[1].code, 'POST-2');
        expect(provider.isUpdatingCourse, isFalse);
        expect(provider.updateCourseError, isNull);
      },
    );

    test('updateCourse menangani kegagalan dengan mengembalikan false dan menyimpan updateCourseError', () async {
      final service = CourseService();
      final repository = CourseRepository(service);
      final provider = CourseProvider(repository);

      provider.posts = [
        const Course(code: 'POST-1', title: 'Post 1', credits: 1, id: 1),
      ];

      const updatedCourse = Course(
        code: 'FAIL',
        title: 'Failure Test',
        credits: 1,
        id: 1,
      );

      final success = await provider.updateCourse(
        updatedCourse,
        originalCode: 'POST-1',
        originalId: 1,
        endpoint: 'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test',
      );

      expect(success, isFalse);
      expect(provider.isUpdatingCourse, isFalse);
      expect(provider.updateCourseError, isNotNull);
      // Data lama tidak rusak
      expect(provider.posts[0].code, 'POST-1');
    });
  });
}
