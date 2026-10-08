// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  int getColumns(double width) {
    if (width < 600) {
      return 1;
    }

    if (width < 840) {
      return 2;
    }

    return 3;
  }

  double getAspectRatio(int columns) {
    if (columns == 1) {
      return 2.2;
    }

    if (columns == 2) {
      return 1.4;
    }

    return 1.3;
  }

  // ====================================================
  // BUKA DETAIL
  // ====================================================

  void openDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CourseDetailPage(course: course);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Jumlah Favorite: ${courseProvider.favorites.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (courseProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (courseProvider.error != null) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan: ${courseProvider.error}',
                    ),
                  );
                } else {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = getColumns(constraints.maxWidth);

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: courseProvider.courses.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: getAspectRatio(columns),
                        ),
                        itemBuilder: (context, index) {
                          final course = courseProvider.courses[index];

                          return CourseCard(
                            course: course,
                            onOpenDetail: () {
                              openDetail(course);
                            },
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
