// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/foundation.dart';

import 'models/course.dart';
import 'repositories/course_repository.dart';

class CourseState extends ChangeNotifier {
  final CourseRepository repository;

  CourseState(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  final Set<String> favorites = {};

  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    notifyListeners();
  }

  //Nama : Gede Supadma
  //NIM : 2415051014
  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
