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

      final List<Course> courses = response
          .map((json) => Course.fromJson(json))
          .toList();

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

  //Nama : Gede Supadma
  //NIM : 2415051014
  // ===========================================================================
  // TAHAP 13: INSERT — MENAMBAH DATA KE DATABASE SUPABASE
  // ===========================================================================
  /// Menambahkan course baru ke tabel `courses` di Supabase.
  Future<void> createCourse(Course course) async {
    debugPrint(
      '[TAHAP 13 - CourseSupabaseService] Menambahkan course ke Supabase: ${course.code} - ${course.title}',
    );

    try {
      await client.from('courses').insert(course.toJson());
      debugPrint(
        '[TAHAP 13 - CourseSupabaseService] Berhasil menambahkan course ke Supabase',
      );
    } catch (e) {
      debugPrint(
        '[TAHAP 13 - CourseSupabaseService] Terjadi kesalahan saat insert course ke Supabase: $e',
      );
      rethrow;
    }
  }

  // Nama : Gede Supadma
  // NIM : 2415051014
  // ===========================================================================
  // TAHAP 14: UPDATE — MENGUBAH DATA DI DATABASE SUPABASE
  // ===========================================================================
  /// Memperbarui data course di tabel `courses` di Supabase berdasarkan `id`.
  /// Menyimpan perubahan title, credits, dan status.
  Future<void> updateCourse(Course course, {int? id}) async {
    final targetId = id ?? course.id;
    if (targetId == null) {
      throw Exception(
        'ID course wajib tersedia untuk melakukan UPDATE di Supabase',
      );
    }

    debugPrint(
      '[TAHAP 14 - CourseSupabaseService] Memperbarui course ID $targetId di Supabase...',
    );

    try {
      await client.from('courses').update({
        'title': course.title,
        'credits': course.credits,
        'status': course.status,
      }).eq('id', targetId);

      debugPrint(
        '[TAHAP 14 - CourseSupabaseService] Berhasil memperbarui course ID $targetId di Supabase: ${course.title}',
      );
    } catch (e) {
      debugPrint(
        '[TAHAP 14 - CourseSupabaseService] Terjadi kesalahan saat update course di Supabase: $e',
      );
      rethrow;
    }
  }
}
