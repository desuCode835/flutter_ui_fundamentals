import 'package:flutter/material.dart';

const String studentName = 'Gede Supadma';
const String studentId = '2415051014';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Stage4Page(),
    );
  }
}

class Stage4Page extends StatelessWidget {
  const Stage4Page({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = [
      'Dart',
      'Flutter',
      'UI Design',
      'Git',
      'Firebase',
      'Database',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 4 - Expanded & Wrap')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nama: Gede Supadma',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('NIM: 2415051014', style: TextStyle(fontSize: 18)),

            const SizedBox(height: 24),

            const Text(
              'Pembagian Panel 2:1',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 120,
                    alignment: Alignment.center,
                    color: Colors.blue.shade200,
                    child: const Text(
                      'Panel A\nFlex 2',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Container(
                    height: 120,
                    alignment: Alignment.center,
                    color: Colors.orange.shade200,
                    child: const Text(
                      'Panel B\nFlex 1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Skills',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
