# Course Explorer v2 - Flutter UI Fundamentals

Aplikasi mobile berbasis Flutter untuk manajemen dan eksplorasi data course/mata kuliah pembelajaran. Proyek ini menerapkan arsitektur bersih (*Clean Architecture* & *Separation of Concerns*), manajemen status terpusat menggunakan **Provider**, integrasi **REST API** (JSONPlaceholder), dan persistensi database **Supabase** (PostgreSQL).

---

## Identitas Mahasiswa

- **Nama** : Gede Supadma
- **NIM** : 2415051014
- **Kelas** : PTI 5A
- **Repository**: https://github.com/desuCode835/flutter_ui_fundamentals

---

## Fitur Utama

1. **Katalog & Daftar Course:**
   - Menampilkan daftar course dari aset lokal (`student_data.json`), REST API JSONPlaceholder, dan database Supabase (tabel `courses`).
   - Tampilan responsif yang mendukung orientasi layar ponsel hingga tablet/desktop dengan `NavigationRail`.

2. **Detail Course & Status Pembelajaran:**
   - Halaman detail komprehensif menampilkan kode, judul, jumlah SKS, status pembelajaran (`active`, `planned`, `done`), serta ID referensi.
   - Identitas mahasiswa (Nama dan NIM) tertera jelas pada tampilan antarmuka aplikasi.

3. **Sistem Favorit (Shared State):**
   - Menandai dan menghapus course favorit secara instan.
   - Sinkronisasi status favorit secara real-time antar halaman (`CoursesPage`, `CourseDetailPage`, dan `FavoritesPage`) via `CourseProvider`.

4. **Operasi CRUD Database Supabase:**
   - **CREATE / INSERT:** Form input data course baru langsung tersimpan permanen ke database Supabase dengan validasi input.
   - **READ / SELECT:** Membaca data secara berurutan berdasarkan ID dari tabel `courses`.
   - **UPDATE / EDIT:** Mengubah judul, SKS, dan status course di database Supabase berdasarkan ID course.
   - **DELETE:** Menghapus course dari tabel Supabase berdasarkan ID dengan dialog konfirmasi sebelum data dihapus secara permanen.

5. **Penanganan Status UI & Ketahanan Aplikasi:**
   - Penanganan 4 kondisi UI: *Loading state*, *Success state*, *Empty state*, dan *Error state*.
   - Fitur coba lagi (*Retry*) saat terjadi kegagalan jaringan atau timeout.
   - Notifikasi feedback visual berupa *SnackBar* untuk setiap keberhasilan dan kegagalan operasi.

---

## Teknologi yang Digunakan

- **Framework:** Flutter (Dart SDK)
- **State Management:** Provider (`ChangeNotifier`, `ChangeNotifierProvider`, `Consumer` / `context.watch`)
- **Backend & Database:** Supabase (`supabase_flutter` - PostgreSQL)
- **REST API Client:** HTTP (`package:http/http.dart`)
- **Linting & Code Quality:** `flutter_lints`

---

## Arsitektur Aplikasi

Aplikasi menerapkan pola *Separation of Concerns* dengan aliran data dan ketergantungan yang terstruktur:

```
[ Screen / Widget Layer ]
           |
           v
[ Provider Layer (State Management) ]
           |
           v
[ Repository Layer (Single Source of Truth) ]
           |
           v
[ Service / Data Source Layer ]
           |
           v
[ Backend (Supabase / REST API / Local JSON) ]
```

### Struktur File dan Tanggung Jawab

- **`lib/models/course.dart`**
  Model data utama `Course` dengan properti `code`, `title`, `credits`, `status`, `id`, `userId`, dan `body`. Dilengkapi factory constructor `fromJson()` dan `fromApiJson()` dengan validasi tipe data yang aman (`FormatException`), method `toJson()` untuk serialisasi, dan `copyWith()` untuk imutabilitas data.

- **`lib/providers/course_provider.dart`**
  Pengelola state terpusat (*ChangeNotifier*). Menyimpan state `courses`, `posts`, `supabaseCourses`, status `isLoading`, pesan `error`, dan `favorites`. Provider tidak mengakses database atau HTTP secara langsung, melainkan mendelegasikannya ke repository.

