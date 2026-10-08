// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  // Callback untuk membuka detail
  final VoidCallback onOpenDetail;

  const CourseCard({
    super.key,
    required this.course,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final isFavorite = courseProvider.favorites.contains(course.code);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpenDetail,
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${course.title} - ${course.code}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          // Menggunakan context.read untuk memanggil aksi
                          context.read<CourseProvider>().toggleFavorite(
                            course.code,
                          );
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(course.code, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${course.credits} SKS'),
                  const Spacer(),
                  Text(
                    course.status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
