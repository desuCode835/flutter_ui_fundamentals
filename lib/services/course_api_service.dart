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

  /// ===========================================================================
  /// TAHAP 6: HTTP POST — MEMBUAT RESOURCE BARU
  /// ===========================================================================
  /// Mengirim request HTTP POST menggunakan `http.post`, header `Content-Type: application/json; charset=UTF-8`,
  /// dan `jsonEncode` untuk payload.
  /// Menerima parameter opsional [endpoint] untuk pengujian skenario error.
  Future<Course> createCourse(Course course, {String? endpoint}) async {
    final targetUrl = endpoint ?? apiUrl;
    debugPrint('[TAHAP 6 - CourseApiService] Memulai HTTP POST ke: $targetUrl');

    final payload = {
      'title': course.title,
      'body': 'Kode: ${course.code} • SKS: ${course.credits}',
      'code': course.code,
      'credits': course.credits,
      'userId': course.userId ?? 1,
    };

    try {
      final response = await _client.post(
        Uri.parse(targetUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      );

      debugPrint(
        '[TAHAP 6 - CourseApiService] Response status: ${response.statusCode}',
      );

      // 4. Tangani respons berhasil dengan status 200 atau 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint('[TAHAP 6 - CourseApiService] POST Berhasil: $data');

        return Course(
          code: course.code,
          title: data['title'] as String? ?? course.title,
          credits: course.credits,
          status: 'active',
          id: (data['id'] as num?)?.toInt() ?? 101,
          userId: (data['userId'] as num?)?.toInt() ?? 1,
          body:
              data['body'] as String? ??
              'Kode: ${course.code} • SKS: ${course.credits}',
        );
      } else {
        final errorMessage =
            '[TAHAP 6 - CourseApiService] Gagal membuat resource. Status Code: ${response.statusCode} (${response.reasonPhrase ?? 'Error'})';
        debugPrint(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint(
        '[TAHAP 6 - CourseApiService] Terjadi kesalahan saat HTTP POST: $e',
      );
      rethrow;
    }
  }
}
