// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';

// =============================================================================
// TAHAP 12: SERVICE LAYER SUPABASE (CourseSupabaseService)
// =============================================================================
// Bertanggung jawab membaca data dari database Supabase (tabel courses)
// menggunakan Supabase.instance.client.
class CourseSupabaseService {
  final SupabaseClient _client;

  CourseSupabaseService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Supabase client yang digunakan oleh service
  SupabaseClient get client => _client;

  /// Membaca daftar course dari tabel `courses` di Supabase dan mengurutkannya berdasarkan `id`.
  Future<List<Course>> getCourses() async {
    debugPrint(
      '[TAHAP 12 - CourseSupabaseService] Membaca tabel courses dari Supabase...',
    );

    try {
      final response = await client.from('courses').select().order('id');

      final List<Course> courses =
          response.map((json) => Course.fromJson(json)).toList();

      debugPrint(
        '[TAHAP 12 - CourseSupabaseService] Berhasil membaca ${courses.length} courses dari Supabase',
      );
      return courses;
    } catch (e) {
      debugPrint(
        '[TAHAP 12 - CourseSupabaseService] Terjadi kesalahan saat membaca courses dari Supabase: $e',
      );
      rethrow;
    }
  }
}
