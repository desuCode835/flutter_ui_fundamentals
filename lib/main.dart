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
      title: 'Feedback App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FeedbackPage(),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // GlobalKey untuk Form
  final formKey = GlobalKey<FormState>();

  // Identitas
  static const String namaDefault = 'Gede Supadma';
  static const String nimDefault = '2415051014';

  // Controller
  final TextEditingController namaController = TextEditingController(
    text: namaDefault,
  );

  final TextEditingController nimController = TextEditingController(
    text: nimDefault,
  );

  final TextEditingController komentarController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    komentarController.dispose();
    super.dispose();
  }

  // =========================
  // VALIDASI FORM
  // =========================

  void submitForm() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin mengirim feedback?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                processFeedback();
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // PROSES LOADING
  // =========================

  Future<void> processFeedback() async {
    setState(() {
      isLoading = true;
    });

    // Simulasi proses selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    // SnackBar setelah proses selesai
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feedback berhasil disimpan')));

    // Tampilkan hasil
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Feedback Tersimpan'),
          content: Text(
            'Nama: ${namaController.text}\n'
            'NIM: ${nimController.text}\n'
            'Komentar: ${komentarController.text}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Feedback Praktikum',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Nama: Gede Supadma\n'
                'NIM: 2415051014',
              ),

              const SizedBox(height: 24),

              // =========================
              // NAMA
              // =========================
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // NIM
              // =========================
              TextFormField(
                controller: nimController,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // =========================
              // KOMENTAR
              // =========================
              TextFormField(
                controller: komentarController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  hintText: 'Minimal 5 karakter',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.comment),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Komentar wajib diisi';
                  }

                  if (value.trim().length < 5) {
                    return 'Komentar minimal 5 karakter';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // =========================
              // BUTTON / LOADING
              // =========================
              if (isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Menyimpan feedback...'),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: submitForm,
                  icon: const Icon(Icons.send),
                  label: const Text('Kirim Feedback'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
