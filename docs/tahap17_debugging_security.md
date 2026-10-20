# Dokumentasi Tahap 17 — Error Handling & Security Hardening Dasar

**Proyek:** Course Data Manager (`flutter_ui_fundamentals`)  
**Mata Kuliah:** Pemrograman Mobile / Flutter UI Fundamentals  
**Identitas Mahasiswa:**
- **Nama:** Gede Supadma
- **NIM:** 2415051014
- **Kelas:** PTI 5A

---

## 1. Ringkasan Tahap 17

Tahap 17 berfokus pada penguatan keandalan (*resilience*), penanganan error terstruktur (*graceful error handling*), dan audit keamanan (*security hardening*) pada arsitektur aplikasi Flutter yang mengintegrasikan REST API JSONPlaceholder dan Database Supabase.

Aplikasi dirancang agar:
1. Tidak mengalami crash saat menghadapi kegagalan jaringan, timeout, atau data tidak valid.
2. Memberikan pesan error yang jelas dan mudah dipahami pengguna (*user-friendly*), serta menyediakan tombol coba lagi (*retry*).
3. Melindungi rahasia kredensial (*secrets*) dan menerapkan prinsip *least privilege* (hanya menggunakan anon/publishable key, bukan `service_role key`).
4. Memvalidasi data sebelum dikirim ke backend dan menangani penolakan database (RLS, constraint) secara elegan.

---

## 2. Penanganan Kasus Error (Kasus A – E)

### Kasus A — HTTP 404 & Non-Success Response (REST API)
- **Masalah:** Request HTTP GET/PUT/POST/DELETE ke REST API mengembalikan kode status bukan 200/201/204 (misalnya HTTP 404 Not Found atau HTTP 500 Server Error).
- **Implementasi:**
  - Pada `CourseApiService`, dilakukan pemeriksaan status code respons sebelum memproses body.
  - Untuk HTTP 404, dilempar exception dengan pesan jelas:  
    `Resource tidak ditemukan (HTTP 404). Silakan periksa URL endpoint atau coba lagi.`
  - Untuk HTTP 500+, dilempar pesan:  
    `Server mengalami gangguan internal (HTTP <status>). Silakan coba beberapa saat lagi.`
  - Pada `CourseProvider`, status `isPostsLoading` diatur kembali ke `false`, pesan error disimpan di `postsError`, dan state daftar data lokal sebelumnya tidak dihapus secara sepihak.
  - Tampilan UI di `HomePage` menampilkan status error berwarna merah dengan tombol **Retry (Coba Lagi)** yang memanggil ulang `retryFetchPosts()`.
- **Cara Pengujian:**
  - Jalankan tombol **Uji Error (Endpoint Salah)** pada form Tahap 5 di aplikasi, atau
  - Jalankan automated test: `test/tahap17_error_handling_security_test.dart` (Group: Kasus A).

---

### Kasus B — Network Failure & Connection Timeout
- **Masalah:** Kehilangan koneksi internet, server tidak dapat dijangkau (*socket exception*), DNS lookup gagal, atau koneksi menggantung (*timeout*).
- **Implementasi:**
  - Ditambahkan batas waktu standar pada semua panggilan jaringan: `.timeout(const Duration(seconds: 15))`.
  - Exception `TimeoutException` ditangkap dan diterjemahkan menjadi pesan:  
    `Waktu koneksi habis (Timeout). Server tidak merespons dalam waktu yang ditentukan.`
  - Exception `ClientException` dan `SocketException` (misal *Failed host lookup*, *Connection refused*) diterjemahkan menjadi pesan:  
    `Gagal terhubung ke jaringan/server. Periksa koneksi internet Anda lalu tekan coba lagi.`
  - Status kegagalan koneksi tidak dianggap sebagai data kosong (*empty state*), melainkan error state dengan tombol retry.
- **Cara Pengujian:**
  - Jalankan automated test: `test/tahap17_error_handling_security_test.dart` (Group: Kasus B).
  - Pada emulator/device fisik, matikan koneksi Wi-Fi/Data Seluler lalu tekan tombol **Muat Data Supabase** atau **Uji Success (Normal)**.

---

