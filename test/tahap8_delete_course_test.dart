// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';

void main() {
  group('Tahap 8 - Service Layer deleteCourse (HTTP DELETE) Test', () {
    test(
      'deleteCourse berhasil menghapus resource dan mengembalikan true',
      () async {
        final apiService = CourseApiService();

        final success = await apiService.deleteCourse(1);
        expect(success, isTrue);
      },
    );

    test('deleteCourse dengan endpoint salah melempar Exception', () async {
      final apiService = CourseApiService();

      expect(
        () => apiService.deleteCourse(
          1,
          endpoint: 'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Tahap 8 - Repository Layer deleteCourse Test', () {
    test(
      'CourseRepository meneruskan deleteCourse ke CourseApiService',
      () async {
        final service = CourseService();
        final apiService = CourseApiService();
        final repository = CourseRepository(service, apiService);

        final result = await repository.deleteCourse(1);
        expect(result, isTrue);
      },
    );
  });

  group('Tahap 8 - Provider Layer deleteCourse State Test', () {
    test(
      'deleteCourse berhasil menghapus item dari daftar posts provider',
      () async {
        final service = CourseService();
        final repository = CourseRepository(service);
        final provider = CourseProvider(repository);

        // Inisialisasi daftar posts dengan dua item
        provider.posts = [
          const Course(
            code: 'POST-1',
            title: 'Post 1 to delete',
            credits: 1,
            id: 1,
            userId: 1,
          ),
          const Course(
            code: 'POST-2',
            title: 'Post 2 to keep',
            credits: 2,
            id: 2,
            userId: 1,
          ),
        ];

        final success = await provider.deleteCourse(1, code: 'POST-1');

        expect(success, isTrue);
        // Item POST-1 terhapus dari daftar
        expect(provider.posts.length, 1);
        expect(provider.posts.first.code, 'POST-2');
        expect(provider.isDeletingCourse, isFalse);
        expect(provider.deleteCourseError, isNull);
      },
    );

    test(
      'deleteCourse yang gagal TIDAK menghapus item dari daftar posts provider',
      () async {
        final service = CourseService();
        final repository = CourseRepository(service);
        final provider = CourseProvider(repository);

        // Inisialisasi daftar posts dengan satu item
        provider.posts = [
          const Course(
            code: 'POST-1',
            title: 'Post 1 should remain on error',
            credits: 1,
            id: 1,
            userId: 1,
          ),
        ];

        final success = await provider.deleteCourse(
          1,
          code: 'POST-1',
          endpoint: 'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test',
        );

        // Request gagal
        expect(success, isFalse);
        // Item tetap ada di daftar posts (tidak terhapus dari UI saat error)
        expect(provider.posts.length, 1);
        expect(provider.posts.first.code, 'POST-1');
        expect(provider.isDeletingCourse, isFalse);
        expect(provider.deleteCourseError, isNotNull);
      },
    );
  });
}
