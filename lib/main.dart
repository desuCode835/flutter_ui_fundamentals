import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tahap 16 - Debugging',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DebuggingPage(),
    );
  }
}

class DebuggingPage extends StatefulWidget {
  const DebuggingPage({super.key});

  @override
  State<DebuggingPage> createState() => _DebuggingPageState();
}

class _DebuggingPageState extends State<DebuggingPage> {
  final String studentName = 'Gede Supadma';
  final String studentId = '2415051014';

  bool _isNavigating = false;

  void _openDetail() async {
    // Mencegah tombol ditekan berkali-kali
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DetailPage()),
    );

    if (mounted) {
      setState(() {
        _isNavigating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 16 - Debugging')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identitas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama: $studentName',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'NIM: $studentId',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // KASUS A
            const Text(
              'Kasus A - RenderFlex Overflow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info),
                  const SizedBox(width: 8),

                  // Expanded memberikan batas lebar kepada Text
                  // sehingga teks dapat melakukan wrapping.
                  Expanded(
                    child: Text(
                      '$studentId - $studentName - '
                      'teks sangat panjang yang sebelumnya dapat '
                      'menyebabkan RenderFlex overflow pada Row.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // KASUS B
            const Text(
              'Kasus B - ListView dalam Column',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Expanded memberikan batas tinggi kepada ListView.
            SizedBox(
              height: 180,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('Data pembelajaran ${index + 1}'),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // KASUS C
            const Text(
              'Kasus C - Keyboard Overflow',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Form dibuat scrollable agar tetap dapat diakses '
              'ketika keyboard muncul.',
            ),

            const SizedBox(height: 8),

            TextField(
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Komentar',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // KASUS D
            const Text(
              'Kasus D - Navigasi Ganda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Tombol dikunci sementara ketika proses navigasi '
              'sedang berlangsung.',
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isNavigating ? null : _openDetail,
                icon: const Icon(Icons.open_in_new),
                label: Text(
                  _isNavigating ? 'Membuka halaman...' : 'Buka Detail',
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Catatan
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Catatan Debugging',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A: Expanded membatasi lebar Text sehingga '
                      'teks dapat turun ke baris berikutnya.',
                    ),
                    SizedBox(height: 4),
                    Text(
                      'B: ListView membutuhkan batas tinggi agar '
                      'tidak memiliki tinggi tak terbatas.',
                    ),
                    SizedBox(height: 4),
                    Text(
                      'C: SingleChildScrollView memungkinkan halaman '
                      'digeser ketika keyboard muncul.',
                    ),
                    SizedBox(height: 4),
                    Text(
                      'D: Tombol dinonaktifkan sementara agar route '
                      'tidak ter-push berkali-kali.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Kembali'),
        ),
      ),
    );
  }
}
