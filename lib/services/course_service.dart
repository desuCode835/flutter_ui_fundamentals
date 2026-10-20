// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/course.dart';

// =============================================================================
// TAHAP 2: KONSTANTA API URL (JSONPlaceholder Posts)
// =============================================================================
const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

class CourseService {
  // Konstanta apiUrl di dalam class CourseService
  static const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  // ===========================================================================
  // TAHAP 2 & 3: HTTP GET DARI FLUTTER & PARSING KE MODEL COURSE
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  Future<List<Course>> fetchPosts({String? endpoint}) async {
    final targetUrl = endpoint ?? apiUrl;
    debugPrint('[TAHAP 3] Memulai HTTP GET ke: $targetUrl');

    try {
      final response = await http.get(Uri.parse(targetUrl));

      // 3. Periksa response.statusCode sebelum memproses response
      if (response.statusCode == 200) {
        // 4. Jika status code 200, parsing JSON menggunakan jsonDecode
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;

        // Konversi setiap item JSON menjadi objek Course via Course.fromJson
        final List<Course> posts = jsonList
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();

        // 5. Cetak jumlah item yang berhasil diterima dan diparsing
        debugPrint(
          '[TAHAP 3] Berhasil memparsing ${posts.length} Course dari REST API',
        );
        return posts;
      } else {
        final errorMessage =
            '[TAHAP 3] Gagal mengambil data. Status Code: ${response.statusCode} (${response.reasonPhrase ?? 'Error'})';
        debugPrint(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('[TAHAP 3] Terjadi kesalahan saat HTTP GET: $e');
      rethrow;
    }
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
