// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/models/user_profile.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/course_detail_page.dart';
import 'package:flutter_ui_fundamentals/screens/home_page.dart';
import 'package:flutter_ui_fundamentals/services/auth_service.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:flutter_ui_fundamentals/services/profile_service.dart';
import 'package:flutter_ui_fundamentals/widgets/role_guard.dart';

/// Fake AuthService untuk pengujian Praktik 4 (Role-Based Authorization)
class FakeAuthServiceP4 extends AuthService {
  User? mockUser;

  FakeAuthServiceP4({this.mockUser});

  @override
  User? get currentUser => mockUser;

  @override
  bool get isLoggedIn => mockUser != null;
}

/// Fake ProfileService untuk pengujian Praktik 4
class FakeProfileServiceP4 extends ProfileService {
  UserProfile? mockProfile;
  bool shouldThrow = false;
  int getProfileCallCount = 0;

  FakeProfileServiceP4({this.mockProfile, this.shouldThrow = false});

  @override
  UserProfile? get cachedProfile => mockProfile;

  @override
  String get currentUserRoleSync => mockProfile?.role ?? 'student';

  @override
  Future<UserProfile?> getCurrentProfile() async {
    getProfileCallCount++;
    if (shouldThrow) {
      throw Exception('Gagal memuat profil pengguna dari Supabase');
    }
    return mockProfile;
  }

  @override
  Future<String> getCurrentUserRole() async {
    if (shouldThrow) {
      throw Exception('Gagal memuat role dari Supabase');
    }
    return mockProfile?.role ?? 'student';
  }
}

/// Fake CourseSupabaseService untuk pengujian UI tanpa network
class FakeCourseSupabaseServiceP4 extends CourseSupabaseService {
  final List<Course> mockCourses;

  FakeCourseSupabaseServiceP4(this.mockCourses);

  @override
  Future<List<Course>> getCourses() async {
    return List.from(mockCourses);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CourseProvider courseProvider;
  late List<Course> initialCourses;

  setUp(() {
    initialCourses = [
      const Course(
        id: 1,
        code: 'CS101',
        title: 'Pengantar Pemrograman',
        credits: 3,
        status: 'active',
        userId: 101, // Milik user 101
      ),
      const Course(
        id: 2,
        code: 'CS102',
        title: 'Struktur Data & Algoritma',
        credits: 4,
        status: 'active',
        userId: 202, // Milik user 202
      ),
      const Course(
        id: 3,
        code: 'CS103',
        title: 'Basis Data Lanjutan',
        credits: 3,
        status: 'planned',
        // Tanpa userId (simulasi data Supabase saat ini tanpa ownership)
      ),
    ];

    final localService = CourseService();
    final apiService = CourseApiService();
    final supabaseService = FakeCourseSupabaseServiceP4(initialCourses);
    final repo = CourseRepository(localService, apiService, supabaseService);
    courseProvider = CourseProvider(repo);
    courseProvider.supabaseCourses = List.from(initialCourses);
    courseProvider.courses = List.from(initialCourses);
  });

  Widget buildTestableWidget(
    Widget child, {
    CourseProvider? provider,
  }) {
    return ChangeNotifierProvider<CourseProvider>.value(
      value: provider ?? courseProvider,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Worksheet 9 Praktik 4 — RoleGuard Widget & Authorization Logic', () {
    testWidgets('1. RoleGuard menampilkan child jika role pengguna termasuk dalam allowedRoles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleGuard(
              userRole: 'instructor',
              allowedRoles: ['instructor', 'admin'],
              child: Text('Instructor / Admin Content'),
            ),
          ),
        ),
      );

