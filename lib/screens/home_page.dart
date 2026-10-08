// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.school, size: 90),
            const SizedBox(height: 20),
            const Text(
              'Course Explorer',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi untuk melihat daftar course '
              'dan informasi pembelajaran.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Identitas Mahasiswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Nama: Gede Supadma'),
                    Text('NIM: 2415051014'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selamat datang di Course Explorer'),
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
