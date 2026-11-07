// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_ui_fundamentals/models/user_profile.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/profile_page.dart';
import 'package:flutter_ui_fundamentals/screens/register_page.dart';
import 'package:flutter_ui_fundamentals/services/auth_service.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_ui_fundamentals/services/profile_service.dart';

/// Fake AuthService untuk menguji Praktik 3 (User Roles)
class FakeRoleAuthService extends AuthService {
  String? lastRegisteredEmail;
  String? lastRegisteredPassword;
  String? lastRegisteredName;
  String? lastRegisteredRole;
  int registerCallCount = 0;
  bool returnSessionOnRegister = false;

  User? mockUser;

  FakeRoleAuthService({this.mockUser});

  @override
  User? get currentUser => mockUser;

  @override
  Future<AuthResponse> register(
    String email,
    String password, {
    String? name,
    String role = 'student',
  }) async {
    registerCallCount++;
    lastRegisteredEmail = email;
    lastRegisteredPassword = password;
    lastRegisteredName = name;
    lastRegisteredRole = role;

    final user = User(
      id: 'user-role-test-123',
      appMetadata: {},
      userMetadata: {
        'name': name ?? '',
        'role': role,
      },
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );

    return AuthResponse(
      session: returnSessionOnRegister
          ? Session(
              accessToken: 'fake_jwt_token',
              tokenType: 'bearer',
              user: user,
            )
          : null,
      user: user,
    );
  }
}

/// Fake ProfileService untuk menguji pengambilan profil dan penanganan error/loading
class FakeProfileService extends ProfileService {
  UserProfile? mockProfile;
  bool shouldThrow = false;
  int getProfileCallCount = 0;

  FakeProfileService({this.mockProfile, this.shouldThrow = false});

  @override
  Future<UserProfile?> getCurrentProfile() async {
    getProfileCallCount++;
    if (shouldThrow) {
      throw Exception('Gagal membaca tabel profiles dari Supabase');
    }
    return mockProfile;
  }

  @override
  Future<UserProfile?> getProfileById(String userId, {String? fallbackEmail}) async {
    getProfileCallCount++;
    if (shouldThrow) {
      throw Exception('Gagal membaca tabel profiles dari Supabase');
    }
    return mockProfile;
  }
}