      expect(find.text('Instructor / Admin Content'), findsOneWidget);
    });

    testWidgets('2. RoleGuard menyembunyikan child (SizedBox.shrink) jika role tidak diizinkan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleGuard(
              userRole: 'student',
              allowedRoles: ['instructor', 'admin'],
              child: Text('Protected Content'),
            ),
          ),
        ),
      );

      expect(find.text('Protected Content'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('3. RoleGuard menangani case-insensitivity dan whitespace pada role pengguna', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RoleGuard(
                  userRole: ' ADMIN ',
                  allowedRoles: ['admin'],
                  child: Text('Admin Content'),
                ),
                RoleGuard(
                  userRole: 'Instructor',
                  allowedRoles: ['instructor'],
                  child: Text('Instructor Content'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Admin Content'), findsOneWidget);
      expect(find.text('Instructor Content'), findsOneWidget);
    });

    testWidgets('4. RoleGuard dengan isOwner: instructor hanya melihat jika isOwner == true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RoleGuard(
                  userRole: 'instructor',
                  allowedRoles: ['instructor', 'admin'],
                  isOwner: true,
                  child: Text('Tombol Edit Course Milik Sendiri'),
                ),
                RoleGuard(
                  userRole: 'instructor',
                  allowedRoles: ['instructor', 'admin'],
                  isOwner: false,
                  child: Text('Tombol Edit Course Orang Lain'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tombol Edit Course Milik Sendiri'), findsOneWidget);
      expect(find.text('Tombol Edit Course Orang Lain'), findsNothing);
    });

    testWidgets('5. RoleGuard dengan isOwner: admin tetap melihat meski isOwner == false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleGuard(
              userRole: 'admin',
              allowedRoles: ['instructor', 'admin'],
              isOwner: false,
              child: Text('Admin Can Edit Any Course'),
            ),
          ),
        ),
      );

      expect(find.text('Admin Can Edit Any Course'), findsOneWidget);
    });
  });

  group('Worksheet 9 Praktik 4 — Role-Based UI Access Rules', () {
    testWidgets('6. Student TIDAK DAPAT melihat form dan tombol Add Course di HomePage', (tester) async {
      final fakeAuth = FakeAuthServiceP4(
        mockUser: User(
          id: 'user-student-1',
          appMetadata: {},
          userMetadata: {'name': 'Budi Student', 'role': 'student'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: 'budi@example.com',
        ),
      );
      final fakeProfile = FakeProfileServiceP4(
        mockProfile: const UserProfile(
          id: 'user-student-1',
          email: 'budi@example.com',
          name: 'Budi Student',
          role: 'student',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          HomePage(
            authService: fakeAuth,
            profileService: fakeProfile,
            userRole: 'student',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Form Tambah Course Baru (Tahap 6) tidak boleh terlihat untuk Student
      expect(find.text('Tahap 6 — Form Tambah Course Baru (HTTP POST)'), findsNothing);
      expect(find.text('Simpan ke Supabase'), findsNothing);
      expect(find.text('Simpan (HTTP POST)'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Simpan ke Supabase'), findsNothing);
    });

    testWidgets('7. Student TIDAK DAPAT melihat tombol Edit dan Delete di CourseDetailPage', (tester) async {
      final testCourse = initialCourses.first;

      await tester.pumpWidget(
        buildTestableWidget(
          CourseDetailPage(
            course: testCourse,
            userRole: 'student',
            isOwner: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tombol Edit dan Delete tidak boleh ada
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.edit_note), findsNothing);
      expect(find.text('Edit Course di Supabase'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.delete_forever), findsNothing);
      expect(find.text('Hapus Course dari Supabase'), findsNothing);

      // Namun fitur Favorite dan Detail Course tetap ada untuk Student
      expect(find.byIcon(Icons.favorite_border), findsWidgets);
      expect(find.text('Pengantar Pemrograman'), findsOneWidget);
    });

    testWidgets('8. Instructor DAPAT melihat form dan tombol Add Course di HomePage', (tester) async {
      final fakeAuth = FakeAuthServiceP4(
        mockUser: User(
          id: 'user-inst-101',
          appMetadata: {},
          userMetadata: {'name': 'Dosen Gede', 'role': 'instructor'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: 'dosen@example.com',
        ),
      );
      final fakeProfile = FakeProfileServiceP4(
        mockProfile: const UserProfile(
          id: 'user-inst-101',
          email: 'dosen@example.com',
          name: 'Dosen Gede',
          role: 'instructor',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          HomePage(
            authService: fakeAuth,
            profileService: fakeProfile,
            userRole: 'instructor',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Form Tambah Course Baru harus terlihat untuk Instructor
      expect(find.text('Simpan ke Supabase'), findsOneWidget);
      expect(find.text('Simpan (HTTP POST)'), findsOneWidget);
    });

    testWidgets('9. Instructor HANYA melihat tombol Edit dan Delete pada course miliknya sendiri', (tester) async {
      final ownedCourse = initialCourses[0]; // userId: 101

      // 1. Pada course miliknya (isOwner: true)
      await tester.pumpWidget(
        buildTestableWidget(
          CourseDetailPage(
            course: ownedCourse,
            userRole: 'instructor',
            isOwner: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('Edit Course di Supabase'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.text('Hapus Course dari Supabase'), findsOneWidget);
    });

    testWidgets('10. Instructor TIDAK DAPAT mengedit atau menghapus course milik pengguna lain', (tester) async {
      final othersCourse = initialCourses[1]; // userId: 202

      // 2. Pada course milik orang lain (isOwner: false)
      await tester.pumpWidget(
        buildTestableWidget(
          CourseDetailPage(
            course: othersCourse,
            userRole: 'instructor',
            isOwner: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.text('Edit Course di Supabase'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.text('Hapus Course dari Supabase'), findsNothing);
    });

    testWidgets('11. Admin DAPAT melihat fitur pengelolaan (Add, Edit, Delete) pada seluruh course', (tester) async {
      final othersCourse = initialCourses[1]; // userId: 202

      // Admin melihat Add Course di Home
      await tester.pumpWidget(
        buildTestableWidget(
          const HomePage(
            userRole: 'admin',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Simpan ke Supabase'), findsOneWidget);
      expect(find.text('Simpan (HTTP POST)'), findsOneWidget);

      // Admin melihat Edit dan Delete di Detail meski bukan pemilik (isOwner: false)
      await tester.pumpWidget(
        buildTestableWidget(
          CourseDetailPage(
            course: othersCourse,
            userRole: 'admin',
            isOwner: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('Edit Course di Supabase'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.text('Hapus Course dari Supabase'), findsOneWidget);
    });

    testWidgets('12. Penanganan role saat profil loading atau error defaulting dengan aman', (tester) async {
      // RoleGuard dengan userRole: null (simulasi saat profile belum selesai dimuat)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RoleGuard(
              userRole: null,
              allowedRoles: ['instructor', 'admin'],
              child: Text('Sensitive Action'),
            ),
          ),
        ),
      );

      // Tindakan sensitif tidak boleh dirender secara prematur saat loading
      expect(find.text('Sensitive Action'), findsNothing);

      // isCourseOwner mengembalikan false jika tidak ada user login atau ID tidak cocok
      const unownedCourse = Course(code: 'CS99', title: 'Test', userId: null);
      expect(isCourseOwner(unownedCourse, userId: null), isFalse);
      expect(isCourseOwner(unownedCourse, userId: 'user-123'), isFalse);
    });
  });
}
