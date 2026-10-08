// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final isFavorite = courseProvider.favorites.contains(course.code);

    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.book, size: 80),
            const SizedBox(height: 20),
            Text(
              course.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Kode: ${course.code}', style: const TextStyle(fontSize: 17)),
            Text(
              'SKS: ${course.credits}',
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              'Status: ${course.status}',
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 30),
            const Text(
              'Mahasiswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Gede Supadma'),
            const Text('NIM: 2415051014'),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final isFav = context
                      .read<CourseProvider>()
                      .favorites
                      .contains(course.code);
                  context.read<CourseProvider>().toggleFavorite(course.code);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !isFav
                            ? 'Course ditambahkan ke favorite'
                            : 'Course dihapus dari favorite',
                      ),
                    ),
                  );
                },
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(isFavorite ? 'Favorite' : 'Tambah Favorite'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
