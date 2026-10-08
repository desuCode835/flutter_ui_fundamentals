// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';

class CourseService {
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

    debugPrint('[DEBUG - Kasus C] CourseService: Berhasil parsing ${courses.length} courses dari JSON');
    return courses;
  }
}
