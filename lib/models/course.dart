// Nama : Gede Supadma
// NIM : 2415051014

class Course {
  final String code;
  final String title;
  final int credits;
  final String status;

  // Field khusus untuk REST API (JSONPlaceholder Posts: userId, id, title, body)
  final int? id;
  final int? userId;
  final String? body;

  const Course({
    required this.code,
    required this.title,
    this.credits = 1,
    this.status = 'active',
    this.id,
    this.userId,
    this.body,
  });

  // ===========================================================================
  // TAHAP 17 - KASUS C: JSON MAPPING & TYPE VALIDATION
  // ===========================================================================
  // Factory constructor dari JSON (mendukung data lokal, Supabase, dan data REST API)
  factory Course.fromJson(Map<String, dynamic> json) {
    // Deteksi jika JSON berasal dari REST API JSONPlaceholder
    if (json.containsKey('userId') ||
        (json.containsKey('id') && !json.containsKey('code'))) {
      return Course.fromApiJson(json);
    }

    // Validasi tipe field 'code'
    final rawCode = json['code'];
    if (rawCode != null && rawCode is! String) {
      throw FormatException(
        'Format field "code" tidak valid: diharapkan String tetapi menerima ${rawCode.runtimeType} ($rawCode)',
      );
    }

    // Validasi tipe field 'title'
    final rawTitle = json['title'];
    if (rawTitle != null && rawTitle is! String) {
      throw FormatException(
        'Format field "title" tidak valid: diharapkan String tetapi menerima ${rawTitle.runtimeType} ($rawTitle)',
      );
    }

    // Validasi tipe field 'credits'
    final rawCredits = json['credits'];
    int credits = 1;
    if (rawCredits != null) {
      if (rawCredits is num) {
        credits = rawCredits.toInt();
      } else if (rawCredits is String) {
        final parsed = int.tryParse(rawCredits);
        if (parsed != null) {
          credits = parsed;
        } else {
          throw FormatException(
            'Format field "credits" tidak valid: tidak dapat mengonversi "$rawCredits" menjadi angka integer',
          );
        }
      } else {
        throw FormatException(
          'Format field "credits" tidak valid: diharapkan num/int tetapi menerima ${rawCredits.runtimeType} ($rawCredits)',
        );
      }
    }

    // Validasi tipe field 'status'
    final rawStatus = json['status'];
    if (rawStatus != null && rawStatus is! String) {
      throw FormatException(
        'Format field "status" tidak valid: diharapkan String tetapi menerima ${rawStatus.runtimeType} ($rawStatus)',
      );
    }

    // Validasi tipe field 'id'
    final rawId = json['id'];
    int? id;
    if (rawId != null) {
      if (rawId is num) {
        id = rawId.toInt();
      } else if (rawId is String) {
        id = int.tryParse(rawId);
        if (id == null) {
          throw FormatException(
            'Format field "id" tidak valid: tidak dapat mengonversi "$rawId" menjadi integer',
          );
        }
      } else {
        throw FormatException(
          'Format field "id" tidak valid: diharapkan num/int tetapi menerima ${rawId.runtimeType} ($rawId)',
        );
      }
    }

    return Course(
      code: (rawCode as String?) ?? '',
      title: (rawTitle as String?) ?? '',
      credits: credits,
      status: (rawStatus as String?) ?? 'active',
      id: id,
    );
  }

  // Factory constructor khusus untuk memetakan REST API JSONPlaceholder posts
  // Struktur respons asli API: userId, id, title, body
  // Menggunakan identitas turunan POST-$id untuk code tanpa menganggapnya field asli API
  factory Course.fromApiJson(Map<String, dynamic> json) {
    // Validasi tipe field 'id'
    final rawId = json['id'];
    int? id;
    if (rawId != null) {
      if (rawId is num) {
        id = rawId.toInt();
      } else if (rawId is String) {
        id = int.tryParse(rawId);
        if (id == null) {
          throw FormatException(
            'Format field "id" pada REST API tidak valid: "$rawId" bukan angka integer',
          );
        }
      } else {
        throw FormatException(
          'Format field "id" pada REST API tidak valid: diharapkan num tetapi menerima ${rawId.runtimeType}',
        );
      }
    }

    // Validasi tipe field 'userId'
    final rawUserId = json['userId'];
    int? userId;
    if (rawUserId != null) {
      if (rawUserId is num) {
        userId = rawUserId.toInt();
      } else if (rawUserId is String) {
        userId = int.tryParse(rawUserId);
        if (userId == null) {
          throw FormatException(
            'Format field "userId" pada REST API tidak valid: "$rawUserId" bukan angka integer',
          );
        }
      } else {
        throw FormatException(
          'Format field "userId" pada REST API tidak valid: diharapkan num tetapi menerima ${rawUserId.runtimeType}',
        );
      }
    }

    // Validasi tipe field 'title'
    final rawTitle = json['title'];
    if (rawTitle != null && rawTitle is! String) {
      throw FormatException(
        'Format field "title" pada REST API tidak valid: diharapkan String tetapi menerima ${rawTitle.runtimeType}',
      );
    }

    // Validasi tipe field 'body'
    final rawBody = json['body'];
    if (rawBody != null && rawBody is! String) {
      throw FormatException(
        'Format field "body" pada REST API tidak valid: diharapkan String tetapi menerima ${rawBody.runtimeType}',
      );
    }

    return Course(
      id: id,
      userId: userId,
      title: (rawTitle as String?) ?? '',
      body: rawBody as String?,
      code: id != null ? 'POST-$id' : 'POST-UNKNOWN',
      credits: 1,
      status: 'active',
    );
  }

  // Method copyWith untuk memudahkan modifikasi field course (Tahap 7)
  Course copyWith({
    String? code,
    String? title,
    int? credits,
    String? status,
    int? id,
    int? userId,
    String? body,
  }) {
    return Course(
      code: code ?? this.code,
      title: title ?? this.title,
      credits: credits ?? this.credits,
      status: status ?? this.status,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      body: body ?? this.body,
    );
  }

  // Method toJson untuk serialisasi objek kembali ke Map<String, dynamic>
  // Menjaga integritas payload tanpa menyertakan field buatan ke API payload
  Map<String, dynamic> toJson() {
    if (userId != null || body != null) {
      return {
        if (userId != null) 'userId': userId,
        if (id != null) 'id': id,
        'title': title,
        if (body != null) 'body': body,
      };
    }

    return {'code': code, 'title': title, 'credits': credits, 'status': status};
  }
}
