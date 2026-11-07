// Nama : Gede Supadma
// NIM : 2415051014

// =============================================================================
// WORKSHEET 9 - PRAKTIK 3: MODEL USER PROFILE (UserProfile)
// =============================================================================
// Merepresentasikan data profil pengguna yang tersimpan di tabel `public.profiles`
// pada database Supabase dengan kolom id, email, name, dan role.
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'student',
  });

  /// Factory constructor untuk memetakan respons JSON/Map dari tabel Supabase `profiles`
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: (json['role'] as String? ?? 'student').toLowerCase().trim(),
    );
  }

  /// Mengonversi objek UserProfile ke dalam Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  /// Helper untuk menyalin instance UserProfile dengan pembaruan sebagian data
  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  /// Helper untuk memeriksa hak akses berdasarkan peran pengguna
  bool get isStudent => role == 'student';
  bool get isInstructor => role == 'instructor';
  bool get isAdmin => role == 'admin';

  /// Label peran yang ramah pengguna untuk ditampilkan pada antarmuka UI
  String get roleDisplay {
    switch (role) {
      case 'instructor':
        return 'Instructor';
      case 'admin':
        return 'Admin';
      case 'student':
      default:
        return 'Student';
    }
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, name, role);
  }
}

