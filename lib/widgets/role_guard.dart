// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import '../services/auth_service.dart';

// =============================================================================
// WORKSHEET 9 - PRAKTIK 4: WIDGET ROLE GUARD (RoleGuard)
// =============================================================================
// Mengatur otorisasi UI berbasis peran pengguna (Role-Based UI Authorization).
// Widget menerima:
// - [userRole]: role pengguna saat ini (misal: 'student', 'instructor', 'admin').
// - [allowedRoles]: daftar role yang diizinkan mengakses komponen ini.
// - [child]: widget yang akan ditampilkan jika pengguna memiliki hak akses.
// - [fallback]: widget alternatif jika tidak berhak (default: const SizedBox.shrink()).
// - [isOwner]: flag kepemilikan opsional (misal: instructor hanya dapat edit/delete course miliknya).
class RoleGuard extends StatelessWidget {
  final String? userRole;
  final List<String> allowedRoles;
  final Widget child;
  final Widget fallback;
  final bool? isOwner;

  const RoleGuard({
    super.key,
    required this.userRole,
    required this.allowedRoles,
    required this.child,
    this.fallback = const SizedBox.shrink(),
    this.isOwner,
  });

  /// Memeriksa apakah [role] memenuhi daftar [allowed] secara case-insensitive
  static bool hasRole(String? role, List<String> allowed) {
    if (role == null || role.trim().isEmpty) return false;
    final normalized = role.trim().toLowerCase();
    return allowed.any((item) => item.trim().toLowerCase() == normalized);
  }

  /// Memeriksa apakah suatu aksi diizinkan berdasarkan role dan status kepemilikan
  static bool canPerformAction({
    required String? role,
    required List<String> allowedRoles,
    bool? isOwner,
  }) {
    if (role == null || role.trim().isEmpty) return false;
    final normalized = role.trim().toLowerCase();

    final matchesRole = allowedRoles.any(
      (item) => item.trim().toLowerCase() == normalized,
    );
    if (!matchesRole) return false;

    // Role admin memiliki hak akses penuh (ownership tidak membatasi admin)
    if (normalized == 'admin') {
      return true;
    }

    // Role instructor: jika aksi memerlukan verifikasi kepemilikan (isOwner != null)
    // Instructor HANYA boleh jika isOwner == true
    if (normalized == 'instructor' && isOwner != null) {
      return isOwner;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (canPerformAction(
      role: userRole,
      allowedRoles: allowedRoles,
      isOwner: isOwner,
    )) {
      return child;
    }
    return fallback;
  }
}

/// Helper untuk memeriksa apakah course dimiliki oleh pengguna tertentu.
/// Mengembalikan true hanya jika course memiliki informasi pembuat yang cocok dengan identitas pengguna.
/// Mengembalikan false jika kepemilikan tidak cocok, course lama belum memiliki user_id,
/// atau informasi pembuat tidak tersedia di database.
bool isCourseOwner(Course course, {String? userId, User? user}) {
  final activeUserId =
      userId ?? user?.id ?? AuthService.instance.currentUser?.id;
  if (activeUserId == null || activeUserId.trim().isEmpty) return false;

  // 1. Pengecekan utama kepemilikan database Supabase via UUID (supabaseUserId)
  if (course.supabaseUserId != null &&
      course.supabaseUserId!.trim().isNotEmpty) {
    return course.supabaseUserId!.trim().toLowerCase() ==
        activeUserId.trim().toLowerCase();
  }

  // 2. Legacy fallback untuk REST API jika userId integer cocok
  if (course.userId != null) {
    return course.userId.toString() == activeUserId.trim();
  }

  // 3. Course lama yang belum memiliki user_id ditangani secara aman (bukan milik siapa pun)
  return false;
}

