// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';

void main() {
  group('Tahap 3 - Model Course Test', () {
    test('Course.fromJson memetakan data lokal dengan benar', () {
      final localJson = {
        'code': 'MOB01',
        'title': 'Git & GitHub',
        'credits': 2,
        'status': 'done',
      };

      final course = Course.fromJson(localJson);

      expect(course.code, 'MOB01');
      expect(course.title, 'Git & GitHub');
      expect(course.credits, 2);
      expect(course.status, 'done');
      expect(course.id, isNull);
      expect(course.userId, isNull);

      final exportedJson = course.toJson();
      expect(exportedJson, localJson);
    });

    test('Course.fromJson memetakan respons REST API JSONPlaceholder dengan benar', () {
      final apiJson = {
        'userId': 1,
        'id': 1,
        'title': 'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
        'body':
            'quia et suscipit suscipit recusandae consequuntur expedita et cum',
      };

      final course = Course.fromJson(apiJson);

      expect(course.id, 1);
      expect(course.userId, 1);
      expect(
        course.title,
        'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
      );
      expect(
        course.body,
        'quia et suscipit suscipit recusandae consequuntur expedita et cum',
      );
      // Identitas turunan
      expect(course.code, 'POST-1');

      // toJson harus konsisten dengan struktur data API dan tidak memasukkan field buatan (seperti code atau credits)
      final exportedJson = course.toJson();
      expect(exportedJson['userId'], 1);
      expect(exportedJson['id'], 1);
      expect(exportedJson['title'], course.title);
      expect(exportedJson['body'], course.body);
      expect(exportedJson.containsKey('code'), isFalse);
      expect(exportedJson.containsKey('credits'), isFalse);
      expect(exportedJson.containsKey('status'), isFalse);
    });

    test('Course.fromApiJson memetakan tanpa field code asli di JSON', () {
      final apiJson = {
        'userId': 2,
        'id': 42,
        'title': 'Testing Post 42',
        'body': 'Content 42',
      };

      final course = Course.fromApiJson(apiJson);
      expect(course.code, 'POST-42');
      expect(course.id, 42);
      expect(course.userId, 2);
    });
  });

  group('Tahap 4 - Service Layer & Repository Test', () {
    test('CourseApiService.apiUrl adalah endpoint yang benar', () {
      expect(
        CourseApiService.apiUrl,
        'https://jsonplaceholder.typicode.com/posts',
      );
    });

    test(
      'CourseRepository menginisialisasi CourseApiService dan CourseService',
      () {
        final service = CourseService();
        final apiService = CourseApiService();
        final repository = CourseRepository(service, apiService);

        expect(repository.service, service);
        expect(repository.apiService, apiService);
      },
    );
  });

  group('Tahap 5 - State Management (Loading, Success, Empty, Error) Test', () {
    test('State awal provider sebelum fetchPosts dipanggil', () {
      final service = CourseService();
      final repository = CourseRepository(service);
      final provider = CourseProvider(repository);

      expect(provider.isPostsLoading, isFalse);
      expect(provider.posts, isEmpty);
      expect(provider.postsError, isNull);
      expect(provider.hasFetchedPosts, isFalse);
      expect(provider.isPostsEmpty, isFalse);
      expect(provider.isPostsSuccess, isFalse);
    });

    test('clearPosts memicu kondisi Empty state', () {
      final service = CourseService();
      final repository = CourseRepository(service);
      final provider = CourseProvider(repository);

      provider.clearPosts();

      expect(provider.hasFetchedPosts, isTrue);
      expect(provider.isPostsLoading, isFalse);
      expect(provider.postsError, isNull);
      expect(provider.isPostsEmpty, isTrue);
      expect(provider.isPostsSuccess, isFalse);
    });
  });

  group('Tahap 6 - HTTP POST Test', () {
    test(
      'createCourse menambahkan item baru ke posisi awal daftar posts',
      () async {
        final service = CourseService();
        final repository = CourseRepository(service);
        final provider = CourseProvider(repository);

        const newCourse = Course(
          code: 'MOB06',
          title: 'REST API & Networking',
          credits: 3,
          status: 'active',
        );

        final success = await provider.createCourse(newCourse);
        expect(success, isTrue);
        expect(provider.posts.isNotEmpty, isTrue);
        expect(provider.posts.first.code, 'MOB06');
        expect(provider.posts.first.title, 'REST API & Networking');
        expect(provider.posts.first.credits, 3);
        expect(provider.isCreatingCourse, isFalse);
        expect(provider.createCourseError, isNull);
      },
    );
  });
}
