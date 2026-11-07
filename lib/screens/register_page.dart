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

// =============================================================================
// WORKSHEET 9 - PRAKTIK 1: REGISTER PAGE
// =============================================================================
// Halaman registrasi akun baru dengan Supabase Auth: input email, password,
// konfirmasi password, validasi lengkap, penanganan session / verifikasi email,
// dan visual UI profesional yang konsisten dengan LoginPage.
class RegisterPage extends StatefulWidget {
  final AuthService? authService;

  const RegisterPage({super.key, this.authService});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late final AuthService _authService;

  String _selectedRole = 'student';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // VALIDASI FORM
  // ===========================================================================
  String? _validateName(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != _passwordController.text) {
      return 'Konfirmasi password tidak cocok dengan password di atas';
    }
    return null;
  }

  // ===========================================================================
  // PROSES REGISTRASI DENGAN SUPABASE AUTH
  // ===========================================================================
  Future<void> _handleRegister() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final rawName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final name = rawName.isNotEmpty ? rawName : email.split('@').first;
    final password = _passwordController.text;
    final role = _selectedRole;

    try {
      final response = await _authService.register(
        email,
        password,
        name: name,
        role: role,
      );

      if (!mounted) return;

      // Evaluasi hasil registrasi berdasarkan perilaku Supabase
      // Periksa apakah session langsung tersedia atau memerlukan konfirmasi email
      if (response.session != null) {
        // Pengguna langsung terautentikasi (auto-confirm aktif di Supabase)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Akun berhasil dibuat dan aktif! Mengalihkan ke Home...',
                  ),
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

        // Arahkan ke halaman utama Course Explorer
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ResponsiveShell()),
          (route) => false,
        );
      } else {
        // Session null: Supabase mengharuskan konfirmasi email
        setState(() {
          _successMessage =
              'Registrasi berhasil! Tautan konfirmasi telah dikirimkan ke $email. '
              'Silakan buka email Anda dan lakukan konfirmasi sebelum login.';
        });

        // Tampilkan dialog informasi
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    color: Color(0xFF1D4ED8),
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Konfirmasi Email',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akun untuk $email berhasil didaftarkan di Supabase Auth.',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Supabase telah mengirimkan email verifikasi. '
                    'Silakan periksa kotak masuk (inbox) atau folder spam Anda, '
                    'lalu klik tautan verifikasi sebelum melakukan login.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Tutup dialog
                    Navigator.pop(context); // Kembali ke halaman Login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Kembali ke Halaman Login'),
                ),
              ],
            );
          },
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      String message;
      final raw = e.message.toLowerCase();
      if (raw.contains('already registered') ||
          raw.contains('already in use') ||
          raw.contains('user already exists')) {
        message =
            'Email tersebut sudah terdaftar di Supabase Auth. Silakan masuk menggunakan akun tersebut atau gunakan email lain.';
      } else if (raw.contains('password should be at least')) {
        message = 'Password tidak memenuhi kriteria keamanan: minimal 6 karakter.';
      } else if (raw.contains('signup requires a valid password')) {
        message = 'Password tidak valid. Pastikan password tidak kosong.';
      } else {
        message = e.message;
      }

      setState(() {
        _errorMessage = message;
      });
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Tidak ada koneksi internet. Pastikan perangkat terhubung ke internet lalu coba lagi.';
      });
    } catch (e) {
      if (!mounted) return;
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socketexception') ||
          errStr.contains('clientexception') ||
          errStr.contains('failed host lookup')) {
        setState(() {
          _errorMessage =
              'Gagal menghubungi server Supabase. Pastikan koneksi internet aktif.';
        });
      } else {
        setState(() {
          _errorMessage = 'Terjadi kesalahan saat registrasi: ${e.toString()}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          title: 'Buat Akun Baru',
                          subtitle:
                              'Daftarkan email Anda untuk mulai mengelola kursus di Course Explorer.',
                        ),
                        const SizedBox(height: 20),

                        // Error Banner
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

                        // Success Banner
                        if (_successMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFF15803D),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
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
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          validator: _validatePassword,
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
                        const SizedBox(height: 16),

                        // Input Konfirmasi Password
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Konfirmasi Password',
                          hintText: 'Ulangi password di atas',
                          prefixIcon: Icons.lock_reset_rounded,
                          obscureText: !_isConfirmPasswordVisible,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          validator: _validateConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF64748B),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Nama Lengkap
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Nama Lengkap',
                          hintText: 'Contoh: Gede Supadma',
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.done,
                          enabled: !_isLoading,
                          validator: _validateName,
                          onFieldSubmitted: (_) => _handleRegister(),
                        ),
                        // Pilihan Peran Akun (Role: Student vs Instructor)
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pilih Peran Akun',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                key: const Key('role_student'),
                                title: 'Student',
                                subtitle: 'Mahasiswa / Siswa',
                                icon: Icons.school_outlined,
                                isSelected: _selectedRole == 'student',
                                onTap: !_isLoading
                                    ? () => setState(() => _selectedRole = 'student')
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleCard(
                                key: const Key('role_instructor'),
                                title: 'Instructor',
                                subtitle: 'Pengajar / Dosen',
                                icon: Icons.cast_for_education_outlined,
                                isSelected: _selectedRole == 'instructor',
                                onTap: !_isLoading
                                    ? () => setState(() => _selectedRole = 'instructor')
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Tombol Register
                        PrimaryButton(
                          text: 'Daftar Akun Baru',
                          icon: Icons.person_add_alt_1_rounded,
                          isLoading: _isLoading,
                          onPressed: _handleRegister,
                        ),
                        const SizedBox(height: 20),

                        // Navigasi Kembali ke Login
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Sudah memiliki akun? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text(
                                'Masuk di sini',
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

// =============================================================================
// PRAKTIK 3: KARTU PILIHAN PERAN (ROLE CARD)
// =============================================================================
class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF64748B),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
