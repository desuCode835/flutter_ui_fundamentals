// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/course.dart';
import 'course_api_service.dart';

// =============================================================================
// SERVICE LAYER: LOCAL DATA (CourseService)
// =============================================================================
// Bertanggung jawab membaca data aset JSON lokal (student_data.json).
// Komunikasi REST API telah dipisahkan ke CourseApiService (Tahap 4).
class CourseService {
  // Referensi apiUrl yang mengarah ke CourseApiService
  static const String apiUrl = CourseApiService.apiUrl;

  final CourseApiService _apiService;

  CourseService({CourseApiService? apiService})
    : _apiService = apiService ?? CourseApiService();

  /// Forwarder fetchPosts ke CourseApiService untuk kompatibilitas
  Future<List<Course>> fetchPosts({String? endpoint}) {
    return _apiService.fetchPosts(endpoint: endpoint);
  }

  /// Forwarder createCourse ke CourseApiService untuk kompatibilitas
  Future<Course> createCourse(Course course, {String? endpoint}) {
    return _apiService.createCourse(course, endpoint: endpoint);
  }

  // ===========================================================================
  // TAHAP 15 - KASUS C: DEBUGGING PATH ASSET JSON
  // ===========================================================================
  Future<List<Course>> loadCourses() async {
    const assetPath = 'assets/data/student_data.json';
    debugPrint('[DEBUG - Kasus C] CourseService: Membaca file dari $assetPath');

    final jsonString = await rootBundle.loadString(assetPath);

    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final list = data['courses'] as List<dynamic>;

    final courses = list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();

    debugPrint(
      '[DEBUG - Kasus C] CourseService: Berhasil parsing ${courses.length} courses dari JSON',
    );
    return courses;
  }
}
