// Nama : Gede Supadma
// NIM : 2415051014

import '../models/course.dart';
import '../services/course_service.dart';

class CourseRepository {
  final CourseService service;

  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.loadCourses();
  }

  // ===========================================================================
  // TAHAP 2 & 3: METHOD HTTP GET POSTS (MODEL COURSE)
  // ===========================================================================
  Future<List<Course>> getPosts({String? endpoint}) {
    return service.fetchPosts(endpoint: endpoint);
  }
}
