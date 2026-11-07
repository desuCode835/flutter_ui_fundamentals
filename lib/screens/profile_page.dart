// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_page.dart';

// =============================================================================
// WORKSHEET 9 - PRAKTIK 3: PROFILE PAGE DENGAN INFORMASI USER & ROLE
// =============================================================================
// Menampilkan profil pengguna terautentikasi (Nama, Email, Role) dari database
// Supabase (tabel public.profiles) dengan penanganan loading, error, dan not found.
class ProfilePage extends StatefulWidget {
  final ProfileService? profileService;
  final AuthService? authService;

  const ProfilePage({super.key, this.profileService, this.authService});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileService _profileService;
  late final AuthService _authService;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileService = widget.profileService ?? ProfileService.instance;
    _authService = widget.authService ?? AuthService.instance;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _profile = null;
          _isLoading = false;
          _errorMessage = null;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getCurrentProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '').trim();
        _isLoading = false;
      });
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'instructor':
        return const Color(0xFF7C3AED); // Violet / Purple
      case 'admin':
        return const Color(0xFFDC2626); // Red
      case 'student':
      default:
        return const Color(0xFF0284C7); // Sky Blue
    }
  }

  Color _getRoleBackgroundColor(String role) {
    switch (role.toLowerCase()) {
      case 'instructor':
        return const Color(0xFFF5F3FF);
      case 'admin':
        return const Color(0xFFFEF2F2);
      case 'student':
      default:
        return const Color(0xFFF0F9FF);
    }
  }

  Widget _buildRoleBadge(String role) {
    final color = _getRoleColor(role);
    final bgColor = _getRoleBackgroundColor(role);

    IconData icon;
    switch (role.toLowerCase()) {
      case 'instructor':
        icon = Icons.cast_for_education_rounded;
        break;
      case 'admin':
        icon = Icons.admin_panel_settings_rounded;
        break;
      case 'student':
      default:
        icon = Icons.school_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            role.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupabaseAccountCard(BuildContext context) {
    final user = _authService.currentUser;
    final isAuthed = user != null;

    if (!isAuthed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.no_accounts_outlined, color: Colors.grey.shade600, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Mode Tamu (Belum Login)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'GUEST',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.login, size: 16),
                label: const Text('Masuk ke Akun'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 1. Kondisi Loading
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text(
                'Memuat profil pengguna dari Supabase...',
                style: TextStyle(fontSize: 13, color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Kondisi Error
    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Gagal Memuat Profil Pengguna',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _loadProfile,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => AuthService.logoutDialog(context, authService: _authService),
                  icon: const Icon(Icons.logout, size: 16, color: Color(0xFFDC2626)),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Ambil data profile atau fallback dari metadata user
    final profile = _profile;
    final meta = user.userMetadata;
    final displayName = profile?.name.isNotEmpty == true
        ? profile!.name
        : (meta?['name'] as String? ?? 'Nama belum diatur');
    final displayEmail = profile?.email.isNotEmpty == true
        ? profile!.email
        : (user.email ?? 'Email belum diatur');
    final displayRole = profile?.role.isNotEmpty == true
        ? profile!.role
        : (meta?['role'] as String? ?? 'student');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF1D4ED8),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Profil Akun Supabase',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              _buildRoleBadge(displayRole),
            ],
          ),
          const Divider(height: 22, thickness: 1, color: Color(0xFFDBEAFE)),

          // 1. Informasi Nama
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.badge_outlined, size: 17, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text(
                'Nama: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Informasi Email
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.email_outlined, size: 17, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text(
                'Email: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              Expanded(
                child: Text(
                  displayEmail,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E40AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3. Informasi Role
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, size: 17, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text(
                'Role: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              Text(
                displayRole.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _getRoleColor(displayRole),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tombol Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => AuthService.logoutDialog(context, authService: _authService),
              icon: const Icon(Icons.logout, size: 16, color: Color(0xFFDC2626)),
              label: const Text(
                'Keluar dari Akun (Logout)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final profile = _profile;
    final meta = user?.userMetadata;
    final headerName = profile?.name.isNotEmpty == true
        ? profile!.name
        : (meta?['name'] as String? ?? 'Gede Supadma');
    final headerRole = profile?.roleDisplay ??
        ((meta?['role'] as String?)?.toUpperCase() ?? 'STUDENT');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Profil',
            onPressed: _loadProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => AuthService.logoutDialog(context, authService: _authService),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFBBDEFB),
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            const SizedBox(height: 12),
            Text(
              headerName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('NIM: 2415051014 • Peran: $headerRole'),
            const SizedBox(height: 20),
            _buildSupabaseAccountCard(context),
            const SizedBox(height: 24),
            const FeedbackForm(),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// FEEDBACK FORM
// ======================================================

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController(
    text: 'Gede Supadma',
  );

  final TextEditingController nimController = TextEditingController(
    text: '2415051014',
  );

  final TextEditingController komentarController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    komentarController.dispose();
    super.dispose();
  }

  void submitFeedback() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin mengirim feedback?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                saveFeedback();
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // TAHAP 15 - KASUS D: PENGUJIAN ASYNC & MOUNTED CHECK
  // ===========================================================================
  Future<void> saveFeedback() async {
    setState(() {
      isLoading = true;
    });

    debugPrint('[DEBUG - Kasus D] saveFeedback: Operasi async dimulai...');
    await Future.delayed(const Duration(seconds: 2));

    // Pengecekan apakah widget masih terpasang pada widget tree setelah async
    if (!mounted) {
      debugPrint(
        '[DEBUG - Kasus D] Widget unmounted, setState dibatalkan demi keamanan.',
      );
      return;
    }

    debugPrint(
      '[DEBUG - Kasus D] Widget mounted, memanggil setState() untuk mematikan loading.',
    );
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feedback berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: namaController,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama wajib diisi';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nimController,
            decoration: const InputDecoration(
              labelText: 'NIM',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'NIM wajib diisi';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: komentarController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Komentar',
              hintText: 'Minimal 5 karakter',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.comment),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Komentar wajib diisi';
              }

              if (value.trim().length < 5) {
                return 'Komentar minimal 5 karakter';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Menyimpan feedback...'),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: submitFeedback,
              icon: const Icon(Icons.send),
              label: const Text('Kirim Feedback'),
            ),
        ],
      ),
    );
  }
}
