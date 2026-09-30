import 'package:flutter/material.dart';

const String studentName = 'Gede Supadma';
const String studentId = '2415051014';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> pages = const [HomePage(), CoursesPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Courses'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==================== HOME ====================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80),
            SizedBox(height: 20),
            Text(
              'Selamat Datang',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Nama: Gede Supadma', style: TextStyle(fontSize: 18)),
            Text('NIM: 2415051014', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// ==================== COURSES ====================

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CourseCard(title: 'Pemrograman Mobile', code: 'PM01'),
          CourseCard(title: 'Pemrograman Web', code: 'WEB01'),
          CourseCard(title: 'Basis Data', code: 'BD01'),
          CourseCard(title: 'Rekayasa Perangkat Lunak', code: 'RPL01'),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String code;

  const CourseCard({super.key, required this.title, required this.code});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.school),
        title: Text(title),
        subtitle: Text(code),
      ),
    );
  }
}

// ==================== PROFILE ====================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),
            SizedBox(height: 20),
            Text(
              'Profil Mahasiswa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Nama: Gede Supadma', style: TextStyle(fontSize: 18)),
            Text('NIM: 2415051014', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
