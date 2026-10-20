// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            // TAHAP 2: PENGUJIAN HTTP GET REST API
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

                            // Tampilkan minimal tiga data hasil API dalam bentuk List<Course>
                            ...courseProvider.posts.take(3).map((item) {
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
                                        item.code, // Identitas turunan POST-$id
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
                                          Text(
                                            'ID: ${item.id ?? '-'} • UserID: ${item.userId ?? '-'}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Menampilkan 3 dari ${courseProvider.posts.length} item List<Course>',
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
