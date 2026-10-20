// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../services/course_service.dart';

// =============================================================================
// TAHAP 15: DOKUMENTASI DEBUGGING PROVIDER & CHANGENOTIFIER
// -----------------------------------------------------------------------------
// Kasus A: notifyListeners() memicu rebuild widget yang mendengarkan state.
// Kasus B: Akses context provider harus berada di bawah ChangeNotifierProvider.
// Kasus C: Error handling & pembaruan state saat pembacaan data gagal.
// Kasus D: Penanganan async state & pengecekan mounted sebelum perubahan UI.
// =============================================================================

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  final Set<String> favorites = {};

  // ===========================================================================
  // TAHAP 2 & 3: STATE & HTTP GET REST API (List<Course>)
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  List<Course> posts = [];
  bool isPostsLoading = false;
  String? postsError;
  String? lastFetchedUrl;

  Future<void> fetchPosts({String? endpoint}) async {
    isPostsLoading = true;
    postsError = null;
    lastFetchedUrl = endpoint ?? CourseService.apiUrl;
    notifyListeners();

    try {
      posts = await repository.getPosts(endpoint: endpoint);
      debugPrint(
        '[TAHAP 3 Provider] Berhasil memperbarui state dengan ${posts.length} Course',
      );
    } catch (e) {
      postsError = e.toString();
      debugPrint('[TAHAP 3 Provider] Terjadi error saat fetchPosts: $e');
    } finally {
      isPostsLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String code) {
    return favorites.contains(code);
  }

  // ===========================================================================
  // TAHAP 15 - KASUS A: PENGUJIAN notifyListeners()
  // ===========================================================================
  void toggleFavorite(String code) {
    debugPrint(
      '[DEBUG - Kasus A] toggleFavorite() dipanggil untuk code: $code',
    );

    if (favorites.contains(code)) {
      favorites.remove(code);
      debugPrint(
        '[DEBUG - Kasus A] Course $code dihapus dari favorites. Sisa: ${favorites.length}',
      );
    } else {
      favorites.add(code);
      debugPrint(
        '[DEBUG - Kasus A] Course $code ditambahkan ke favorites. Total: ${favorites.length}',
      );
    }

    // [Kasus A]: notifyListeners() WAJIB dipanggil agar UI (watch/Consumer) langsung rebuild.
    // Jika baris ini dikomentari/dihapus, data berubah secara internal namun UI tidak akan terupdate.
    notifyListeners();
    debugPrint(
      '[DEBUG - Kasus A] notifyListeners() dipanggil untuk memperbarui UI.',
    );
  }

  List<Course> get favoriteCourses {
    return courses.where((course) => favorites.contains(course.code)).toList();
  }

  // ===========================================================================
  // TAHAP 15 - KASUS C: PENGUJIAN ERROR & ASYNC STATE
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM : 2415051014
  Future<void> loadCourses() async {
    debugPrint('[DEBUG - Kasus C] loadCourses() dimulai (state: loading)');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
      debugPrint(
        '[DEBUG - Kasus C] Data courses berhasil dimuat: ${courses.length} item',
      );
    } catch (e) {
      error = e.toString();
      debugPrint('[DEBUG - Kasus C] Terjadi error saat membaca data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
      debugPrint('[DEBUG - Kasus C] loadCourses() selesai (state: selesai)');
    }
  }
}
