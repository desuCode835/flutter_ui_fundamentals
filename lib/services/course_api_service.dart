// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/course.dart';

// =============================================================================
// TAHAP 4: SERVICE LAYER REST API (CourseApiService)
// =============================================================================
// Bertanggung jawab melakukan request HTTP ke REST API dan memparsing respons JSON
// menjadi List<Course> menggunakan Course.fromJson().
class CourseApiService {
  // Endpoint utama yang benar dan berfungsi (JSONPlaceholder Posts)
  static const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  final http.Client _client;

  CourseApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data dari REST API dan mengubah respons JSON menjadi `List<Course>`.
  /// Menerima parameter opsional [endpoint] untuk memfasilitasi pengujian error.
  Future<List<Course>> fetchPosts({String? endpoint}) async {
    final targetUrl = endpoint ?? apiUrl;
    debugPrint('[TAHAP 4 - CourseApiService] Memulai HTTP GET ke: $targetUrl');

    try {
      final response = await _client.get(Uri.parse(targetUrl));

      // 1. Periksa response.statusCode sebelum memproses response
      if (response.statusCode == 200) {
        // 2. Parsing respons JSON menggunakan jsonDecode
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;

        // 3. Konversi setiap item JSON menjadi objek Course via Course.fromJson
        final List<Course> posts = jsonList
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint(
          '[TAHAP 4 - CourseApiService] Berhasil memparsing ${posts.length} Course dari REST API',
        );
        return posts;
      } else {
        final errorMessage =
            '[TAHAP 4 - CourseApiService] Gagal mengambil data. Status Code: ${response.statusCode} (${response.reasonPhrase ?? 'Error'})';
        debugPrint(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint(
        '[TAHAP 4 - CourseApiService] Terjadi kesalahan saat HTTP GET: $e',
      );
      rethrow;
    }
  }
}
