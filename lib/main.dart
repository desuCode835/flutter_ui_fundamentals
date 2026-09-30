import 'package:flutter/material.dart';

const String studentName = 'Gede Supadma';
const String studentId = '2415051014';

final List<Map<String, dynamic>> courses = [
  {
    'title': 'Pemrograman Mobile',
    'code': 'PM01',
    'credits': 3,
    'status': 'Aktif',
  },
  {
    'title': 'Pemrograman Web',
    'code': 'WEB01',
    'credits': 3,
    'status': 'Aktif',
  },
  {'title': 'Basis Data', 'code': 'BD01', 'credits': 3, 'status': 'Aktif'},
  {
    'title': 'Rekayasa Perangkat Lunak',
    'code': 'RPL01',
    'credits': 3,
    'status': 'Aktif',
  },
  {'title': 'Multimedia', 'code': 'MM01', 'credits': 2, 'status': 'Aktif'},
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CourseListPage(),
    );
  }
}

// ==================== COURSE LIST ====================

class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  Future<void> openCourseDetail(
    BuildContext context,
    Map<String, dynamic> course,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course['title']} berhasil dipilih/favorite')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 9 - Returning Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Course Explorer',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text('Nama: Gede Supadma', style: TextStyle(fontSize: 16)),

          const Text('NIM: 2415051014', style: TextStyle(fontSize: 16)),

          const SizedBox(height: 20),

          ...courses.map(
            (course) => Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text(course['title']),
                subtitle: Text('${course['code']} • ${course['credits']} SKS'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => openCourseDetail(context, course),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== COURSE DETAIL ====================

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Course',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Text(
              course['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              'Kode: ${course['code']}',
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              'SKS: ${course['credits']}',
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              'Status: ${course['status']}',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 16),

            const Text(
              'Data Mahasiswa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text('Nama: Gede Supadma', style: TextStyle(fontSize: 17)),

            const Text('NIM: 2415051014', style: TextStyle(fontSize: 17)),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.favorite),
                label: const Text('Pilih / Favorite'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
