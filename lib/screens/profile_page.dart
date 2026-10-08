// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 12),
            const Text(
              'Gede Supadma',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text('NIM: 2415051014'),
            const SizedBox(height: 30),
            const FeedbackForm(),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// FEEDBACK FORM
// ======================================================

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController(
    text: 'Gede Supadma',
  );

  final TextEditingController nimController = TextEditingController(
    text: '2415051014',
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

  void submitFeedback() {
    if (!formKey.currentState!.validate()) {
      return;
    }

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
                saveFeedback();
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveFeedback() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feedback berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          TextFormField(
            controller: komentarController,
            maxLines: 4,
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
          const SizedBox(height: 16),
          if (isLoading)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Menyimpan feedback...'),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: submitFeedback,
              icon: const Icon(Icons.send),
              label: const Text('Kirim Feedback'),
            ),
        ],
      ),
    );
  }
}
