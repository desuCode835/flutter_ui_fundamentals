// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'config/supabase_config.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/courses_page.dart';
import 'screens/favorites_page.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/profile_page.dart';
import 'services/auth_service.dart';
import 'services/course_api_service.dart';
import 'services/course_service.dart';
import 'services/course_supabase_service.dart';

// ======================================================
// FIREBASE CLOUD MESSAGING
// ======================================================

Future<void> initializeFCM() async {
  // Mendengarkan FCM registration token
  FirebaseMessaging.instance.onRegistered.listen((token) {
    debugPrint('FCM TOKEN: $token');
  });

  // Mendengarkan notifikasi ketika aplikasi sedang terbuka
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Notifikasi FCM diterima!');
    debugPrint('Judul: ${message.notification?.title}');
    debugPrint('Isi: ${message.notification?.body}');
  });

  // Mendengarkan ketika pengguna membuka notifikasi
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Pengguna membuka notifikasi FCM.');
    debugPrint('Judul: ${message.notification?.title}');
  });

  // Mendaftarkan perangkat ke Firebase Cloud Messaging
  try {
    await FirebaseMessaging.instance.register();
    debugPrint('Registrasi FCM berhasil.');
  } catch (e) {
    debugPrint('Registrasi FCM gagal: $e');
  }
}

// ======================================================
// MAIN
// ======================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Firebase berhasil diinisialisasi.');

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  debugPrint('Supabase berhasil diinisialisasi.');

  // Inisialisasi service dan repository
  final service = CourseService();
  final apiService = CourseApiService();
  final supabaseService = CourseSupabaseService();

  final repository = CourseRepository(service, apiService, supabaseService);

  // Menjalankan aplikasi
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        debugPrint(
          '[DEBUG - Kasus B] ChangeNotifierProvider berhasil diinisialisasi membungkus root tree.',
        );

        return CourseProvider(repository);
      },
      child: const MyApp(),
    ),
  );

  // Inisialisasi FCM setelah aplikasi dijalankan
  initializeFCM();
}

// ======================================================
// APP
// ======================================================

class MyApp extends StatelessWidget {
  final Widget? home;
  final AuthService? authService;

  const MyApp({super.key, this.home, this.authService});

  @override
  Widget build(BuildContext context) {
    // PRAKTIK 2: Pengecekan current session ketika aplikasi pertama kali dibuka.
    // Jika user memiliki session aktif dan valid di Supabase Auth -> langsung tampilkan ResponsiveShell (HomePage).
    // Jika tidak ada session -> tampilkan LoginPage.

    final auth = authService ?? AuthService.instance;

    final Widget initialHome =
        home ??
        (auth.isLoggedIn
            ? const ResponsiveShell()
            : LoginPage(authService: auth));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer v2',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF),
          primary: const Color(0xFF1E40AF),
          secondary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E40AF),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 2,
          indicatorColor: const Color(0xFFDBEAFE),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
              );
            }

            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            );
          }),
        ),
      ),
      home: initialHome,
    );
  }
}

// ======================================================
// RESPONSIVE SHELL
// ======================================================

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    CoursesPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  NavigationBar buildNavigationBar() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });

        if (index == 1) {
          context.read<CourseProvider>().fetchSupabaseCourses();
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  NavigationRail buildNavigationRail() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });

        if (index == 1) {
          context.read<CourseProvider>().fetchSupabaseCourses();
        }
      },
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: Text('Courses'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: Text('Favorites'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Scaffold(
            body: pages[selectedIndex],
            bottomNavigationBar: buildNavigationBar(),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              buildNavigationRail(),
              const VerticalDivider(width: 1),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}
