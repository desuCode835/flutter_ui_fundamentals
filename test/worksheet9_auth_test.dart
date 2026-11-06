// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/screens/login_page.dart';
import 'package:flutter_ui_fundamentals/screens/register_page.dart';
import 'package:flutter_ui_fundamentals/services/auth_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';

// =============================================================================
// FAKE AUTH SERVICE UNTUK PENGUJIAN OTOMATIS
// =============================================================================
class FakeAuthService extends AuthService {
  bool shouldFail = false;
  String? failMessage;
  bool returnSessionOnRegister = false;
  int loginCallCount = 0;
  int registerCallCount = 0;

  @override
  Future<AuthResponse> login(String email, String password) async {
    loginCallCount++;
    if (shouldFail) {
      throw AuthException(failMessage ?? 'Invalid login credentials');
    }
    return AuthResponse(
      session: Session(
        accessToken: 'fake_access_token',
        tokenType: 'bearer',
        user: User(
          id: 'user-supadma-123',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: email,
        ),
      ),
      user: User(
        id: 'user-supadma-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }

  @override
  Future<AuthResponse> register(String email, String password) async {
    registerCallCount++;
    if (shouldFail) {
      throw AuthException(failMessage ?? 'User already registered');
    }
    final user = User(
      id: 'user-new-456',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    return AuthResponse(
      session: returnSessionOnRegister
          ? Session(
              accessToken: 'fake_access_token',
              tokenType: 'bearer',
              user: user,
            )
          : null,
      user: user,
    );
  }
}

class MockCourseService extends CourseService {
  @override
  Future<List<Course>> loadCourses() async {
    return [
      const Course(
        code: 'MOB01',
        title: 'Pengembangan Aplikasi Mobile',
        credits: 3,
        status: 'active',
      ),
    ];
  }
}

void main() {
  late FakeAuthService fakeAuthService;
  late CourseProvider courseProvider;

  setUp(() {
    fakeAuthService = FakeAuthService();
    final service = MockCourseService();
    final repository = CourseRepository(service);
    courseProvider = CourseProvider(repository);
  });

  Widget buildTestableWidget(Widget child) {
    return ChangeNotifierProvider<CourseProvider>.value(
      value: courseProvider,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Worksheet 9 Praktik 1 — LoginPage Validation & Authentication Flow', () {
    testWidgets('1. Field email dan password kosong memicu pesan validasi', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(LoginPage(authService: fakeAuthService)));

      final loginButton = find.text('Masuk Sekarang');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
      expect(fakeAuthService.loginCallCount, 0);
    });

    testWidgets('2. Format email tidak valid memicu pesan validasi', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(LoginPage(authService: fakeAuthService)));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.text('Masuk Sekarang');

      await tester.enterText(emailField, 'bukan-email-valid');
      await tester.enterText(passwordField, 'rahasia123');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid (contoh: user@domain.com)'), findsOneWidget);
      expect(fakeAuthService.loginCallCount, 0);
    });

    testWidgets('3. Password kurang dari 6 karakter memicu pesan validasi', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(LoginPage(authService: fakeAuthService)));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.text('Masuk Sekarang');

      await tester.enterText(emailField, 'gedesupadma@example.com');
      await tester.enterText(passwordField, '12345');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
      expect(fakeAuthService.loginCallCount, 0);
    });

    testWidgets('4. Login berhasil mengarahkan pengguna ke Course Explorer', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(LoginPage(authService: fakeAuthService)));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.text('Masuk Sekarang');

