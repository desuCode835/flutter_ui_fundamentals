// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

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
  // TAHAP 5: STATE PENGAMBILAN DATA REST API (Loading, Success, Empty, Error)
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  List<Course> posts = [];
  bool isPostsLoading = false;
  String? postsError;
  bool hasFetchedPosts = false;
  String? lastFetchedUrl;

  // Getters helper state Tahap 5
  String? get errorMessage => postsError;
  bool get isPostsEmpty =>
      hasFetchedPosts && !isPostsLoading && postsError == null && posts.isEmpty;
  bool get isPostsSuccess =>
      hasFetchedPosts &&
      !isPostsLoading &&
      postsError == null &&
      posts.isNotEmpty;

  Future<void> fetchPosts({String? endpoint}) async {
    isPostsLoading = true;
    postsError = null;
    lastFetchedUrl = endpoint ?? CourseRepository.apiUrl;
    notifyListeners();

    try {
      posts = await repository.getPosts(endpoint: endpoint);
      hasFetchedPosts = true;
      debugPrint(
        '[TAHAP 5 Provider] Berhasil mengambil ${posts.length} Course (State: ${posts.isEmpty ? "EMPTY" : "SUCCESS"})',
      );
    } catch (e) {
      postsError = e.toString();
      hasFetchedPosts = true;
      debugPrint(
        '[TAHAP 5 Provider] Terjadi error saat fetchPosts (State: ERROR): $e',
      );
    } finally {
      isPostsLoading = false;
      notifyListeners();
    }
  }

  /// Tombol Retry: Memanggil ulang proses pengambilan data menggunakan endpoint normal yang benar
  Future<void> retryFetchPosts() {
    debugPrint(
      '[TAHAP 5 Provider] Tombol Retry ditekan, mencoba ulang dengan endpoint normal: ${CourseRepository.apiUrl}',
    );
    return fetchPosts();
  }

  /// Simulasi / reset state kosong (Empty State)
  void clearPosts() {
    posts = [];
    hasFetchedPosts = true;
    postsError = null;
    isPostsLoading = false;
    notifyListeners();
  }

  // ===========================================================================
  // TAHAP 6: HTTP POST — MEMBUAT RESOURCE BARU
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  bool isCreatingCourse = false;
  String? createCourseError;

  Future<bool> createCourse(Course course, {String? endpoint}) async {
    isCreatingCourse = true;
    createCourseError = null;
    notifyListeners();

    try {
      final createdCourse = await repository.addCourse(
        course,
        endpoint: endpoint,
      );

      // 6. Perbarui daftar agar hasil terbaru langsung terlihat di UI
      // Sisipkan di posisi pertama (index 0) agar langsung tampak di daftar atas
      posts.insert(0, createdCourse);
      hasFetchedPosts = true;
      postsError = null;

      debugPrint(
        '[TAHAP 6 Provider] Berhasil membuat course: ${createdCourse.code} - ${createdCourse.title} (Total posts: ${posts.length})',
      );
      return true;
    } catch (e) {
      createCourseError = e.toString();
      debugPrint('[TAHAP 6 Provider] Gagal membuat course: $e');
      return false;
    } finally {
      isCreatingCourse = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // TAHAP 7: HTTP PUT / PATCH — MEMPERBARUI RESOURCE
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  bool isUpdatingCourse = false;
  String? updateCourseError;

  Future<bool> updateCourse(
    Course updatedCourse, {
    String? originalCode,
    int? originalId,
    String? endpoint,
    bool usePatch = false,
  }) async {
    isUpdatingCourse = true;
    updateCourseError = null;
    notifyListeners();

    try {
      final resultCourse = await repository.updateCourse(
        updatedCourse,
        endpoint: endpoint,
        usePatch: usePatch,
      );

      // 8. Perbarui daftar course lokal agar perubahan langsung terlihat di UI
      // JSONPlaceholder menyimulasikan pembaruan tanpa menyimpan permanen di server,
      // sehingga sinkronisasi state lokal memastikan integritas tampilan UI.
      int index = -1;
      if (originalId != null) {
        index = posts.indexWhere((p) => p.id == originalId);
      } else if (updatedCourse.id != null) {
        index = posts.indexWhere((p) => p.id == updatedCourse.id);
      }

      if (index == -1 && originalCode != null) {
        index = posts.indexWhere((p) => p.code == originalCode);
      }

      if (index == -1) {
        index = posts.indexWhere((p) => p.code == updatedCourse.code);
      }

      if (index != -1) {
        posts[index] = resultCourse;
      } else {
        posts.insert(0, resultCourse);
      }

      // Perbarui juga data courses lokal jika cocok
      int localIndex = -1;
      if (originalCode != null) {
        localIndex = courses.indexWhere((c) => c.code == originalCode);
      } else {
        localIndex = courses.indexWhere((c) => c.code == updatedCourse.code);
      }
      if (localIndex != -1) {
        courses[localIndex] = resultCourse;
      }

      debugPrint(
        '[TAHAP 7 Provider] Berhasil memperbarui course: ${resultCourse.code} - ${resultCourse.title}',
      );
      return true;
    } catch (e) {
      updateCourseError = e.toString();
      debugPrint('[TAHAP 7 Provider] Gagal memperbarui course: $e');
      return false;
    } finally {
      isUpdatingCourse = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // TAHAP 8: HTTP DELETE — MENGHAPUS RESOURCE
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  bool isDeletingCourse = false;
  String? deleteCourseError;

  Future<bool> deleteCourse(int id, {String? code, String? endpoint}) async {
    isDeletingCourse = true;
    deleteCourseError = null;
    notifyListeners();

    try {
      final success = await repository.deleteCourse(id, endpoint: endpoint);

      if (success) {
        // 7. Setelah berhasil, perbarui daftar course agar item yang dihapus tidak lagi tampil.
        // JSONPlaceholder menyimulasikan DELETE tanpa menghapus data secara permanen di server,
        // sehingga sinkronisasi state lokal memastikan UI langsung mencerminkan penghapusan item.
        posts.removeWhere(
          (p) => p.id == id || (code != null && p.code == code),
        );

        // Hapus juga dari daftar courses lokal jika cocok
        if (code != null) {
          courses.removeWhere((c) => c.code == code);
          favorites.remove(code);
        }

        debugPrint(
          '[TAHAP 8 Provider] Berhasil menghapus course ID: $id (Sisa posts: ${posts.length})',
        );
        return true;
      }
      return false;
    } catch (e) {
      // 7. Pastikan penanganan error tidak menghapus item dari UI jika request gagal
      deleteCourseError = e.toString();
      debugPrint('[TAHAP 8 Provider] Gagal menghapus course: $e');
      return false;
    } finally {
      isDeletingCourse = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // TAHAP 12: STATE PENGAMBILAN DATA SUPABASE (SELECT — Membaca Data Database)
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  List<Course> supabaseCourses = [];
  bool isSupabaseLoading = false;
  String? supabaseError;
  bool hasFetchedSupabase = false;

  bool get isSupabaseEmpty =>
      hasFetchedSupabase &&
      !isSupabaseLoading &&
      supabaseError == null &&
      supabaseCourses.isEmpty;

  bool get isSupabaseSuccess =>
      hasFetchedSupabase &&
      !isSupabaseLoading &&
      supabaseError == null &&
      supabaseCourses.isNotEmpty;

  /// Membaca daftar course dari database Supabase melalui CourseRepository
  Future<void> fetchSupabaseCourses() async {
    isSupabaseLoading = true;
    supabaseError = null;
    notifyListeners();

    try {
      supabaseCourses = await repository.getSupabaseCourses();
      hasFetchedSupabase = true;
      debugPrint(
        '[TAHAP 12 Provider] Berhasil mengambil ${supabaseCourses.length} Course dari Supabase',
      );
    } catch (e) {
      supabaseError = e.toString();
      hasFetchedSupabase = true;
      debugPrint(
        '[TAHAP 12 Provider] Terjadi error saat fetchSupabaseCourses: $e',
      );
    } finally {
      isSupabaseLoading = false;
      notifyListeners();
    }
  }

  /// Alias method untuk kemudahan pemanggilan
  Future<void> loadSupabaseCourses() => fetchSupabaseCourses();

  // ===========================================================================
  // TAHAP 13: INSERT COURSE KE SUPABASE (Menambah Data ke Database)
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  bool isCreatingSupabaseCourse = false;
  String? createSupabaseCourseError;

  /// Menambahkan course baru ke database Supabase melalui CourseRepository.
  /// Setelah INSERT berhasil, memanggil kembali fetchSupabaseCourses() agar data terbaru tampil.
  Future<bool> createSupabaseCourse(Course course) async {
    isCreatingSupabaseCourse = true;
    createSupabaseCourseError = null;
    notifyListeners();

    try {
      await repository.createSupabaseCourse(course);
      debugPrint(
        '[TAHAP 13 Provider] Berhasil menambahkan course ke Supabase: ${course.code} - ${course.title}',
      );
      // Panggil kembali fetchSupabaseCourses() agar daftar data terbaru tampil
      await fetchSupabaseCourses();
      return true;
    } catch (e) {
      createSupabaseCourseError = e.toString();
      debugPrint(
        '[TAHAP 13 Provider] Gagal menambahkan course ke Supabase: $e',
      );
      return false;
    } finally {
      isCreatingSupabaseCourse = false;
      notifyListeners();
    }
  }

  /// Alias method addSupabaseCourse untuk konsistensi pemanggilan
  Future<bool> addSupabaseCourse(Course course) => createSupabaseCourse(course);

  // ===========================================================================
  // TAHAP 14: UPDATE COURSE DI SUPABASE (Mengubah Data di Database)
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  bool isUpdatingSupabaseCourse = false;
  String? updateSupabaseCourseError;

  /// Memperbarui data course di database Supabase melalui CourseRepository.
  /// Setelah UPDATE berhasil, memanggil kembali fetchSupabaseCourses() agar data terbaru tampil.
  Future<bool> updateSupabaseCourse(Course course, {int? id}) async {
    isUpdatingSupabaseCourse = true;
    updateSupabaseCourseError = null;
    notifyListeners();

    try {
      await repository.updateSupabaseCourse(course, id: id);
      debugPrint(
        '[TAHAP 14 Provider] Berhasil memperbarui course di Supabase (ID: ${id ?? course.id}): ${course.title}',
      );
      // Panggil kembali fetchSupabaseCourses() agar daftar data terbaru tampil
      await fetchSupabaseCourses();
      return true;
    } catch (e) {
      updateSupabaseCourseError = e.toString();
      debugPrint(
        '[TAHAP 14 Provider] Gagal memperbarui course di Supabase: $e',
      );
      return false;
    } finally {
      isUpdatingSupabaseCourse = false;
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
