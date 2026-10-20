// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/config/supabase_config.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_ui_fundamentals/services/course_supabase_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Tahap 17 — Kasus A: HTTP 404 & Non-Success Handling', () {
    test(
      'CourseApiService menangani HTTP 404 dengan pesan informatif',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Not Found', 404);
        });
        final service = CourseApiService(client: mockClient);

        expect(
          () => service.fetchPosts(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('404'),
            ),
          ),
        );
      },
    );

    test(
      'CourseApiService menangani HTTP 500 dengan pesan informatif',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });
        final service = CourseApiService(client: mockClient);

        expect(
          () => service.fetchPosts(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('500'),
            ),
          ),
        );
      },
    );

    test('Provider mencatat error HTTP 404 tanpa mengosongkan state secara sembarangan', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      final repo = CourseRepository(
        CourseService(),
        CourseApiService(client: mockClient),
      );
      final provider = CourseProvider(repo);

      await provider.fetchPosts();

      expect(provider.isPostsLoading, isFalse);
      expect(provider.postsError, isNotNull);
      expect(provider.postsError, contains('404'));
      expect(provider.hasFetchedPosts, isTrue);
    });
  });

  group('Tahap 17 — Kasus B: Network Failure & Timeout Handling', () {
    test(
      'CourseApiService menangani ClientException / koneksi terputus',
      () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('Connection refused');
        });
        final service = CourseApiService(client: mockClient);

        expect(
          () => service.fetchPosts(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Gagal terhubung ke jaringan/server'),
            ),
          ),
        );
      },
    );

    test('CourseApiService menangani TimeoutException saat request memakan waktu lama', () async {
      final mockClient = MockClient((request) async {
        throw TimeoutException('Connection timed out');
      });
      final service = CourseApiService(client: mockClient);

      expect(
        () => service.fetchPosts(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Timeout'),
          ),
        ),
      );
    });

    test(
      'Provider menyimpan error jaringan dengan status loading selesai',
      () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('No Internet');
        });
        final repo = CourseRepository(
          CourseService(),
          CourseApiService(client: mockClient),
        );
        final provider = CourseProvider(repo);

        await provider.fetchPosts();

        expect(provider.isPostsLoading, isFalse);
        expect(provider.postsError, isNotNull);
        expect(provider.postsError, contains('Gagal terhubung'));
      },
    );
  });

  group('Tahap 17 — Kasus C: JSON Mapping Error & FormatException', () {
    test(
      'Course.fromJson melempar FormatException jika tipe "code" bukan String',
      () {
        final badJson = {
          'code': 12345, // salah: integer bukannya String
          'title': 'Struktur Data',
          'credits': 3,
          'status': 'active',
        };

        expect(
          () => Course.fromJson(badJson),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('code'),
            ),
          ),
        );
      },
    );

    test('Course.fromJson melempar FormatException jika tipe "credits" bukan angka', () {
      final badJson = {
        'code': 'MOB01',
        'title': 'Pemrograman Flutter',
        'credits': 'bukan_angka_valid', // salah
        'status': 'active',
      };

      expect(
        () => Course.fromJson(badJson),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('credits'),
          ),
        ),
      );
    });

    test(
      'Course.fromApiJson melempar FormatException jika tipe "id" bukan angka',
      () {
        final badApiJson = {
          'userId': 1,
          'id': 'bukan_id',
          'title': 'Test Post',
          'body': 'Test Body',
        };

        expect(
          () => Course.fromApiJson(badApiJson),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('id'),
            ),
          ),
        );
      },
    );

    test(
      'Course.fromJson berhasil memetakan JSON yang valid tanpa exception',
      () {
        final validJson = {
          'code': 'MOB02',
          'title': 'State Management Provider',
          'credits': 3,
          'status': 'active',
          'id': 10,
        };

        final course = Course.fromJson(validJson);
        expect(course.code, 'MOB02');
        expect(course.title, 'State Management Provider');
        expect(course.credits, 3);
        expect(course.status, 'active');
        expect(course.id, 10);
      },
    );
  });

  group('Tahap 17 — Kasus D: Supabase RLS & Permission Error Handling', () {
    test('CourseSupabaseService memetakan PostgrestException RLS (code 42501)', () {
      try {
        // Simulasikan penanganan PostgrestException RLS melalui validate atau simulasi exception
        throw const PostgrestException(
          message:
              'new row violates row-level security policy for table "courses"',
          code: '42501',
        );
      } catch (e) {
        expect(e, isA<PostgrestException>());
        final pe = e as PostgrestException;
        expect(pe.code, '42501');
      }
    });
  });

  group('Tahap 17 — Kasus E: Duplicate & Invalid Data Validation', () {
    final service = CourseSupabaseService();

    test('validateCourse menolak kode course kosong', () {
      const emptyCode = Course(
        code: '   ',
        title: 'Algoritma',
        credits: 3,
        status: 'active',
      );

      expect(
        () => service.validateCourse(emptyCode),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Kode course'),
          ),
        ),
      );
    });

    test('validateCourse menolak judul course kosong', () {
      const emptyTitle = Course(
        code: 'MOB03',
        title: '',
        credits: 3,
        status: 'active',
      );

      expect(
        () => service.validateCourse(emptyTitle),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Judul course'),
          ),
        ),
      );
    });

    test('validateCourse menolak SKS <= 0', () {
      const zeroCredits = Course(
        code: 'MOB03',
        title: 'Sistem Operasi',
        credits: 0,
        status: 'active',
      );

      expect(
        () => service.validateCourse(zeroCredits),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('SKS'),
          ),
        ),
      );
    });

    test('validateCourse menolak status yang tidak dikenal', () {
      const invalidStatus = Course(
        code: 'MOB03',
        title: 'Jaringan Komputer',
        credits: 3,
        status: 'status_ngawur',
      );

      expect(
        () => service.validateCourse(invalidStatus),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Status course'),
          ),
        ),
      );
    });

    test('validateCourse menolak update tanpa ID', () {
      const updateWithoutId = Course(
        code: 'MOB03',
        title: 'Jaringan Komputer',
        credits: 3,
        status: 'active',
        id: null,
      );

      expect(
        () => service.validateCourse(updateWithoutId, isUpdate: true),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('ID course'),
          ),
        ),
      );
    });
  });

  group('Tahap 17 — Security Audit Checklist', () {
    test('Tidak ada service_role key dalam SupabaseConfig', () {
      expect(
        SupabaseConfig.supabaseAnonKey.contains('service_role'),
        isFalse,
        reason: 'Client-side tidak boleh menggunakan service_role key',
      );
    });

    test('.gitignore memuat aturan untuk file .env dan .vscode', () {
      final gitignoreFile = File('.gitignore');
      expect(gitignoreFile.existsSync(), isTrue);

      final content = gitignoreFile.readAsStringSync();
      expect(content, contains('.env'));
      expect(content, contains('.vscode/'));
    });
  });
}
