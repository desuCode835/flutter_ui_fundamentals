// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_ui_fundamentals/main.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/home_page.dart';
import 'package:flutter_ui_fundamentals/screens/login_page.dart';
import 'package:flutter_ui_fundamentals/screens/profile_page.dart';
import 'package:flutter_ui_fundamentals/services/auth_service.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';

/// Fake AuthService untuk menguji Praktik 2: Session Checking & Logout
class FakePraktik2AuthService extends AuthService {
  bool _isLoggedIn;
  bool shouldFailSignOut;
  int signOutCalls = 0;
  final User _testUser;
  final Session _testSession;

  FakePraktik2AuthService({
    this._isLoggedIn = false,
    this.shouldFailSignOut = false,
  })  : _testUser = User(
          id: 'user-supadma-praktik2',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: 'supadma.test@undiksha.ac.id',
        ),
        _testSession = Session(
          accessToken: 'fake_jwt_token_praktik2',
          tokenType: 'bearer',
          user: User(
            id: 'user-supadma-praktik2',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
            email: 'supadma.test@undiksha.ac.id',
          ),
        );

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  User? get currentUser => _isLoggedIn ? _testUser : null;

  @override
  Session? get currentSession => _isLoggedIn ? _testSession : null;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (shouldFailSignOut) {
      throw const AuthException('Koneksi timeout saat sign out');
    }
    _isLoggedIn = false;
  }
}

class MockSupabaseService extends CourseSupabaseService {
  @override
  Future<List<Course>> getCourses() async {
    return [
      const Course(
        id: 1,
        code: 'CS201',
        title: 'Pemrograman Web & Mobile',
        credits: 3,
        status: 'active',
      ),
    ];
  }
}

