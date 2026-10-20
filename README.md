# Course Explorer v2 — Flutter UI Fundamentals

Aplikasi mobile Flutter untuk eksplorasi course pembelajaran dengan arsitektur bersih (_Clean Architecture_ & _Separation of Concerns_) dan manajemen status terpusat menggunakan **Provider**.

---

## 👤 Identitas Mahasiswa

- **Nama** : Gede Supadma
- **NIM** : 2415051014

---

## 🏛️ Arah Dependency

```
Screen / Widget
       ↓
   Provider
       ↓
  Repository
       ↓
    Service
       ↓
 JSON / Data Source
```

> **Arah Aliran Data & Ketergantungan**:
> `Screen/Widget → Provider → Repository → Service → Data Source`

---

## 📁 Struktur dan Tanggung Jawab Folder

```
lib/
├── main.dart
├── models/
│   └── course.dart
├── services/
│   └── course_service.dart
├── repositories/
│   └── course_repository.dart
├── providers/
│   └── course_provider.dart
├── screens/
│   ├── home_page.dart
│   ├── courses_page.dart
│   ├── course_detail_page.dart
│   ├── favorites_page.dart
│   └── profile_page.dart
└── widgets/
    └── course_card.dart
```

### Penjelasan Tanggung Jawab Tiap Folder:

- `models/` : Menyimpan model data aplikasi seperti `Course` beserta serialisasi JSON (`fromJson`).
- `services/` : Menangani proses pengambilan dan pembacaan data mentah dari sumber data (`rootBundle.loadString` dan `jsonDecode`). Tidak memiliki ketergantungan pada UI widget.
- `repositories/` : Menjadi perantara antara Provider dan Service untuk mengabstraksikan sumber data (memudahkan jika di masa mendatang berganti ke REST API atau database lokal).
- `providers/` : Mengelola state dan logic aplikasi menggunakan `ChangeNotifierProvider`. Mengelola data `courses`, `isLoading`, `error`, dan `favorites` tanpa menyimpan `BuildContext`.
- `screens/` : Menyimpan halaman-halaman utama aplikasi (`HomePage`, `CoursesPage`, `CourseDetailPage`, `FavoritesPage`, `ProfilePage`).
- `widgets/` : Menyimpan komponen UI reusable seperti `CourseCard` yang dapat digunakan di berbagai screen.

---

## 🔍 Hasil Audit Arsitektur (Tahap 16)

1. **Penggunaan `rootBundle` dan `jsonDecode`**:
   - Hanya digunakan secara eksklusif di [`lib/services/course_service.dart`](lib/services/course_service.dart).
   - Tidak ada kebocoran pembacaan JSON langsung pada `screens/`, `widgets/`, atau `providers/`.

2. **Isolasi UI pada `CourseService`**:
   - Bebas dari komponen UI (`Scaffold`, `Text`, dsb.).
   - Murni mengolah data ke dalam objek `List<Course>`.

3. **Isolasi State pada `CourseProvider`**:
   - Tidak menyimpan `BuildContext` sebagai properti state.
   - Mengelola state secara murni: `courses`, `isLoading`, `error`, `favorites`, serta method `toggleFavorite()`, `isFavorite()`, dan `loadCourses()`.

4. **Shared Favorite State**:
   - Status favorit tersinkronisasi secara real-time di seluruh screen (`CoursesPage`, `CourseDetailPage`, dan `FavoritesPage`) melalui `CourseProvider`.

---

## 🚀 Cara Menjalankan Proyek

1. **Unduh dependencies**:

   ```bash
   flutter pub get
   ```

2. **Analisis kode**:

   ```bash
   flutter analyze
   ```

3. **Jalankan pengujian**:

   ```bash
   flutter test
   ```

4. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

## Finalisasi Pertemuan 6

Project Course Explorer v2 telah menyelesaikan implementasi state management
dan arsitektur aplikasi menggunakan Provider, ChangeNotifier, Repository,
Service, serta pemisahan folder berdasarkan tanggung jawab.

Identitas:

- Nama: Gede Supadma
- NIM: 2415051014

Repository:
https://github.com/desuCode835/flutter_ui_fundamentals

## Tahap 1 — Membaca REST Endpoint dan JSON

### Informasi Endpoint

- **Nama API:** JSONPlaceholder
- **URL Endpoint:** https://jsonplaceholder.typicode.com/posts/1
- **HTTP Method:** GET
- **Status Code:** 200 OK
- **Resource:** posts
- **ID Resource:** 1
- **Content-Type:** application/json

### Response Body

```json
{
  "userId": 1,
  "id": 1,
  "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
  "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
}
```

### Identifikasi Field JSON

1. `userId`: menunjukkan ID pengguna yang memiliki post.
2. `id`: menunjukkan ID post.
3. `title`: berisi judul post.
4. `body`: berisi isi atau konten post.

### Catatan Pengamatan

Endpoint diakses menggunakan HTTP method GET dan menghasilkan status code 200 OK. Response body diterima dalam format JSON dan memiliki empat field, yaitu userId, id, title, dan body.

JSONPlaceholder merupakan API dummy untuk latihan. Operasi penulisan data seperti POST, PUT, PATCH, dan DELETE disimulasikan sehingga perubahan tidak disimpan secara permanen di server.

### Identitas Mahasiswa

- **Nama:** Gede Supadma
- **NIM:** 2415051014
- **Kelas:** PTI 5A