- **`lib/repositories/course_repository.dart`**
  Lapisan perantara (*Repository Pattern*) sebagai *single source of truth*. Mengabstraksikan sumber data dari lapisan UI/Provider dan menyalurkan request ke service yang sesuai (`CourseService`, `CourseApiService`, atau `CourseSupabaseService`).

- **`lib/services/course_api_service.dart`**
  Service layer komunikasi HTTP dengan REST API JSONPlaceholder (`/posts`). Menangani operasi GET, POST, PUT, PATCH, dan DELETE, dilengkapi batas waktu (*timeout*), deteksi kegagalan jaringan, dan penanganan status code HTTP (404, 500).

- **`lib/services/course_service.dart`**
  Service layer untuk membaca dataset awal secara lokal dari aset `assets/data/student_data.json` menggunakan `rootBundle` dan `jsonDecode`.

- **`lib/services/course_supabase_service.dart`**
  Service layer untuk integrasi database Supabase pada tabel `courses`. Menangani operasi SELECT, INSERT, UPDATE, dan DELETE via `SupabaseClient` dengan pra-validasi data model dan pemetaan error PostgreSQL/RLS.

- **`lib/config/supabase_config.dart`**
  Menyimpan konfigurasi URL proyek Supabase dan anon/publishable key untuk akses client.

---

## Backend dan Sumber Data

1. **REST API (JSONPlaceholder):**
   - Digunakan untuk latihan integrasi networking dan konsep RESTful API.
   - Endpoint dasar: `https://jsonplaceholder.typicode.com/posts`
   - **PENTING (Simulasi Operasi Tulis):** JSONPlaceholder merupakan REST API tiruan (*dummy mock server*). Seluruh operasi modifikasi data seperti **POST, PUT, PATCH, dan DELETE hanya disimulasikan** berhasil oleh server (mengembalikan respons sukses dengan status code 200/201), namun perubahannya **TIDAK TERSIMPAN PERMANEN** di server JSONPlaceholder. State lokal UI disinkronkan hanya untuk keperluan demonstrasi interaksi pengguna.

2. **Database Supabase (PostgreSQL):**
   - Digunakan untuk penyimpanan data riil secara persisten pada tabel `public.courses`.
   - Skema tabel mencakup kolom: `id` (Primary Key, auto-increment), `code` (TEXT), `title` (TEXT), `credits` (INTEGER), `status` (TEXT dengan CHECK constraint: `planned`, `active`, `done`), dan `created_at` (TIMESTAMPTZ).
   - Seluruh perubahan data (tambah, ubah, hapus) tersimpan permanen di cloud database Supabase.

---

## Informasi Tahap 1 - Observasi Endpoint REST API

Sebagai bagian dari pembelajaran awal integrasi data (Tahap 1), telah dilakukan pengujian endpoint tunggal JSONPlaceholder:

- **Nama API:** JSONPlaceholder
- **URL Endpoint:** `https://jsonplaceholder.typicode.com/posts/1`
- **HTTP Method:** GET
- **Status Code:** 200 OK
- **Struktur Response:**
  ```json
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  }
  ```
- **Field Kunci:** `userId` (ID pemilik post), `id` (ID resource), `title` (judul post), dan `body` (konten post).
- **Hasil:** Berhasil dipetakan ke dalam objek Dart `Course` menggunakan `Course.fromApiJson` dengan identitas turunan `code: POST-1`.

---

## Pengujian dan Pemeriksaan Kode

Proyek telah melalui audit kualitas kode (*code analysis*) dan pengujian otomatis (*unit & widget tests*):

1. **Analisis Statis Kode (`flutter analyze`):**
   Lolos tanpa error dan tanpa peringatan lint (*0 issues*).

