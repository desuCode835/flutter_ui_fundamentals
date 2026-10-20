// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';

/// Mock service untuk membuktikan Repository Pattern memisahkan Provider dari API sesungguhnya
class MockApiService extends CourseApiService {
  bool getPostsCalled = false;
  bool createCourseCalled = false;
  bool updateCourseCalled = false;
  bool deleteCourseCalled = false;

  @override
  Future<List<Course>> fetchPosts({String? endpoint}) async {
    getPostsCalled = true;
    return [
      const Course(
        code: 'POST-1',
        title: 'Mocked GET Post',
        credits: 3,
        id: 1,
        userId: 1,
      ),
    ];
  }

  @override
  Future<Course> createCourse(Course course, {String? endpoint}) async {
    createCourseCalled = true;
    return course.copyWith(id: 101, userId: 1);
  }

  @override
  Future<Course> updateCourse(
    Course course, {
    String? endpoint,
    bool usePatch = false,
  }) async {
    updateCourseCalled = true;
    return course;
  }

  @override
  Future<bool> deleteCourse(int id, {String? endpoint}) async {
    deleteCourseCalled = true;
    return true;
  }
}

void main() {
  group('Tahap 9 - Repository Pattern & Dependency Injection Test', () {
    test(
      'CourseRepository mengekspos apiUrl yang sama dengan CourseApiService',
      () {
        expect(CourseRepository.apiUrl, equals(CourseApiService.apiUrl));
      },
    );

    test('CourseRepository meneruskan seluruh operasi (GET, POST, PUT, DELETE) ke service yang sesuai', () async {
      final mockApi = MockApiService();
      final localService = CourseService();
      final repository = CourseRepository(localService, mockApi);

      // 1. GET
      final posts = await repository.getPosts();
      expect(mockApi.getPostsCalled, isTrue);
      expect(posts.length, 1);
      expect(posts.first.title, 'Mocked GET Post');

      // 2. POST
      const newCourse = Course(
        code: 'MOB09',
        title: 'Repository Pattern Test',
        credits: 3,
      );
      final added = await repository.addCourse(newCourse);
      expect(mockApi.createCourseCalled, isTrue);
      expect(added.id, 101);

      // 3. UPDATE (PUT/PATCH)
      final updated = await repository.updateCourse(added);
      expect(mockApi.updateCourseCalled, isTrue);
      expect(updated.code, 'MOB09');

      // 4. DELETE
      final deleted = await repository.deleteCourse(101);
      expect(mockApi.deleteCourseCalled, isTrue);
      expect(deleted, isTrue);
    });

    test('CourseProvider hanya berkomunikasi melalui CourseRepository tanpa akses HTTP langsung', () async {
      final mockApi = MockApiService();
      final localService = CourseService();
      final repository = CourseRepository(localService, mockApi);
      final provider = CourseProvider(repository);

      // Test Provider GET via Repository
      await provider.fetchPosts();
      expect(mockApi.getPostsCalled, isTrue);
      expect(provider.posts.length, 1);
      expect(provider.posts.first.code, 'POST-1');

      // Test Provider POST via Repository
      const course = Course(
        code: 'POST-NEW',
        title: 'New Post via Repository',
        credits: 2,
      );
      final createSuccess = await provider.createCourse(course);
      expect(createSuccess, isTrue);
      expect(mockApi.createCourseCalled, isTrue);
      expect(provider.posts.first.code, 'POST-NEW');

      // Test Provider UPDATE via Repository
      final edited = course.copyWith(title: 'Edited Title');
      final updateSuccess = await provider.updateCourse(
        edited,
        originalCode: 'POST-NEW',
      );
      expect(updateSuccess, isTrue);
      expect(mockApi.updateCourseCalled, isTrue);
      expect(provider.posts.first.title, 'Edited Title');

      // Test Provider DELETE via Repository
      final deleteSuccess = await provider.deleteCourse(
        provider.posts.first.id ?? 101,
        code: 'POST-NEW',
      );
      expect(deleteSuccess, isTrue);
      expect(mockApi.deleteCourseCalled, isTrue);
      expect(provider.posts.any((p) => p.code == 'POST-NEW'), isFalse);
    });
  });
}