void main() {
  late CourseProvider courseProvider;

  setUp(() {
    final repo = CourseRepository(
      CourseService(),
      CourseApiService(),
    );
    courseProvider = CourseProvider(repo);
  });

  Widget buildTestableWidget(Widget child) {
    return ChangeNotifierProvider<CourseProvider>.value(
      value: courseProvider,
      child: MaterialApp(home: child),
    );
  }

  group('Worksheet 9 Praktik 3 — Model UserProfile', () {
    test('1. UserProfile.fromJson memetakan data tabel profiles dengan benar', () {
      final json = {
        'id': 'uuid-123-supadma',
        'email': 'supadma@undiksha.ac.id',
        'name': 'Gede Supadma',
        'role': 'instructor',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'uuid-123-supadma');
      expect(profile.email, 'supadma@undiksha.ac.id');
      expect(profile.name, 'Gede Supadma');
      expect(profile.role, 'instructor');
      expect(profile.isInstructor, isTrue);
      expect(profile.isStudent, isFalse);
      expect(profile.isAdmin, isFalse);
      expect(profile.roleDisplay, 'Instructor');
    });

    test('2. UserProfile.toJson dan copyWith bekerja dengan benar', () {
      const profile = UserProfile(
        id: 'uuid-456',
        email: 'student@undiksha.ac.id',
        name: 'Mahasiswa Test',
        role: 'student',
      );

      final json = profile.toJson();
      expect(json['id'], 'uuid-456');
      expect(json['role'], 'student');
      expect(profile.isStudent, isTrue);

      final updated = profile.copyWith(name: 'Nama Baru', role: 'admin');
      expect(updated.name, 'Nama Baru');
      expect(updated.role, 'admin');
      expect(updated.isAdmin, isTrue);
      expect(updated.roleDisplay, 'Admin');
    });
  });

  group('Worksheet 9 Praktik 3 — Registrasi dengan User Roles', () {
    testWidgets('3. Registrasi default menggunakan role student dan mengirim metadata name & role', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = FakeRoleAuthService()..returnSessionOnRegister = true;

      await tester.pumpWidget(buildTestableWidget(
        RegisterPage(authService: fakeAuth),
      ));

      // Masukkan Email, Password, Konfirmasi Password, dan Nama
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final confirmField = find.byType(TextFormField).at(2);
      final nameField = find.byType(TextFormField).at(3);
      final registerButton = find.text('Daftar Akun Baru');

      await tester.enterText(emailField, 'student.baru@example.com');
      await tester.enterText(passwordField, 'rahasia123');
      await tester.enterText(confirmField, 'rahasia123');
      await tester.enterText(nameField, 'Gede Supadma Student');

      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi AuthService menerima metadata name dan role student
      expect(fakeAuth.registerCallCount, 1);
      expect(fakeAuth.lastRegisteredEmail, 'student.baru@example.com');
      expect(fakeAuth.lastRegisteredName, 'Gede Supadma Student');
      expect(fakeAuth.lastRegisteredRole, 'student');
    });

    testWidgets('4. Registrasi dengan role instructor saat kartu Instructor dipilih', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = FakeRoleAuthService()..returnSessionOnRegister = true;

      await tester.pumpWidget(buildTestableWidget(
        RegisterPage(authService: fakeAuth),
      ));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final confirmField = find.byType(TextFormField).at(2);
      final nameField = find.byType(TextFormField).at(3);
      final registerButton = find.text('Daftar Akun Baru');

      await tester.enterText(emailField, 'dosen@example.com');
      await tester.enterText(passwordField, 'rahasia123');
      await tester.enterText(confirmField, 'rahasia123');
      await tester.enterText(nameField, 'Dr. Gede Supadma');

      // Pilih kartu peran Instructor
      final instructorCard = find.byKey(const Key('role_instructor'));
      expect(instructorCard, findsOneWidget);
      await tester.ensureVisible(instructorCard);
      await tester.tap(instructorCard);
      await tester.pumpAndSettle();

      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi AuthService menerima metadata name dan role instructor
      expect(fakeAuth.registerCallCount, 1);
      expect(fakeAuth.lastRegisteredEmail, 'dosen@example.com');
      expect(fakeAuth.lastRegisteredName, 'Dr. Gede Supadma');
      expect(fakeAuth.lastRegisteredRole, 'instructor');
    });

    testWidgets('5. Role Admin TIDAK tersedia dan tidak dapat dipilih pada RegisterPage', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

      // Memastikan opsi Admin tidak ada pada RegisterPage
      expect(find.text('Admin'), findsNothing);
      expect(find.text('admin'), findsNothing);
      expect(find.byKey(const Key('role_admin')), findsNothing);

      // Hanya opsi Student dan Instructor yang tersedia
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Instructor'), findsOneWidget);
    });
  });

  group('Worksheet 9 Praktik 3 — Tampilan Profil Pengguna & Role', () {
    testWidgets('6. ProfilePage menampilkan Nama, Email, dan Role Student', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final user = User(
        id: 'user-supadma-profile-1',
        appMetadata: {},
        userMetadata: {'name': 'Gede Supadma', 'role': 'student'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'gedesupadma@undiksha.ac.id',
      );

      final fakeAuth = FakeRoleAuthService(mockUser: user);
      final fakeProfile = FakeProfileService(
        mockProfile: const UserProfile(
          id: 'user-supadma-profile-1',
          email: 'gedesupadma@undiksha.ac.id',
          name: 'Gede Supadma',
          role: 'student',
        ),
      );

      await tester.pumpWidget(MaterialApp(
        home: ProfilePage(
          authService: fakeAuth,
          profileService: fakeProfile,
        ),
      ));
      await tester.pumpAndSettle();

      // Verifikasi pemanggilan ProfileService
      expect(fakeProfile.getProfileCallCount, greaterThanOrEqualTo(1));

      // Verifikasi informasi yang ditampilkan
      expect(find.text('Gede Supadma'), findsWidgets);
      expect(find.text('gedesupadma@undiksha.ac.id'), findsOneWidget);
      expect(find.text('STUDENT'), findsWidgets);
      expect(find.text('Profil Akun Supabase'), findsOneWidget);
    });

    testWidgets('7. ProfilePage menampilkan Nama, Email, dan Role Instructor', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final user = User(
        id: 'user-instructor-profile-2',
        appMetadata: {},
        userMetadata: {'name': 'Prof. Supadma', 'role': 'instructor'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'prof.supadma@undiksha.ac.id',
      );

      final fakeAuth = FakeRoleAuthService(mockUser: user);
      final fakeProfile = FakeProfileService(
        mockProfile: const UserProfile(
          id: 'user-instructor-profile-2',
          email: 'prof.supadma@undiksha.ac.id',
          name: 'Prof. Supadma',
          role: 'instructor',
        ),
      );

      await tester.pumpWidget(MaterialApp(
        home: ProfilePage(
          authService: fakeAuth,
          profileService: fakeProfile,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Prof. Supadma'), findsWidgets);
      expect(find.text('prof.supadma@undiksha.ac.id'), findsOneWidget);
      expect(find.text('INSTRUCTOR'), findsWidgets);
    });

    testWidgets('8. ProfilePage menangani kondisi error dan menyediakan tombol Coba Lagi', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final user = User(
        id: 'user-error-test',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'error.test@undiksha.ac.id',
      );

      final fakeAuth = FakeRoleAuthService(mockUser: user);
      final fakeProfile = FakeProfileService(shouldThrow: true);

      await tester.pumpWidget(MaterialApp(
        home: ProfilePage(
          authService: fakeAuth,
          profileService: fakeProfile,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Gagal Memuat Profil Pengguna'), findsOneWidget);
      expect(find.textContaining('Gagal membaca tabel profiles dari Supabase'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Tekan tombol Coba Lagi setelah pulih
      fakeProfile.shouldThrow = false;
      fakeProfile.mockProfile = const UserProfile(
        id: 'user-error-test',
        email: 'error.test@undiksha.ac.id',
        name: 'Supadma Recovered',
        role: 'student',
      );

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Supadma Recovered'), findsWidgets);
      expect(find.text('STUDENT'), findsWidgets);
    });
  });
}
