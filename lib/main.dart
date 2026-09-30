import 'package:flutter/material.dart';

const String studentName = 'Gede Supadma';
const String studentId = '2415051014';

final List<Map<String, String>> courses = [
  {'code': 'PM01', 'name': 'Pemrograman Mobile', 'credits': '3 SKS'},
  {
    'code': 'PBO01',
    'name': 'Pemrograman Berorientasi Objek',
    'credits': '3 SKS',
  },
  {'code': 'WEB01', 'name': 'Pemrograman Web', 'credits': '3 SKS'},
  {'code': 'BD01', 'name': 'Basis Data', 'credits': '3 SKS'},
  {'code': 'RPL01', 'name': 'Rekayasa Perangkat Lunak', 'credits': '3 SKS'},
  {'code': 'MM01', 'name': 'Multimedia', 'credits': '2 SKS'},
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
      home: const CoursePage(),
    );
  }
}

class CoursePage extends StatelessWidget {
  const CoursePage({super.key});

  int columnsFor(double width) {
    if (width < 600) return 1;
    if (width < 840) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 5 - GridView Responsif')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = columnsFor(constraints.maxWidth);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Explorer',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nama: Gede Supadma',
                  style: TextStyle(fontSize: 16),
                ),
                const Text('NIM: 2415051014', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),

                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      return CourseCard(course: courses[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, String> course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 40),
            const SizedBox(height: 10),
            Text(
              course['code']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              course['name']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(course['credits']!),
          ],
        ),
      ),
    );
  }
}
