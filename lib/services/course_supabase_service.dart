// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';

// =============================================================================
// TAHAP 12–17: SERVICE LAYER SUPABASE (CourseSupabaseService)
// =============================================================================
// Bertanggung jawab berkomunikasi dengan database Supabase (tabel courses)
// menggunakan SupabaseClient dengan perlindungan keamanan, validasi data,
// penanganan RLS (Kasus D), dan validasi invalid/duplicate data (Kasus E).
class CourseSupabaseService {
  final SupabaseClient? _customClient;

  CourseSupabaseService({SupabaseClient? client}) : _customClient = client;

  /// Supabase client yang digunakan oleh service
  SupabaseClient get client => _customClient ?? Supabase.instance.client;

  /// Validasi integritas data model Course sebelum dikirim ke database Supabase (Kasus E)
  void validateCourse(Course course, {bool isUpdate = false}) {
    if (course.code.trim().isEmpty) {
      throw ArgumentError('Kode course wajib diisi dan tidak boleh kosong.');
    }
    if (course.title.trim().isEmpty) {
      throw ArgumentError('Judul course wajib diisi dan tidak boleh kosong.');
    }
    if (course.credits <= 0) {
      throw ArgumentError('Jumlah SKS (credits) harus berupa angka bulat > 0.');
    }

    const allowedStatuses = {'planned', 'active', 'done'};
    if (!allowedStatuses.contains(course.status.toLowerCase().trim())) {
      throw ArgumentError(
        'Status course ("${course.status}") tidak valid. Nilai yang diizinkan: active, planned, done.',
      );
    }

    if (isUpdate && (course.id == null || course.id! <= 0)) {
      throw ArgumentError(
        'ID course wajib tersedia untuk melakukan UPDATE di Supabase.',
      );
    }
  }

  /// Menerjemahkan error Postgrest, RLS, jaringan, atau validasi menjadi Exception informatif (Kasus D & E)
  Never _handleError(Object error, String action) {
    if (error is ArgumentError) {
      debugPrint(
        '[TAHAP 17 - CourseSupabaseService] Validasi gagal saat $action: ${error.message}',
      );
      throw Exception(error.message.toString());
    }

    if (error is PostgrestException) {
      debugPrint(
        '[TAHAP 17 - CourseSupabaseService] PostgrestException saat $action: '
        'code=${error.code}, message=${error.message}, details=${error.details}',
      );

      // Kasus D: Error permission / Row Level Security (RLS)
      if (error.code == '42501' ||
          error.message.toLowerCase().contains('row-level security') ||
          error.message.toLowerCase().contains('permission denied')) {
        final msg =
            'Akses database ditolak oleh kebijakan keamanan RLS (Row Level Security). Operasi $action tidak diizinkan.';
        throw Exception(msg);
      }

      // Kasus E: Duplicate key / unique constraint violation
      if (error.code == '23505' ||
          error.message.toLowerCase().contains('unique') ||
          error.message.toLowerCase().contains('duplicate')) {
        final msg =
            'Data duplikat: Course dengan kode tersebut sudah terdaftar di database Supabase.';
        throw Exception(msg);
      }

      // Kasus E: Check constraint violation (misal status invalid di level database)
      if (error.code == '23514' ||
          error.message.toLowerCase().contains('check constraint')) {
        final msg =
            'Data tidak valid: Nilai field melanggar batasan tabel database (status harus planned/active/done atau SKS > 0).';
        throw Exception(msg);
      }

      throw Exception(
        'Kesalahan database Supabase (${error.code ?? "PostgreSQL"}): ${error.message}',
      );
    }

    final errStr = error.toString();
    if (errStr.contains('SocketException') ||
        errStr.contains('Failed host lookup') ||
        errStr.contains('ClientException') ||
        errStr.contains('Connection refused')) {
      final msg =
          'Gagal terhubung ke database Supabase saat $action. Periksa koneksi internet Anda lalu coba lagi.';
      debugPrint('[TAHAP 17 - CourseSupabaseService] $msg');
      throw Exception(msg);
    }

    if (error is FormatException) {
      final msg =
          'Format data respons dari database tidak valid saat $action: ${error.message}';
      debugPrint('[TAHAP 17 - CourseSupabaseService] $msg');
      throw Exception(msg);
    }

    debugPrint(
      '[TAHAP 17 - CourseSupabaseService] Terjadi kesalahan saat $action: $error',
    );
    throw error is Exception ? error : Exception(error.toString());
  }

  /// Membaca daftar course dari tabel `courses` di Supabase dan mengurutkannya berdasarkan `id`.
  Future<List<Course>> getCourses() async {
    debugPrint(
      '[TAHAP 12 - CourseSupabaseService] Membaca tabel courses dari Supabase...',
    );

    try {
      final response = await client.from('courses').select().order('id');

      final List<Course> courses = (response as List<dynamic>)
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint(
        '[TAHAP 12 - CourseSupabaseService] Berhasil membaca ${courses.length} courses dari Supabase',
      );
      return courses;
    } catch (e) {
      _handleError(e, 'membaca daftar course dari Supabase');
    }
  }

  /// Menambahkan course baru ke tabel `courses` di Supabase.
  Future<void> createCourse(Course course) async {
    // Validasi data sebelum dikirim ke database (Kasus E)
    validateCourse(course);

    debugPrint(
      '[TAHAP 13 - CourseSupabaseService] Menambahkan course ke Supabase: ${course.code} - ${course.title}',
    );

    try {
      await client.from('courses').insert(course.toJson());
      debugPrint(
        '[TAHAP 13 - CourseSupabaseService] Berhasil menambahkan course ke Supabase',
      );
    } catch (e) {
      _handleError(e, 'menambahkan course ke Supabase');
    }
  }

  /// Memperbarui data course di tabel `courses` di Supabase berdasarkan `id`.
  /// Menyimpan perubahan title, credits, dan status.
  Future<void> updateCourse(Course course, {int? id}) async {
    final targetId = id ?? course.id;
    final courseToValidate = course.copyWith(id: targetId);

    // Validasi data sebelum dikirim ke database (Kasus E)
    validateCourse(courseToValidate, isUpdate: true);

    debugPrint(
      '[TAHAP 14 - CourseSupabaseService] Memperbarui course ID $targetId di Supabase...',
    );

    try {
      await client
          .from('courses')
          .update({
            'title': course.title,
            'credits': course.credits,
            'status': course.status,
          })
          .eq('id', targetId!);

      debugPrint(
        '[TAHAP 14 - CourseSupabaseService] Berhasil memperbarui course ID $targetId di Supabase: ${course.title}',
      );
    } catch (e) {
      _handleError(e, 'memperbarui course di Supabase');
    }
  }

  /// Menghapus data course dari tabel `courses` di Supabase berdasarkan `id`.
  Future<void> deleteCourse(int id) async {
    if (id <= 0) {
      throw ArgumentError('ID course tidak valid untuk penghapusan: $id');
    }

    debugPrint(
      '[TAHAP 15 - CourseSupabaseService] Menghapus course ID $id dari Supabase...',
    );

    try {
      await client.from('courses').delete().eq('id', id);
      debugPrint(
        '[TAHAP 15 - CourseSupabaseService] Berhasil menghapus course ID $id dari Supabase',
      );
    } catch (e) {
      _handleError(e, 'menghapus course dari Supabase');
    }
  }
}
