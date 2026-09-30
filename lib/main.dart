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
      title: 'Form Feedback',
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
  // GlobalKey untuk mengontrol Form
  final formKey = GlobalKey<FormState>();

  // Konstanta identitas
  static const String namaDefault = 'Gede Supadma';
  static const String nimDefault = '2415051014';

  // Controller untuk mengambil isi input
  final TextEditingController namaController = TextEditingController(
    text: namaDefault,
  );

  final TextEditingController nimController = TextEditingController(
    text: nimDefault,
  );

  final TextEditingController komentarController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    komentarController.dispose();
    super.dispose();
  }

  // Fungsi validasi dan submit
  void submitForm() {
    if (formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback berhasil dikirim')),
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Hasil Feedback'),
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
  }

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
              // FIELD NAMA
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
              // FIELD NIM
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
              // FIELD KOMENTAR
              // =========================
              TextFormField(
                controller: komentarController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  hintText: 'Tulis komentar minimal 5 karakter',
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
              // BUTTON SUBMIT
              // =========================
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
