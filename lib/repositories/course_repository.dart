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
}