void main() {
  late CourseProvider courseProvider;

  setUp(() {
    final repo = CourseRepository(
      CourseService(),
      CourseApiService(),
      MockSupabaseService(),
    );
    courseProvider = CourseProvider(repo);
  });

  Widget createTestApp({
    required AuthService authService,
    Widget? home,
  }) {
    AuthService.instance = authService;
    return ChangeNotifierProvider<CourseProvider>.value(
      value: courseProvider,
      child: MyApp(
        authService: authService,
        home: home,
      ),
    );
  }

  group('Worksheet 9 Praktik 2 — Session Checking & Auto Redirect', () {
    testWidgets('1. Pengguna tanpa sesi diarahkan langsung ke LoginPage', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = FakePraktik2AuthService(isLoggedIn: false);

      await tester.pumpWidget(createTestApp(authService: fakeAuth));
      await tester.pumpAndSettle();

      // Memastikan LoginPage tampil dan HomePage tidak tampil
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.text('Masuk Sekarang'), findsOneWidget);
      expect(find.byType(ResponsiveShell), findsNothing);
    });

    testWidgets('2. Pengguna dengan sesi valid langsung masuk ke HomePage tanpa melalui LoginPage', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = FakePraktik2AuthService(isLoggedIn: true);

      await tester.pumpWidget(createTestApp(authService: fakeAuth));
      await tester.pumpAndSettle();

      // Memastikan ResponsiveShell (HomePage) tampil langsung tanpa LoginPage
      expect(find.byType(ResponsiveShell), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.text('Course Explorer v2'), findsWidgets);
      expect(find.text('Status Sesi Supabase Auth'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    test('3. AuthService.isLoggedIn mengembalikan status sesi dengan benar', () {
      final fakeAuthLoggedOut = FakePraktik2AuthService(isLoggedIn: false);
      expect(fakeAuthLoggedOut.isLoggedIn, isFalse);
      expect(fakeAuthLoggedOut.currentSession, isNull);
      expect(fakeAuthLoggedOut.currentUser, isNull);

      final fakeAuthLoggedIn = FakePraktik2AuthService(isLoggedIn: true);
      expect(fakeAuthLoggedIn.isLoggedIn, isTrue);
      expect(fakeAuthLoggedIn.currentSession, isNotNull);
      expect(fakeAuthLoggedIn.currentUser, isNotNull);
      expect(fakeAuthLoggedIn.currentUser?.email, 'supadma.test@undiksha.ac.id');
    });
  });

  group('Worksheet 9 Praktik 2 — Fitur Logout & Redirection', () {
    testWidgets('4. Tombol Logout di HomePage menampilkan dialog konfirmasi', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = FakePraktik2AuthService(isLoggedIn: true);
      AuthService.instance = fakeAuth;

      await tester.pumpWidget(createTestApp(
        authService: fakeAuth,
        home: const HomePage(),
      ));
      await tester.pumpAndSettle();

      // Temukan tombol logout di AppBar HomePage
      final logoutAppBarBtn = find.byTooltip('Logout dari Akun');
      expect(logoutAppBarBtn, findsOneWidget);

      await tester.tap(logoutAppBarBtn);
      await tester.pumpAndSettle();

      // Verifikasi dialog konfirmasi muncul
      expect(find.text('Konfirmasi Logout'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin keluar dari akun Supabase Anda?\n\nSesi Anda akan dihapus dan Anda perlu login kembali untuk mengakses aplikasi.'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // Tekan tombol Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog harus tertutup dan pengguna tetap di HomePage
      expect(find.text('Konfirmasi Logout'), findsNothing);
      expect(fakeAuth.signOutCalls, 0);
      expect(fakeAuth.isLoggedIn, isTrue);
    });

    testWidgets('5. Konfirmasi logout di HomePage menghapus sesi dan redirect ke LoginPage', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = FakePraktik2AuthService(isLoggedIn: true);
      AuthService.instance = fakeAuth;

      await tester.pumpWidget(createTestApp(
        authService: fakeAuth,
        home: const ResponsiveShell(),
      ));
      await tester.pumpAndSettle();

      // Tekan tombol logout di SupabaseUserCard
      final userCardLogoutBtn = find.text('Logout dari Akun Supabase');
      expect(userCardLogoutBtn, findsOneWidget);

      await tester.ensureVisible(userCardLogoutBtn);
      await tester.tap(userCardLogoutBtn);
      await tester.pumpAndSettle();

      // Tekan konfirmasi Logout
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Logout');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verifikasi sesi dihapus dan pengguna diarahkan ke LoginPage
      expect(fakeAuth.signOutCalls, 1);
      expect(fakeAuth.isLoggedIn, isFalse);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Berhasil logout. Sesi Anda telah diakhiri.'), findsOneWidget);
    });

    testWidgets('6. Tombol Logout di ProfilePage menghapus sesi dan redirect ke LoginPage', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = FakePraktik2AuthService(isLoggedIn: true);
      AuthService.instance = fakeAuth;

      await tester.pumpWidget(createTestApp(
        authService: fakeAuth,
        home: const ProfilePage(),
      ));
      await tester.pumpAndSettle();

      // Temukan tombol logout di ProfilePage AppBar
      final logoutAppBarBtn = find.byTooltip('Logout');
      expect(logoutAppBarBtn, findsOneWidget);

      await tester.tap(logoutAppBarBtn);
      await tester.pumpAndSettle();

      // Konfirmasi logout
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Logout');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(fakeAuth.signOutCalls, 1);
      expect(fakeAuth.isLoggedIn, isFalse);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('7. Penanganan error jika proses signOut gagal', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = FakePraktik2AuthService(
        isLoggedIn: true,
        shouldFailSignOut: true,
      );
      AuthService.instance = fakeAuth;

      await tester.pumpWidget(createTestApp(
        authService: fakeAuth,
        home: const HomePage(),
      ));
      await tester.pumpAndSettle();

      // Tekan tombol logout di AppBar
      final logoutBtn = find.byTooltip('Logout dari Akun');
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Konfirmasi
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Logout');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verifikasi penanganan error
      expect(fakeAuth.signOutCalls, 1);
      expect(fakeAuth.isLoggedIn, isTrue); // Tetap login jika gagal
      expect(find.textContaining('Gagal logout:'), findsOneWidget);
      // Pengguna tetap berada di HomePage
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
