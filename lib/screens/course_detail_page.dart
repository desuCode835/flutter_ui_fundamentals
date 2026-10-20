// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  Future<void> _showEditDialog(BuildContext context, Course item) async {
    // 3. Hubungkan fitur Edit Course dari halaman detail agar perubahan title, credits, dan status disimpan ke tabel Supabase berdasarkan id.
    final provider = context.read<CourseProvider>();
    final matching = provider.supabaseCourses
        .where((c) => (item.id != null && c.id == item.id) || c.code == item.code)
        .firstOrNull;
    final targetId = item.id ?? matching?.id;

    if (targetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Course "${item.code}" belum memiliki ID di Supabase. Muat data Supabase atau simpan terlebih dahulu.',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    final courseToEdit = item.copyWith(id: targetId);

    await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => SupabaseCourseEditDialog(course: courseToEdit),
    );
  }

  // ===========================================================================
  // TAHAP 15: DIALOG KONFIRMASI DAN PROSES DELETE SUPABASE
  // ===========================================================================
  // Nama : Gede Supadma
  // NIM  : 2415051014
  Future<void> _showDeleteDialog(BuildContext context, Course item) async {
    final provider = context.read<CourseProvider>();
    final matching = provider.supabaseCourses
        .where((c) => (item.id != null && c.id == item.id) || c.code == item.code)
        .firstOrNull;
    final targetId = item.id ?? matching?.id;

    if (targetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Course "${item.code}" belum memiliki ID di Supabase. Muat data Supabase terlebih dahulu.',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    // 5. Sebelum menghapus, tampilkan dialog konfirmasi. Data hanya boleh dihapus jika pengguna menekan tombol konfirmasi.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade700,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Hapus Course (Supabase)',
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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mahasiswa: Gede Supadma • NIM: 2415051014',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFFC62828),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Operasi: DELETE dari tabel courses Supabase',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menghapus course berikut secara permanen dari database Supabase?',
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                ),
                const SizedBox(height: 10),
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
                          color: Color(0xFF004D40),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID Supabase: $targetId • SKS: ${item.credits} • Status: ${item.status}',
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
                  '* Perhatian: Data akan dihapus langsung dari database Supabase berdasarkan kolom ID ($targetId). Tindakan ini tidak dapat dibatalkan.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              icon: const Icon(Icons.delete_forever, size: 16),
              label: const Text('Hapus Permanen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // 2 & 8. Hapus data dari tabel courses berdasarkan ID menggunakan Supabase
    final success = await provider.deleteSupabaseCourse(targetId);

    if (!context.mounted) return;

    // 6 & 7. Refresh daftar course dan tampilkan pesan keberhasilan / error
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil menghapus course "${item.title}" (ID: $targetId) dari database Supabase!',
          ),
          backgroundColor: Colors.teal.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus course dari Supabase: ${provider.deleteSupabaseCourseError ?? "Terjadi kesalahan"}',
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
    final isFavorite = courseProvider.isFavorite(course.code);

    // Ambil data course terbaru dari provider jika sudah diperbarui di Supabase atau lokal
    final currentCourse = courseProvider.supabaseCourses
            .where((c) => (course.id != null && c.id == course.id) || c.code == course.code)
            .firstOrNull ??
        courseProvider.courses
            .where((c) => c.code == course.code)
            .firstOrNull ??
        course;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Detail'),
        actions: [
          // Tombol Edit Course di AppBar
          IconButton(
            onPressed: () => _showEditDialog(context, currentCourse),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Course (Supabase)',
          ),
          // Tombol Hapus Course di AppBar (Tahap 15)
          IconButton(
            onPressed: () => _showDeleteDialog(context, currentCourse),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Hapus Course (Supabase)',
          ),
          IconButton(
            onPressed: () {
              context.read<CourseProvider>().toggleFavorite(currentCourse.code);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            tooltip: isFavorite ? 'Hapus dari Favorite' : 'Tambah ke Favorite',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book, size: 80),
                const Spacer(),
                Chip(
                  avatar: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 18,
                  ),
                  label: Text(
                    isFavorite ? 'Favorit' : 'Bukan Favorit',
                    style: TextStyle(
                      color: isFavorite ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              currentCourse.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Kode: ${currentCourse.code}', style: const TextStyle(fontSize: 17)),
            Text(
              'SKS: ${currentCourse.credits}',
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              'Status: ${currentCourse.status}',
              style: const TextStyle(fontSize: 17),
            ),
            if (currentCourse.id != null) ...[
              Text(
                'Supabase ID: ${currentCourse.id}',
                style: TextStyle(fontSize: 15, color: Colors.teal.shade800),
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              'Mahasiswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Gede Supadma'),
            const Text('NIM: 2415051014'),
            const SizedBox(height: 30),

            // Tombol Edit Course di Supabase
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditDialog(context, currentCourse),
                icon: const Icon(Icons.edit_note),
                label: const Text('Edit Course di Supabase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Hapus Course dari Supabase (Tahap 15)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteDialog(context, currentCourse),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Hapus Course dari Supabase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Favorite
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final wasFav = context.read<CourseProvider>().isFavorite(
                    currentCourse.code,
                  );
                  context.read<CourseProvider>().toggleFavorite(currentCourse.code);

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !wasFav
                            ? 'Course ditambahkan ke favorite'
                            : 'Course dihapus dari favorite',
                      ),
                    ),
                  );
                },
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(
                  isFavorite ? 'Hapus dari Favorite' : 'Tambah ke Favorite',
                ),
                style: isFavorite
                    ? ElevatedButton.styleFrom(foregroundColor: Colors.red)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TAHAP 14: DIALOG EDIT COURSE DI SUPABASE (UPDATE)
// =============================================================================
// Nama : Gede Supadma
// NIM  : 2415051014
class SupabaseCourseEditDialog extends StatefulWidget {
  final Course course;

  const SupabaseCourseEditDialog({super.key, required this.course});

  @override
  State<SupabaseCourseEditDialog> createState() =>
      _SupabaseCourseEditDialogState();
}

class _SupabaseCourseEditDialogState extends State<SupabaseCourseEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course.title);
    _creditsController = TextEditingController(
      text: widget.course.credits.toString(),
    );
    final status = widget.course.status.toLowerCase().trim();
    if (status == 'active' || status == 'planned' || status == 'done') {
      _selectedStatus = status;
    } else {
      _selectedStatus = 'active';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final credits = int.parse(_creditsController.text.trim());
    final status = _selectedStatus.trim();

    final updated = widget.course.copyWith(
      title: title,
      credits: credits,
      status: status,
    );

    final provider = context.read<CourseProvider>();
    final success = await provider.updateSupabaseCourse(
      updated,
      id: widget.course.id,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Berhasil memperbarui course "$title" di database Supabase!',
          ),
          backgroundColor: Colors.teal.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memperbarui course di Supabase: ${provider.updateSupabaseCourseError ?? "Terjadi kesalahan"}',
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating =
        context.watch<CourseProvider>().isUpdatingSupabaseCourse;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit_note, color: Color(0xFF00796B), size: 28),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Edit Course (Supabase)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
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
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mahasiswa: Gede Supadma • NIM: 2415051014',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF00796B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update tabel courses • ID: ${widget.course.id ?? "-"} • Kode: ${widget.course.code}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Field 1: Judul Course (title)
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Course (title)',
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

                // Field 2: SKS (credits)
                TextFormField(
                  controller: _creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'SKS (credits)',
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
                    if (credits == null || credits <= 0) {
                      return 'SKS harus berupa angka bulat > 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Field 3: Status Course (status)
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status Course (status)',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('active (Aktif)'),
                    ),
                    DropdownMenuItem(
                      value: 'planned',
                      child: Text('planned (Rencana)'),
                    ),
                    DropdownMenuItem(
                      value: 'done',
                      child: Text('done (Selesai)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Status course wajib dipilih';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: isUpdating ? null : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          onPressed: isUpdating ? null : _submit,
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
          label: Text(isUpdating ? 'Menyimpan...' : 'Simpan ke Supabase'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