### Kasus C — JSON Mapping Error & Type Validation
- **Masalah:** Struktur respons JSON dari API atau database memiliki field bernilai null, key hilang, atau tipe data yang tidak sesuai (misal: field `code` bernilai integer atau `credits` bernilai string non-angka).
- **Implementasi:**
  - Pada `Course.fromJson` dan `Course.fromApiJson`, diterapkan validasi tipe eksplisit untuk setiap field:
    - Field `code`: divalidasi harus String. Jika menerima tipe lain, dilempar `FormatException` dengan detail tipe yang diterima.
    - Field `title`: divalidasi harus String.
    - Field `credits`: dikonversi secara aman jika bernilai `num` atau `String` representasi angka bulat. Jika tidak dapat diubah ke integer, dilempar `FormatException` deskriptif.
    - Field `id` dan `userId`: divalidasi bertipe numerik.
  - Pendekatan ini menghindari pengabaian error secara diam-diam (*silent failure*) dan mempermudah pelacakan *bug* data.
- **Cara Pengujian:**
  - Jalankan automated test: `test/tahap17_error_handling_security_test.dart` (Group: Kasus C).

---

### Kasus D — Supabase Row Level Security (RLS) & Permission Denied
- **Masalah:** Operasi SELECT, INSERT, UPDATE, atau DELETE ditolak oleh kebijakan keamanan tabel database Supabase (*Row Level Security*), menghasilkan `PostgrestException` dengan kode `42501`.
- **Implementasi:**
  - Pada `CourseSupabaseService`, setiap panggilan database dibungkus dalam blok try-catch yang secara spesifik mendeteksi `PostgrestException`.
  - Kode error PostgreSQL `42501` atau pesan yang mengandung `row-level security` / `permission denied` dipetakan ke pesan pengguna yang aman:  
    `Akses database ditolak oleh kebijakan keamanan RLS (Row Level Security). Operasi tidak diizinkan.`
  - Kebijakan RLS di database tetap aktif (*enabled*) sebagai garis pertahanan utama di sisi server; aplikasi tidak mencoba menonaktifkan RLS dan tidak menggunakan `service_role key`.
- **Cara Pengujian:**
  - Jalankan automated test: `test/tahap17_error_handling_security_test.dart` (Group: Kasus D).
  - Pengujian integrasi mandiri di `test/tahap16_supabase_crud_test.dart`.

---

### Kasus E — Duplicate & Invalid Data Validation
- **Masalah:** Pengguna memasukkan data yang tidak valid (kode kosong, judul kosong, SKS $\le 0$, status di luar pilihan) atau memasukkan data yang melanggar constraint database (kode duplikat, check constraint).
- **Implementasi:**
  - **Validasi UI:** `TextFormField` pada `home_page.dart` dan `course_detail_page.dart` memiliki validator untuk memastikan field tidak kosong, SKS berupa angka $> 0$, dan status dipilih dari dropdown.
  - **Validasi Service Layer:** Method `validateCourse(Course course, {bool isUpdate = false})` pada `CourseSupabaseService` memverifikasi integritas data sebelum query dikirim ke Supabase:
    - Kode course tidak boleh kosong atau hanya spasi.
    - Judul course tidak boleh kosong atau hanya spasi.
    - SKS harus berupa angka bulat $> 0$.
    - Status harus salah satu dari: `'planned'`, `'active'`, `'done'`.
    - Operasi UPDATE wajib menyertakan ID yang valid.
  - **Penanganan Constraint Database:**
    - Kode PostgreSQL `23505` (unique violation) dipetakan ke:  
      `Data duplikat: Course dengan kode tersebut sudah terdaftar di database Supabase.`
    - Kode PostgreSQL `23514` (check constraint violation) dipetakan ke:  
      `Data tidak valid: Nilai field melanggar batasan tabel database (status harus planned/active/done atau SKS > 0).`
- **Cara Pengujian:**
  - Jalankan automated test: `test/tahap17_error_handling_security_test.dart` (Group: Kasus E).
  - Masukkan SKS 0 atau kosongkan judul pada form aplikasi, lalu tekan simpan; amati feedback visual.

---

## 3. Security Checklist & Temuan Audit

