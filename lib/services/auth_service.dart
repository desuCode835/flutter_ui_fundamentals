// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/login_page.dart';

// =============================================================================
// WORKSHEET 9 - PRAKTIK 1 & 2: AUTHENTICATION SERVICE (AuthService)
// =============================================================================
// Mengelola proses autentikasi (Registrasi, Login, Logout, Session Checking)
// menggunakan Supabase Auth client dengan pemisahan logika yang bersih dari UI.
class AuthService {
  /// Singleton / shared instance untuk kemudahan akses session di seluruh aplikasi
  static AuthService _instance = AuthService();
  static AuthService get instance => _instance;

  @visibleForTesting
  static set instance(AuthService service) => _instance = service;

  final SupabaseClient? _customClient;

  AuthService({SupabaseClient? client}) : _customClient = client;

  /// Instance SupabaseClient yang aktif
  SupabaseClient get client => _customClient ?? Supabase.instance.client;

  /// Pengguna (User) yang sedang aktif terautentikasi
  User? get currentUser {
    try {
      return client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Session aktif saat ini
  Session? get currentSession {
    try {
      return client.auth.currentSession;
    } catch (_) {
      return null;
    }
  }

  /// Status apakah ada pengguna yang sedang login dengan sesi aktif dan valid
  bool get isLoggedIn {
    try {
      final session = currentSession;
      if (session == null) return false;
      if (session.isExpired) return false;
      return currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Stream perubahan status autentikasi (SIGNED_IN, SIGNED_OUT, dll.)
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;

  /// Mendaftarkan pengguna baru dengan email, password, name, dan role ke Supabase Auth.
  /// Mengirimkan metadata 'name' dan 'role' dalam payload `data` agar dibaca
  /// oleh fungsi trigger database `handle_new_user()` pada tabel `public.profiles`.
  Future<AuthResponse> register(
    String email,
    String password, {
    String? name,
    String role = 'student',
  }) async {
    final sanitizedRole = role.trim().toLowerCase();
    final metadata = <String, dynamic>{
      'role': sanitizedRole.isNotEmpty ? sanitizedRole : 'student',
    };
    if (name != null && name.trim().isNotEmpty) {
      metadata['name'] = name.trim();
    }

    debugPrint(
      '[AuthService] Melakukan registrasi untuk email: $email, role: ${metadata['role']}, name: ${metadata['name']}',
    );
    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: metadata,
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

  /// Keluar dari sesi Supabase Auth (Sign Out)
  Future<void> signOut() async {
    debugPrint('[AuthService] Melakukan signOut...');
    try {
      await client.auth.signOut();
      debugPrint('[AuthService] signOut berhasil. Sesi telah dihapus.');
    } catch (e) {
      debugPrint('[AuthService] Exception saat signOut: $e');
      rethrow;
    }
  }

  /// Alias method untuk kemudahan pemanggilan
  Future<void> logout() => signOut();

  // ===========================================================================
  // PRAKTIK 2: INTERAKTIF LOGOUT DENGAN KONFIRMASI, LOADING, & REDIRECT
  // ===========================================================================
  /// Menampilkan dialog konfirmasi logout dan menjalankan proses sign out.
  /// Menangani indikator loading, pesan error, serta navigasi pushAndRemoveUntil ke LoginPage.
  Future<void> handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun Supabase Anda?\n\n'
          'Sesi Anda akan dihapus dan Anda perlu login kembali untuk mengakses aplikasi.',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // Tampilkan loading dialog selama proses logout berlangsung
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingCtx) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 14),
                  Text(
                    'Memproses logout...',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      await signOut();

      if (!context.mounted) return;

      // Tutup loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Berhasil logout. Sesi Anda telah diakhiri.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Bersihkan seluruh riwayat navigasi dan kembali ke LoginPage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(authService: this),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      // Tutup loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text('Gagal logout: $e')),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  /// Helper statis untuk memicu dialog logout dari widget manapun
  static Future<void> logoutDialog(BuildContext context, {AuthService? authService}) {
    final auth = authService ?? AuthService.instance;
    return auth.handleLogout(context);
  }
}