2. **Pengujian Otomatis (`flutter test`):**
   Seluruh suite pengujian (45 pengujian) lolos dengan status sukses:
   - `test/course_model_test.dart`: Validasi parsing JSON model, data lokal, dan REST API.
   - `test/tahap7_update_course_test.dart`: Pengujian HTTP PUT dan PATCH.
   - `test/tahap8_delete_course_test.dart`: Pengujian simulasi HTTP DELETE dan isolasi state UI.
   - `test/tahap9_repository_test.dart`: Pengujian abstraksi Repository Pattern.
   - `test/widget_test.dart`: Smoke test widget dasar dan verifikasi identitas mahasiswa.
   - `test/tahap16_supabase_crud_test.dart`: Pengujian siklus hidup CRUD Supabase (SELECT, INSERT, UPDATE, DELETE).
   - `test/tahap17_error_handling_security_test.dart`: Pengujian komprehensif penanganan error Kasus A - E:
     - **Kasus A:** Penanganan HTTP 404 & 500 pada REST API.
     - **Kasus B:** Penanganan TimeoutException dan SocketException (offline/jaringan mati).
     - **Kasus C:** Penanganan FormatException pada payload data JSON yang rusak.
     - **Kasus D:** Pengujian pemetaan error RLS menggunakan **simulasi error `PostgrestException` berkode `42501`** (bukan pengujian penolakan akses langsung ke database riil).
     - **Kasus E:** Validasi data input lokal sebelum request dikirim ke database.
     - Verifikasi checklist keamanan (konfigurasi `.gitignore` dan pemisahan kunci API).

---

## Catatan Keamanan dan Pembatasan Lingkungan (Security Notes)

1. **Pemisahan Kunci Anon vs Service Role:**
   - Aplikasi client Flutter **hanya** menggunakan `anon / publishable key` yang memang diperuntukkan bagi konsumsi publik client-side.
   - **DILARANG KERAS** memasukkan `service_role key` ke dalam aplikasi mobile client, karena kunci tersebut memiliki hak akses administratif penuh yang dapat membypass seluruh aturan database.

2. **Kebijakan Row Level Security (RLS) - Status Praktikum:**
   - Row Level Security (RLS) pada tabel `public.courses` telah diaktifkan di Supabase.
   - Namun, kebijakan akses saat ini (`lab_allow_all_courses`) masih dibuat **bersifat permisif** (`FOR ALL TO anon, authenticated USING (true) WITH CHECK (true)`) semata-mata untuk memudahkan proses pembelajaran dan pengujian praktikum di lingkungan laboratorium.
   - **PENTING:** Konfigurasi database saat ini **BELUM COCOK dan BELUM SIAP UNTUK LINGKUNGAN PRODUKSI**. Aplikasi ini **TIDAK mengklaim bahwa database sudah aman untuk produksi**.
   - Untuk implementasi produksi nyata di masa mendatang, kebijakan RLS wajib diperketat dengan menerapkan:
     - Autentikasi pengguna nyata via Supabase Auth (`auth.uid()`).
     - Pembatasan izin tulis (INSERT, UPDATE, DELETE) hanya untuk pemilik data atau akun berwenang.
     - Audit berkala terhadap permission role database.

3. **Pencegahan Kebocoran Kredensial:**
   - File `.gitignore` telah dikonfigurasi untuk mencegah commit file rahasia seperti `.env`, `.env.*`, `*.env`, dan `*.secret`.
   - Tidak ada nilai API key rahasia, password, token pribadi, atau kredensial rahasia yang dicantumkan dalam dokumentasi ini maupun di-hardcode sembarangan.

---

## Cara Instalasi dan Menjalankan Aplikasi

Pastikan Flutter SDK (versi 3.x atau terbaru) telah terpasang di sistem Anda.

1. **Clone repository:**
   ```bash
   git clone https://github.com/desuCode835/flutter_ui_fundamentals.git
   cd flutter_ui_fundamentals
   ```

2. **Unduh dependencies:**
   ```bash
   flutter pub get
   ```

3. **Jalankan analisis kode:**
   ```bash
   flutter analyze
   ```

4. **Jalankan pengujian otomatis:**
   ```bash
   flutter test
   ```

5. **Jalankan aplikasi pada emulator atau perangkat:**
   ```bash
   flutter run
   ```
