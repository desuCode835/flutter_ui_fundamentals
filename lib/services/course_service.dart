// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:convert';

import 'package:flutter/services.dart';
import '../models/course.dart';

class CourseService {
  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final list = data['courses'] as List<dynamic>;

    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
