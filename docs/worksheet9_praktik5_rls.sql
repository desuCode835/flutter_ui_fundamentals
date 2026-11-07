-- =============================================================================
-- Nama : Gede Supadma
-- NIM  : 2415051014
-- WORKSHEET 9 - PRAKTIK 5: ROW LEVEL SECURITY (RLS) POLICIES TABEL COURSES
-- =============================================================================
-- Jalankan query SQL ini pada Supabase SQL Editor untuk menerapkan konfigurasi
-- Row Level Security (RLS) dan hak akses berbasis role pengguna (Student, Instructor, Admin).

-- 1. Tambahkan kolom user_id bertipe UUID pada tabel courses jika belum ada
ALTER TABLE public.courses
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- 2. Pastikan Row Level Security (RLS) diaktifkan pada tabel courses
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- 3. Hapus policy lama yang terlalu permisif agar tidak mem-bypass otorisasi
DROP POLICY IF EXISTS "lab_allow_all_courses" ON public.courses;

-- 4. Hapus policy versi lama jika ada untuk mencegah duplikasi
DROP POLICY IF EXISTS "courses_select_authenticated" ON public.courses;
DROP POLICY IF EXISTS "courses_insert_instructor_admin" ON public.courses;
DROP POLICY IF EXISTS "courses_update_instructor_admin" ON public.courses;
DROP POLICY IF EXISTS "courses_delete_instructor_admin" ON public.courses;

-- 5. POLICY SELECT: courses_select_authenticated
--    Hanya pengguna terautentikasi (authenticated) yang dapat membaca course.
--    Student, Instructor, dan Admin yang sudah login dapat membaca seluruh course.
CREATE POLICY "courses_select_authenticated"
ON public.courses
FOR SELECT
TO authenticated
USING (true);

-- 6. POLICY INSERT: courses_insert_instructor_admin
--    - Instructor hanya dapat membuat course jika user_id = auth.uid()
--    - Admin dapat membuat course secara leluasa
--    - Student dilarang membuat course
CREATE POLICY "courses_insert_instructor_admin"
ON public.courses
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
  )
  OR
  (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'instructor'
    )
  )
);

-- 7. POLICY UPDATE: courses_update_instructor_admin
--    - Instructor hanya dapat mengubah course miliknya sendiri (user_id = auth.uid())
--    - Admin dapat mengubah seluruh course
--    - Student dilarang mengubah course
CREATE POLICY "courses_update_instructor_admin"
ON public.courses
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
  )
  OR
  (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'instructor'
    )
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
  )
  OR
  (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'instructor'
    )
  )
);

-- 8. POLICY DELETE: courses_delete_instructor_admin
--    - Instructor hanya dapat menghapus course miliknya sendiri (user_id = auth.uid())
--    - Admin dapat menghapus seluruh course
--    - Student dilarang menghapus course
CREATE POLICY "courses_delete_instructor_admin"
ON public.courses
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
  )
  OR
  (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'instructor'
    )
  )
);

