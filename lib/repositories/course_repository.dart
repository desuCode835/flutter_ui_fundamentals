// Nama : Gede Supadma
// NIM : 2415051014

import '../models/course.dart';
import '../services/course_api_service.dart';
import '../services/course_service.dart';
import '../services/course_supabase_service.dart';

// =============================================================================
// TAHAP 9: REPOSITORY PATTERN UNTUK REST API & DATA LOKAL (CourseRepository)
// =============================================================================
// Bertindak sebagai perantara (single source of truth) antara lapisan presentasi/state
// (CourseProvider) dan sumber data:
// - CourseService untuk data lokal (student_data.json)
// - CourseApiService untuk REST API (JSONPlaceholder)
// - CourseSupabaseService untuk database Supabase (tabel courses - Tahap 12)
class CourseRepository {
  // Referensi apiUrl yang diteruskan dari CourseApiService
  static const String apiUrl = CourseApiService.apiUrl;

  final CourseService service;
  final CourseApiService apiService;
  final CourseSupabaseService supabaseService;

  CourseRepository(
    this.service, [
    CourseApiService? apiService,
    CourseSupabaseService? supabaseService,
  ])  : apiService = apiService ?? CourseApiService(),
        supabaseService = supabaseService ?? CourseSupabaseService();

  /// Membaca daftar course dari aset JSON lokal via CourseService
  Future<List<Course>> getCourses() {
    return service.loadCourses();
  }

  // ===========================================================================
  // TAHAP 12: METHOD SELECT COURSES MELALUI CourseSupabaseService
  // ===========================================================================
  /// Membaca daftar course dari database Supabase (tabel courses)
  Future<List<Course>> getSupabaseCourses() {
    return supabaseService.getCourses();
  }

  // ===========================================================================
  // TAHAP 4: METHOD HTTP GET POSTS MELALUI CourseApiService
  // ===========================================================================
  Future<List<Course>> getPosts({String? endpoint}) {
    return apiService.fetchPosts(endpoint: endpoint);
  }

  // ===========================================================================
  // TAHAP 6: METHOD HTTP POST COURSE MELALUI CourseApiService
  // ===========================================================================
  Future<Course> addCourse(Course course, {String? endpoint}) {
    return apiService.createCourse(course, endpoint: endpoint);
  }

  // ===========================================================================
  // TAHAP 7: METHOD HTTP PUT/PATCH COURSE MELALUI CourseApiService
  // ===========================================================================
  Future<Course> updateCourse(
    Course course, {
    String? endpoint,
    bool usePatch = false,
  }) {
    return apiService.updateCourse(
      course,
      endpoint: endpoint,
      usePatch: usePatch,
    );
  }

  // ===========================================================================
  // TAHAP 8: METHOD HTTP DELETE COURSE MELALUI CourseApiService
  // ===========================================================================
  Future<bool> deleteCourse(int id, {String? endpoint}) {
    return apiService.deleteCourse(id, endpoint: endpoint);
  }
}
