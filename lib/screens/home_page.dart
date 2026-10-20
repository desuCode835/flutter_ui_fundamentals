// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ===========================================================================
  // TAHAP 8: DIALOG KONFIRMASI DAN PROSES HTTP DELETE
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Course item,
  ) async {
    // 4. Ketika tombol Delete ditekan, tampilkan AlertDialog konfirmasi
    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Konfirmasi Hapus Course',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: const Text(
                    'Mahasiswa: Gede Supadma • NIM: 2415051014',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menghapus course berikut dari daftar?',
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.code} — ${item.title}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${item.id ?? 1} • SKS: ${item.credits}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '* Catatan: JSONPlaceholder menyimulasikan HTTP DELETE (Status 200/204). '
                  'Setelah berhasil, item dihapus dari state lokal UI.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            // 5. Jika pengguna memilih Batal, jangan lakukan request DELETE atau mengubah daftar
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop('cancel'),
              child: const Text('Batal'),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(dialogCtx).pop('error_test'),
                  icon: const Icon(Icons.error_outline, size: 15),
                  label: const Text(
                    'Uji Error DELETE',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(dialogCtx).pop('confirm'),
                  icon: const Icon(Icons.delete, size: 15),
                  label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    // 5. Jika batal, jangan lakukan request DELETE atau mengubah daftar
    if (result == null || result == 'cancel') {
      return;
    }

    if (!context.mounted) return;

    final provider = context.read<CourseProvider>();
    final targetId = item.id ?? 1;
    final endpoint = result == 'error_test'
        ? 'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test'
        : null;

    // 6. Jika pengguna memilih Hapus, jalankan HTTP DELETE
    final success = await provider.deleteCourse(
      targetId,
      code: item.code,
      endpoint: endpoint,
    );

    if (!context.mounted) return;

    // 6 & 7. Tampilkan SnackBar yang sesuai dengan hasil operasi
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil menghapus course "${item.code} - ${item.title}" via HTTP DELETE (Status 200 OK)! Item telah dihapus dari daftar.',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus course via HTTP DELETE: ${provider.deleteCourseError ?? "Terjadi kesalahan"}',
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer v2')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.school, size: 80, color: Color(0xFF1976D2)),
            const SizedBox(height: 16),
            const Text(
              'Course Explorer v2',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi untuk melihat daftar course '
              'dan informasi pembelajaran terintegrasi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ====================================================
            // IDENTITAS MAHASISWA
            // ====================================================
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade100),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Identitas Mahasiswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Nama: Gede Supadma'),
                    Text('NIM: 2415051014'),
                    Text('Kelas: PTI 5A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ====================================================
            // TAHAP 6: FORM TAMBAH COURSE BARU (HTTP POST)
            // ====================================================
            const CoursePostForm(),
            const SizedBox(height: 20),

            // ====================================================
            // TAHAP 5: STATE UI (LOADING, SUCCESS, EMPTY, ERROR)
            // ====================================================
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              color: Colors.blue.shade50.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.http, color: Color(0xFF1565C0)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tahap 5 — State UI: Loading, Success, Empty, Error',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Endpoint: https://jsonplaceholder.typicode.com/posts',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: courseProvider.isPostsLoading
                              ? null
                              : () {
                                  context.read<CourseProvider>().fetchPosts();
                                },
                          icon: const Icon(Icons.cloud_download),
                          label: const Text('Uji Success (Normal)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: courseProvider.isPostsLoading
                              ? null
                              : () {
                                  context.read<CourseProvider>().fetchPosts(
                                    endpoint: 'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test',
                                  );
                                },
                          icon: const Icon(Icons.error_outline),
                          label: const Text('Uji Error (Endpoint Salah)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: courseProvider.isPostsLoading
                              ? null
                              : () {
                                  context.read<CourseProvider>().fetchPosts(
                                    endpoint: 'https://jsonplaceholder.typicode.com/posts?userId=99999',
                                  );
                                },
                          icon: const Icon(Icons.inbox_outlined),
                          label: const Text('Uji Empty State'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber.shade900,
                            side: BorderSide(color: Colors.amber.shade400),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ====================================================
                    // 1. KONDISI LOADING STATE
                    // ====================================================
                    if (courseProvider.isPostsLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              'Memuat data dari REST API...',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    // ====================================================
                    // 2. KONDISI ERROR STATE DENGAN TOMBOL RETRY
                    // ====================================================
                    else if (courseProvider.postsError != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Gagal Memuat Data',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              courseProvider.postsError!,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 13,
                              ),
                            ),
                            if (courseProvider.lastFetchedUrl != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'URL yang diuji: ${courseProvider.lastFetchedUrl}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            // Tombol Retry: Memanggil ulang proses pengambilan data via Provider
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<CourseProvider>()
                                    .retryFetchPosts();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry (Coba Lagi)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    // ====================================================
                    // 3. KONDISI EMPTY STATE (DATA COURSE BELUM TERSEDIA)
                    // ====================================================
                    else if (courseProvider.isPostsEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.amber.shade800,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Data course belum tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Request berhasil diterima (HTTP 200 OK), namun tidak ada item data yang ditemukan.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<CourseProvider>()
                                    .retryFetchPosts();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Muat Data Normal'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    // ====================================================
                    // 4. KONDISI SUCCESS STATE (DAFTAR DATA REST API)
                    // ====================================================
                    else if (courseProvider.posts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Berhasil (Status 200 OK)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                      Text(
                                        '[TAHAP 5] Berhasil memparsing ${courseProvider.posts.length} Course via CourseApiService',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              'Hasil Data API (Model Course):',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tampilkan minimal tiga data hasil API dalam bentuk List<Course> (Tahap 5 & 7)
                            ...courseProvider.posts.take(5).map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFF90CAF9),
                                        ),
                                      ),
                                      child: Text(
                                        item.code, // Identitas turunan POST-$id atau kode baru
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF0D47A1),
                                            ),
                                          ),
                                          if (item.body != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              item.body!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 8,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color:
                                                        Colors.amber.shade300,
                                                  ),
                                                ),
                                                child: Text(
                                                  '${item.credits} SKS',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.amber.shade900,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'ID: ${item.id ?? '-'} • UserID: ${item.userId ?? '-'}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Tombol Aksi: Edit (Tahap 7) & Delete (Tahap 8)
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        // 1. Tombol Edit pada setiap item course di daftar (Tahap 7)
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // 2. Saat tombol Edit ditekan, tampilkan form yang sudah terisi data course sebelumnya
                                            showDialog(
                                              context: context,
                                              builder: (dialogCtx) =>
                                                  CourseEditDialog(
                                                    course: item,
                                                  ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 13,
                                          ),
                                          label: const Text(
                                            'Edit',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(
                                              0xFF1565C0,
                                            ),
                                            side: BorderSide(
                                              color: Colors.blue.shade300,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        // 3. Tombol Delete pada setiap item course (Tahap 8)
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                context,
                                                item,
                                              ),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 13,
                                          ),
                                          label: const Text(
                                            'Hapus',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                Colors.red.shade700,
                                            side: BorderSide(
                                              color: Colors.red.shade300,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Menampilkan ${courseProvider.posts.length > 5 ? 5 : courseProvider.posts.length} dari ${courseProvider.posts.length} item List<Course>',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    // ====================================================
                    // 5. KONDISI INITIAL STATE (BELUM ADA REQUEST)
                    // ====================================================
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tekan tombol di atas untuk menjalankan pengujian state (Loading, Success, Empty, Error).',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selamat datang di Course Explorer v2'),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('Tampilkan Info'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TAHAP 6: WIDGET FORM TAMBAH COURSE BARU (HTTP POST)
// =============================================================================
// Nama : Gede Supadma
// NIM  : 2415051014
class CoursePostForm extends StatefulWidget {
  const CoursePostForm({super.key});

  @override
  State<CoursePostForm> createState() => _CoursePostFormState();
}

class _CoursePostFormState extends State<CoursePostForm> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _creditsController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _submit({bool simulateError = false}) async {
    // 2. Validasi seluruh field wajib diisi dan credits angka
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = _codeController.text.trim();
    final title = _titleController.text.trim();
    final credits = int.parse(_creditsController.text.trim());

    final newCourse = Course(
      code: code,
      title: title,
      credits: credits,
      status: 'active',
      body: 'Kode: $code • SKS: $credits',
      userId: 1,
    );

    final provider = context.read<CourseProvider>();
    final endpoint = simulateError
        ? 'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test'
        : null;

    final success = await provider.createCourse(newCourse, endpoint: endpoint);

    if (!mounted) return;

    // 5. Tampilkan SnackBar untuk hasil berhasil maupun gagal
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil membuat course "$code - $title" (HTTP 201 Created)! Data ditambahkan ke daftar.',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
      _formKey.currentState!.reset();
      _codeController.clear();
      _titleController.clear();
      _creditsController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membuat course: ${provider.createCourseError ?? "Terjadi kesalahan"}',
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<CourseProvider>().isCreatingCourse;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tahap 6 — HTTP POST: Tambah Course Baru',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Mengirim payload JSON via HTTP POST ke https://jsonplaceholder.typicode.com/posts',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),

              // Field 1: Kode Course
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Course',
                  hintText: 'Misal: MOB06',
                  prefixIcon: Icon(Icons.code),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode course wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Field 2: Judul Course
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Course',
                  hintText: 'Misal: Pemrograman REST API Flutter',
                  prefixIcon: Icon(Icons.book_outlined),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul course wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Field 3: SKS (Credits)
              TextFormField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SKS (Credits)',
                  hintText: 'Misal: 3',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'SKS wajib diisi';
                  }
                  final credits = int.tryParse(value.trim());
                  if (credits == null) {
                    return 'SKS harus berupa angka bulat';
                  }
                  if (credits <= 0) {
                    return 'SKS harus lebih besar dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Action buttons
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: isCreating ? null : () => _submit(),
                    icon: isCreating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      isCreating ? 'Mengirim POST...' : 'Simpan (HTTP POST)',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: isCreating
                        ? null
                        : () => _submit(simulateError: true),
                    icon: const Icon(Icons.error_outline),
                    label: const Text('Uji Error POST'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '* Catatan: REST API JSONPlaceholder mensimulasikan pembuatan resource (HTTP 201 Created). '
                'Hasil POST langsung diperbarui ke daftar di bawah untuk membuktikan integrasi UI.',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TAHAP 7: DIALOG FORM EDIT COURSE (HTTP PUT / PATCH)
// =============================================================================
// Nama : Gede Supadma
// NIM  : 2415051014
class CourseEditDialog extends StatefulWidget {
  final Course course;

  const CourseEditDialog({super.key, required this.course});

  @override
  State<CourseEditDialog> createState() => _CourseEditDialogState();
}

class _CourseEditDialogState extends State<CourseEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;

  @override
  void initState() {
    super.initState();
    // 2. Saat tombol Edit ditekan, tampilkan form yang sudah terisi data course sebelumnya
    _codeController = TextEditingController(text: widget.course.code);
    _titleController = TextEditingController(text: widget.course.title);
    _creditsController = TextEditingController(
      text: widget.course.credits.toString(),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _submit({
    bool simulateError = false,
    bool usePatch = false,
  }) async {
    // 4. Validasi semua field wajib diisi dan credits harus berupa angka
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = _codeController.text.trim();
    final title = _titleController.text.trim();
    final credits = int.parse(_creditsController.text.trim());

    // 3. Pengguna dapat mengubah code, title, dan credits
    final updatedCourse = widget.course.copyWith(
      code: code,
      title: title,
      credits: credits,
      body: 'Kode: $code • SKS: $credits',
    );

    final provider = context.read<CourseProvider>();
    final endpoint = simulateError
        ? 'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test'
        : null;

    // 5. Kirim perubahan menggunakan HTTP PUT atau PATCH melalui service layer
    final success = await provider.updateCourse(
      updatedCourse,
      originalCode: widget.course.code,
      originalId: widget.course.id,
      endpoint: endpoint,
      usePatch: usePatch,
    );

    if (!mounted) return;

    final methodText = usePatch ? 'HTTP PATCH' : 'HTTP PUT';

    // 6 & 7. Tangani respons berhasil dan gagal dengan baik serta tampilkan SnackBar
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil memperbarui course "$code - $title" via $methodText (Status 200 OK)! Daftar course telah diperbarui.',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memperbarui course via $methodText: ${provider.updateCourseError ?? "Terjadi kesalahan"}',
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = context.watch<CourseProvider>().isUpdatingCourse;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit_note, color: Color(0xFF1565C0), size: 28),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Edit Course (Tahap 7)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mahasiswa: Gede Supadma • NIM: 2415051014',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pembaruan resource via HTTP PUT / PATCH (REST API)',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Field 1: Kode Course
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Course',
                    prefixIcon: Icon(Icons.code),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kode course wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Field 2: Judul Course
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Course',
                    prefixIcon: Icon(Icons.book_outlined),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul course wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Field 3: SKS (Credits)
                TextFormField(
                  controller: _creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'SKS (Credits)',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'SKS wajib diisi';
                    }
                    final credits = int.tryParse(value.trim());
                    if (credits == null) {
                      return 'SKS harus berupa angka bulat';
                    }
                    if (credits <= 0) {
                      return 'SKS harus lebih besar dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Text(
                  '* REST API JSONPlaceholder menyimulasikan PUT/PATCH (HTTP 200 OK). '
                  'Perubahan diperbarui ke state lokal agar langsung terlihat di UI.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: isUpdating
                  ? null
                  : () => _submit(simulateError: true, usePatch: false),
              icon: const Icon(Icons.error_outline, size: 16),
              label: const Text('Uji Error PUT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                visualDensity: VisualDensity.compact,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: isUpdating
                  ? null
                  : () => _submit(simulateError: false, usePatch: true),
              icon: const Icon(Icons.bolt, size: 16),
              label: const Text('HTTP PATCH'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
            ElevatedButton.icon(
              onPressed: isUpdating
                  ? null
                  : () => _submit(simulateError: false, usePatch: false),
              icon: isUpdating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 16),
              label: Text(isUpdating ? 'Menyimpan...' : 'HTTP PUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
