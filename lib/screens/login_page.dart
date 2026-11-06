// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'register_page.dart';

// =============================================================================
// WORKSHEET 9 - PRAKTIK 1: LOGIN PAGE
// =============================================================================
// Halaman login profesional dengan integrasi Supabase Auth, validasi form,
// status loading, toggle password visibility, penanganan error, dan navigasi.
class LoginPage extends StatefulWidget {
  final AuthService? authService;

  const LoginPage({super.key, this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AuthService _authService;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // VALIDASI FORM
  // ===========================================================================
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid (contoh: user@domain.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // ===========================================================================
  // PROSES LOGIN DENGAN SUPABASE AUTH
  // ===========================================================================
  Future<void> _handleLogin() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await _authService.login(email, password);

      if (!mounted) return;

      // Berhasil login
      final userEmail = response.user?.email ?? email;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Selamat datang, $userEmail! Login berhasil.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigasi ke halaman utama Course Explorer (ResponsiveShell)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ResponsiveShell(),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      String message;
      final raw = e.message.toLowerCase();
      if (raw.contains('invalid login credentials') ||
          raw.contains('invalid credentials')) {
        message = 'Email atau password salah. Periksa kembali kredensial Anda.';
      } else if (raw.contains('email not confirmed')) {
        message = 'Email belum diverifikasi. Silakan buka inbox/spam email Anda untuk verifikasi akun.';
      } else if (raw.contains('too many requests')) {
        message = 'Terlalu banyak percobaan masuk. Tunggu beberapa saat lalu coba lagi.';
      } else {
        message = e.message;
      }

      setState(() {
        _errorMessage = message;
      });
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.';
      });
    } catch (e) {
      if (!mounted) return;
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socketexception') ||
          errStr.contains('clientexception') ||
          errStr.contains('failed host lookup')) {
        setState(() {
          _errorMessage = 'Gagal menghubungi server Supabase. Pastikan koneksi internet aktif.';
        });
      } else {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(authService: _authService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Branding & Header
                        const AuthHeader(
                          title: 'Masuk ke Akun',
                          subtitle:
                              'Masukkan kredensial Supabase Anda untuk mengakses Course Explorer.',
                        ),
                        const SizedBox(height: 20),

                        // Error Alert Card jika login gagal
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFB91C1C),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _errorMessage = null),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Input Email
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Alamat Email',
                          hintText: 'nama@example.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          enabled: !_isLoading,
                          validator: _validatePassword,
                          onFieldSubmitted: (_) => _handleLogin(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF64748B),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol Login
                        PrimaryButton(
                          text: 'Masuk Sekarang',
                          icon: Icons.login_rounded,
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'atau',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Link ke RegisterPage
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Belum memiliki akun? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isLoading ? null : _navigateToRegister,
                              child: const Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
