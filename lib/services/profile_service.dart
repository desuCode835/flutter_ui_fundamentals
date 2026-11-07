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

  ProfileService({SupabaseClient? client}) : _customClient = client;

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
      return null;
    }

    return getProfileById(user.id, fallbackEmail: user.email);
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

