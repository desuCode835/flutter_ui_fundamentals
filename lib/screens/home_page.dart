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
                            'Tahap 2 — Pengujian HTTP GET',
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
                          label: const Text('Uji HTTP GET (Normal)'),
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
                                    endpoint:
                                        'https://jsonplaceholder.typicode.com/invalid_posts_endpoint_for_test',
                                  );
                                },
                          icon: const Icon(Icons.error_outline),
                          label: const Text('Uji Error (Endpoint Salah)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade300),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Indikator Status & Hasil
                    if (courseProvider.isPostsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Mengirim HTTP GET ke REST API...'),
                          ],
                        ),
                      )
                    else if (courseProvider.postsError != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.cancel,
                                    color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Error Tertangkap:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              courseProvider.postsError!,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 13,
                              ),
                            ),
                            if (courseProvider.lastFetchedUrl != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'URL: ${courseProvider.lastFetchedUrl}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else if (courseProvider.posts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green.shade700, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'Berhasil (Status 200 OK)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '[TAHAP 2] Berhasil mengambil ${courseProvider.posts.length} post dari REST API',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Contoh judul post #1: "${courseProvider.posts.first['title']}"',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      )
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
                            Icon(Icons.info_outline,
                                color: Colors.grey, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tekan tombol di atas untuk menjalankan HTTP GET request.',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
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

