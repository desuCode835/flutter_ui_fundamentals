// Nama : Gede Supadma
// NIM : 2415051014

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';

void main() {
  group('Tahap 3 - Model Course Test', () {
    test('Course.fromJson memetakan data lokal dengan benar', () {
      final localJson = {
        'code': 'MOB01',
        'title': 'Git & GitHub',
        'credits': 2,
        'status': 'done',
      };

      final course = Course.fromJson(localJson);

      expect(course.code, 'MOB01');
      expect(course.title, 'Git & GitHub');
      expect(course.credits, 2);
      expect(course.status, 'done');
      expect(course.id, isNull);
      expect(course.userId, isNull);

      final exportedJson = course.toJson();
      expect(exportedJson, localJson);
    });

    test('Course.fromJson memetakan respons REST API JSONPlaceholder dengan benar', () {
      final apiJson = {
        'userId': 1,
        'id': 1,
        'title': 'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
        'body':
            'quia et suscipit suscipit recusandae consequuntur expedita et cum',
      };

      final course = Course.fromJson(apiJson);

      expect(course.id, 1);
      expect(course.userId, 1);
      expect(
        course.title,
        'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
      );
      expect(
        course.body,
        'quia et suscipit suscipit recusandae consequuntur expedita et cum',
      );
      // Identitas turunan
      expect(course.code, 'POST-1');

      // toJson harus konsisten dengan struktur data API dan tidak memasukkan field buatan (seperti code atau credits)
      final exportedJson = course.toJson();
      expect(exportedJson['userId'], 1);
      expect(exportedJson['id'], 1);
      expect(exportedJson['title'], course.title);
      expect(exportedJson['body'], course.body);
      expect(exportedJson.containsKey('code'), isFalse);
      expect(exportedJson.containsKey('credits'), isFalse);
      expect(exportedJson.containsKey('status'), isFalse);
    });

    test('Course.fromApiJson memetakan tanpa field code asli di JSON', () {
      final apiJson = {
        'userId': 2,
        'id': 42,
        'title': 'Testing Post 42',
        'body': 'Content 42',
      };

      final course = Course.fromApiJson(apiJson);
      expect(course.code, 'POST-42');
      expect(course.id, 42);
      expect(course.userId, 2);
    });
  });
}
