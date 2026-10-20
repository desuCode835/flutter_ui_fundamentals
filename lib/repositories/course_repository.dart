// Nama : Gede Supadma
// NIM : 2415051014

import '../models/course.dart';
import '../services/course_api_service.dart';
import '../services/course_service.dart';

// =============================================================================
// TAHAP 4: REPOSITORY LAYER (MENGHUBUNGKAN SERVICE LOKAL & SERVICE API)
// =============================================================================
class CourseRepository {
  final CourseService service;
  final CourseApiService apiService;

  CourseRepository(this.service, [CourseApiService? apiService])
    : apiService = apiService ?? CourseApiService();

  /// Membaca daftar course dari aset JSON lokal via CourseService
  Future<List<Course>> getCourses() {
    return service.loadCourses();
  }

  // ===========================================================================
  // TAHAP 4: METHOD HTTP GET POSTS MELALUI CourseApiService
  // ===========================================================================
  Future<List<Course>> getPosts({String? endpoint}) {
    return apiService.fetchPosts(endpoint: endpoint);
  }
}