      await tester.enterText(emailField, 'gedesupadma@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(fakeAuthService.loginCallCount, 1);
      // Memastikan navigasi ke ResponsiveShell / Course Explorer
      expect(find.text('Course Explorer v2'), findsWidgets);
    });

    testWidgets('5. Login kredensial salah menampilkan pesan error yang mudah dipahami', (tester) async {
      fakeAuthService.shouldFail = true;
      fakeAuthService.failMessage = 'Invalid login credentials';

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(LoginPage(authService: fakeAuthService)));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final loginButton = find.text('Masuk Sekarang');

      await tester.enterText(emailField, 'gedesupadma@example.com');
      await tester.enterText(passwordField, 'passwordSalah123');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(fakeAuthService.loginCallCount, 1);
      expect(
        find.text('Email atau password salah. Periksa kembali kredensial Anda.'),
        findsOneWidget,
      );
    });

    testWidgets('6. Navigasi dari LoginPage ke RegisterPage berfungsi', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(LoginPage(authService: fakeAuthService)));

      final registerLink = find.text('Daftar Sekarang');
      await tester.ensureVisible(registerLink);
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      expect(find.text('Buat Akun Baru'), findsOneWidget);
      expect(find.text('Konfirmasi Password'), findsOneWidget);
    });
  });

  group('Worksheet 9 Praktik 1 — RegisterPage Validation & Flow', () {
    testWidgets('7. Form Register kosong memicu validasi ketiga input', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(RegisterPage(authService: fakeAuthService)));

      final registerButton = find.text('Daftar Akun Baru');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
      expect(find.text('Konfirmasi password wajib diisi'), findsOneWidget);
      expect(fakeAuthService.registerCallCount, 0);
    });

    testWidgets('8. Konfirmasi password yang berbeda memicu pesan validasi', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(RegisterPage(authService: fakeAuthService)));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final confirmField = find.byType(TextFormField).at(2);
      final registerButton = find.text('Daftar Akun Baru');

      await tester.enterText(emailField, 'gedesupadma@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmField, 'passwordBEDA');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Konfirmasi password tidak cocok dengan password di atas'),
        findsOneWidget,
      );
      expect(fakeAuthService.registerCallCount, 0);
    });

    testWidgets('9. Registrasi berhasil dengan session mengarahkan ke Home', (tester) async {
      fakeAuthService.returnSessionOnRegister = true;

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(RegisterPage(authService: fakeAuthService)));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final confirmField = find.byType(TextFormField).at(2);
      final registerButton = find.text('Daftar Akun Baru');

      await tester.enterText(emailField, 'gedesupadma@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmField, 'password123');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(fakeAuthService.registerCallCount, 1);
      expect(find.text('Course Explorer v2'), findsWidgets);
    });

    testWidgets('10. Registrasi berhasil tanpa session menampilkan dialog konfirmasi email', (tester) async {
      fakeAuthService.returnSessionOnRegister = false;

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(RegisterPage(authService: fakeAuthService)));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final confirmField = find.byType(TextFormField).at(2);
      final registerButton = find.text('Daftar Akun Baru');

      await tester.enterText(emailField, 'gedesupadma@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmField, 'password123');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeAuthService.registerCallCount, 1);
      expect(find.text('Konfirmasi Email'), findsOneWidget);
      expect(find.text('Kembali ke Halaman Login'), findsOneWidget);

      await tester.tap(find.text('Kembali ke Halaman Login'));
      await tester.pumpAndSettle();
    });

    testWidgets('11. Registrasi email duplikat menampilkan pesan error', (tester) async {
      fakeAuthService.shouldFail = true;
      fakeAuthService.failMessage = 'User already registered';

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(RegisterPage(authService: fakeAuthService)));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final confirmField = find.byType(TextFormField).at(2);
      final registerButton = find.text('Daftar Akun Baru');

      await tester.enterText(emailField, 'gedesupadma@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmField, 'password123');
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(fakeAuthService.registerCallCount, 1);
      expect(
        find.text(
          'Email tersebut sudah terdaftar di Supabase Auth. Silakan masuk menggunakan akun tersebut atau gunakan email lain.',
        ),
        findsOneWidget,
      );
    });
  });

  group('Worksheet 9 Praktik 1 — Responsiveness & UI/UX', () {
    testWidgets('12. Layar sempit (360x640) tidak mengalami RenderFlex overflow pada LoginPage', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(LoginPage(authService: fakeAuthService)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
    });

    testWidgets('13. Layar sempit (360x640) tidak mengalami RenderFlex overflow pada RegisterPage', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(RegisterPage(authService: fakeAuthService)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Buat Akun Baru'), findsOneWidget);
    });
  });
}
