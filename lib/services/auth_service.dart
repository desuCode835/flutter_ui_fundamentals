// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================================================
// WORKSHEET 9 - PRAKTIK 1: AUTHENTICATION SERVICE (AuthService)
// =============================================================================
// Mengelola proses autentikasi (Registrasi, Login, State Pengguna)
// menggunakan Supabase Auth client dengan pemisahan logika yang bersih dari UI.
class AuthService {
  final SupabaseClient? _customClient;

  AuthService({SupabaseClient? client}) : _customClient = client;

  /// Instance SupabaseClient yang aktif
  SupabaseClient get client => _customClient ?? Supabase.instance.client;

  /// Pengguna (User) yang sedang aktif terautentikasi
  User? get currentUser => client.auth.currentUser;

  /// Session aktif saat ini
  Session? get currentSession => client.auth.currentSession;

  /// Status apakah ada pengguna yang sedang login
  bool get isLoggedIn => currentUser != null;

  /// Mendaftarkan pengguna baru dengan email dan password ke Supabase Auth
  Future<AuthResponse> register(String email, String password) async {
    debugPrint('[AuthService] Melakukan registrasi untuk email: $email');
    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      debugPrint(
        '[AuthService] Registrasi berhasil diproses. User ID: ${response.user?.id}, Session: ${response.session != null ? "Tersedia" : "Menunggu konfirmasi email"}',
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('[AuthService] AuthException saat register: ${e.message} (status: ${e.statusCode})');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Exception umum saat register: $e');
      rethrow;
    }
  }

  /// Masuk dengan email dan password ke Supabase Auth
  Future<AuthResponse> login(String email, String password) async {
    debugPrint('[AuthService] Melakukan login untuk email: $email');
    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint(
        '[AuthService] Login berhasil! User ID: ${response.user?.id}, Email: ${response.user?.email}',
      );
      return response;
    } on AuthException catch (e) {
      debugPrint('[AuthService] AuthException saat login: ${e.message} (status: ${e.statusCode})');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Exception umum saat login: $e');
      rethrow;
    }
  }

  /// Keluar dari sesi Supabase Auth
  Future<void> signOut() async {
    debugPrint('[AuthService] Melakukan signOut...');
    try {
      await client.auth.signOut();
      debugPrint('[AuthService] signOut berhasil.');
    } catch (e) {
      debugPrint('[AuthService] Exception saat signOut: $e');
      rethrow;
    }
  }
}

