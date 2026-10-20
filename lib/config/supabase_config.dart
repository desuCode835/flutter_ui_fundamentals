// Nama : Gede Supadma
// NIM : 2415051014

// =============================================================================
// TAHAP 17: KONFIGURASI SUPABASE & SECURITY HARDENING
// =============================================================================
// Catatan Keamanan:
// 1. Kunci berikut merupakan public anon/publishable key yang aman digunakan di
//    lapisan client Flutter bersama Row Level Security (RLS) di database.
// 2. Secret 'service_role key' TIDAK BOLEH disimpan di dalam aplikasi mobile
//    karena dapat membypass seluruh kebijakan RLS backend.
class SupabaseConfig {
  static const String supabaseUrl = 'https://cgaqznikjramcowlrnct.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_GwoZJ0CcFcHpnnEICDTMQw_E-Va-tio';
}
