// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

// =============================================================================
// WORKSHEET 9 - PRAKTIK 3: SERVICE LAYER PROFILE (ProfileService)
// =============================================================================
// Bertanggung jawab mengambil data profil pengguna dari tabel database Supabase
// `public.profiles` dengan pemisahan logika yang bersih dari tampilan widget UI.
class ProfileService {
  static ProfileService _instance = ProfileService();
  static ProfileService get instance => _instance;

  @visibleForTesting
  static set instance(ProfileService service) => _instance = service;

  final SupabaseClient? _customClient;
  UserProfile? _cachedProfile;

  ProfileService({SupabaseClient? client}) : _customClient = client;

  /// Profil pengguna terakhir yang berhasil dimuat dari database.
  /// Otomatis memvalidasi bahwa cache sesuai dengan user autentikasi aktif saat ini.
  UserProfile? get cachedProfile {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null ||
          (currentUserId.isNotEmpty && _cachedProfile?.id != currentUserId)) {
        _cachedProfile = null;
      }
    } catch (_) {}
    return _cachedProfile;
  }

  /// Mengatur cache profil secara manual (misal untuk testing)
  @visibleForTesting
  set cachedProfile(UserProfile? profile) => _cachedProfile = profile;

  /// Membersihkan cache profil (misalnya saat logout atau pergantian akun)
  void clearCache() {
    _cachedProfile = null;
  }

  /// Mengambil role pengguna aktif secara sinkron jika profil sudah berada di cache.
  /// Mengembalikan null jika belum dimuat agar caller dapat menampilkan status loading
  /// dan TIDAK melakukan fallback ke 'student' secara prematur.
  String? get currentUserRoleSync {
    final profile = cachedProfile;
    if (profile != null && profile.role.isNotEmpty) {
      return profile.role;
    }
    return null;
  }

  /// Mengambil role pengguna aktif secara asinkron dari tabel profiles.
  /// Mengembalikan null jika pengguna belum login atau profil gagal dimuat.
  Future<String?> getCurrentUserRole() async {
    try {
      final profile = await getCurrentProfile();
      if (profile != null && profile.role.isNotEmpty) {
        return profile.role;
      }
    } catch (e) {
      debugPrint('[ProfileService] Error saat mengambil role: $e');
    }
    return cachedProfile?.role;
  }

  /// Instance SupabaseClient yang aktif
  SupabaseClient get client => _customClient ?? Supabase.instance.client;

  /// Mengambil profil pengguna yang sedang login dari tabel Supabase `profiles`
  /// berdasarkan ID akun autentikasi aktif saat ini.
  Future<UserProfile?> getCurrentProfile() async {
    User? user;
    try {
      user = client.auth.currentUser;
    } catch (e) {
      debugPrint('[ProfileService] Supabase client belum diinisialisasi atau error: $e');
      return null;
    }

    if (user == null) {
      debugPrint('[ProfileService] Tidak ada user aktif yang sedang terautentikasi.');
      _cachedProfile = null;
      return null;
    }

    final profile = await getProfileById(user.id, fallbackEmail: user.email);
    if (profile != null) {
      _cachedProfile = profile;
    }
    return profile;
  }

  /// Mengambil data profil dari tabel `profiles` berdasarkan user ID (UUID)
  Future<UserProfile?> getProfileById(
    String userId, {
    String? fallbackEmail,
  }) async {
    debugPrint('[ProfileService] Mengambil profil dari tabel profiles untuk ID: $userId');
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint(
          '[ProfileService] Baris profil belum tersedia di tabel profiles untuk user ID: $userId',
        );

        // Jika row belum terbuat oleh trigger, gunakan fallback dari auth user metadata
        final currentUser = client.auth.currentUser;
        if (currentUser != null && currentUser.id == userId) {
          final meta = currentUser.userMetadata;
          final metaName = meta?['name'] as String?;
          final metaRole = meta?['role'] as String?;
          if (metaName != null || metaRole != null) {
            return UserProfile(
              id: userId,
              email: fallbackEmail ?? currentUser.email ?? '',
              name: metaName ?? '',
              role: metaRole ?? 'student',
            );
          }
        }
        return null;
      }

      final profile = UserProfile.fromJson(response);
      debugPrint(
        '[ProfileService] Berhasil memuat profil: Name="${profile.name}", Role="${profile.role}", Email="${profile.email}"',
      );
      return profile;
    } on PostgrestException catch (e) {
      debugPrint('[ProfileService] PostgrestException saat membaca tabel profiles: ${e.message} (code: ${e.code})');
      rethrow;
    } catch (e) {
      debugPrint('[ProfileService] Kesalahan saat membaca tabel profiles: $e');
      rethrow;
    }
  }
}

