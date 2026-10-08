import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ui_fundamentals/course_state.dart';
import 'package:flutter_ui_fundamentals/main.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';

class MockCourseService extends CourseService {
  @override
  Future<List<Course>> loadCourses() async {
    return [
      const Course(
        code: 'MOB01',
        title: 'Git & GitHub',
        credits: 2,
        status: 'done',
      ),
    ];
  }
}

void main() {
  testWidgets('Course Explorer smoke test', (WidgetTester tester) async {
    final service = MockCourseService();
    final repository = CourseRepository(service);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CourseState(repository),
        child: const MyApp(),
      ),
    );

    expect(find.text('Course Explorer'), findsWidgets);
    expect(find.text('Nama: Gede Supadma'), findsOneWidget);
  });
}