| No | Poin Pemeriksaan Keamanan | Status | Penjelasan & Bukti |
|:--:|:--------------------------|:------:|:-------------------|
| 1 | **Tidak ada `service_role key` di aplikasi** | **LULUS** | Aplikasi hanya menggunakan `supabaseAnonKey` (`sb_publishable_...`). Tidak ada `service_role key` di seluruh file proyek. |
| 2 | **Tidak ada password atau personal access token** | **LULUS** | Seluruh file di `lib/` dan `test/` telah diaudit bebas dari password hardcoded dan token pribadi. |
| 3 | **File `.env` tidak terlacak oleh Git** | **LULUS** | File `.gitignore` telah diperbarui dengan aturan `.env`, `.env.*`, `*.env`, dan `*.secret`. `git ls-files` mengonfirmasi tidak ada file `.env` terlacak. |
| 4 | **Kredensial rahasia tidak tercetak di log** | **LULUS** | `debugPrint` hanya mencetak kode course, judul, endpoint URL umum, dan status kode tanpa mencetak header otentikasi atau kunci rahasia. |
| 5 | **Row Level Security (RLS) Aktif di Database** | **LULUS** | Tabel `public.courses` memiliki `ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;` dengan policy `lab_allow_all_courses` yang terkontrol. |
| 6 | **Validasi Ganda (Client & Backend)** | **LULUS** | Validasi form di UI mencegah input cacat; service layer memvalidasi parameter sebelum transmisi; database menegakkan constraint NOT NULL dan CHECK `status IN ('planned', 'active', 'done')`. |
| 7 | **Pemisahan Kunci Anon vs Service Role** | **LULUS** | Anon key bersifat publik untuk konsumsi mobile client via RLS. Service role key yang berhak bypass RLS disimpan eksklusif di dashboard Supabase milik admin. |

---

## 4. Hasil Pengujian Otomatis

Seluruh pengujian dijalankan pada lingkungan lokal dan menghasilkan status bersih:

1. **Hasil `flutter analyze`:**
   ```text
   Analyzing flutter_ui_fundamentals...
   No issues found! (ran in 5.8s)
   ```

2. **Hasil `flutter test`:**
   ```text
   00:09 +45: All tests passed!
   ```
   Daftar pengujian yang berhasil dilewati:
   - `test/course_model_test.dart` (Model, mapping, local data, API json)
   - `test/tahap7_update_course_test.dart` (HTTP PUT & PATCH)
   - `test/tahap8_delete_course_test.dart` (HTTP DELETE)
   - `test/tahap9_repository_test.dart` (Repository layer)
   - `test/widget_test.dart` (Smoke test widget & identitas mahasiswa)
   - `test/tahap16_supabase_crud_test.dart` (Lifecycle CREATE, READ, UPDATE, DELETE Supabase asli)
   - `test/tahap17_error_handling_security_test.dart` (Pengujian lengkap Kasus A–E dan security checklist)

---

## 5. Panduan Pengambilan Screenshot Manual untuk Laporan Praktikum

Mahasiswa dapat mengambil screenshot berikut pada emulator/device untuk melengkapi laporan praktikum:

1. **Screenshot 1 — Identitas Mahasiswa & Halaman Utama:**
   - Buka aplikasi pada emulator/device.
   - Ambil screenshot halaman utama yang menampilkan kartu **Identitas Mahasiswa: Gede Supadma • NIM: 2415051014**.

2. **Screenshot 2 — Kasus A: Simulasi Error HTTP 404:**
   - Pada kartu Tahap 5, tekan tombol **Uji Error (Endpoint Salah)**.
   - Ambil screenshot saat container error berwarna merah muncul dengan pesan `Gagal Memuat Data`, URL uji yang salah, dan tombol **Retry (Coba Lagi)**.

3. **Screenshot 3 — Kasus B: Empty / Retry State:**
   - Tekan tombol **Uji Empty State** atau matikan koneksi internet untuk melihat pesan error jaringan.
   - Ambil screenshot tampilan pesan error beserta tombol retry.

4. **Screenshot 4 — Kasus D & E: Form Validasi & Dialog Konfirmasi Supabase:**
   - Buka form **Tambah Course Baru** atau buka halaman detail lalu tekan **Edit Course di Supabase**.
   - Kosongkan salah satu field lalu tekan simpan untuk melihat pesan validasi merah.
   - Tekan tombol **Hapus Course dari Supabase** untuk menampilkan dialog konfirmasi bertuliskan identitas **Gede Supadma - 2415051014** sebelum penghapusan dieksekusi.

---

## 6. Tindakan Manual di Dashboard Supabase (Opsional)

Jika ingin menguji penolakan RLS (Kasus D) secara visual langsung di dashboard Supabase:
1. Buka dashboard Supabase pada proyek `cgaqznikjramcowlrnct`.
2. Masuk ke menu **Authentication** $\rightarrow$ **Policies** $\rightarrow$ tabel `courses`.
3. Nonaktifkan sementara policy `lab_allow_all_courses` atau ubah menjadi `FOR SELECT USING (false)`.
4. Buka aplikasi pada emulator dan tekan **Muat Data Supabase**.
5. Amati pesan error di aplikasi:  
   `Akses database ditolak oleh kebijakan keamanan RLS (Row Level Security)...`
6. **Penting:** Setelah pengujian manual selesai, aktifkan kembali policy `lab_allow_all_courses` seperti semula di dashboard.
