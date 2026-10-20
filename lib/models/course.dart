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

  // Factory constructor dari JSON (mendukung data lokal dan data REST API)
  factory Course.fromJson(Map<String, dynamic> json) {
    // Deteksi jika JSON berasal dari REST API JSONPlaceholder
    if (json.containsKey('userId') ||
        (json.containsKey('id') && !json.containsKey('code'))) {
      return Course.fromApiJson(json);
    }

    return Course(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'active',
    );
  }

  // Factory constructor khusus untuk memetakan REST API JSONPlaceholder posts
  // Struktur respons asli API: userId, id, title, body
  // Menggunakan identitas turunan POST-$id untuk code tanpa menganggapnya field asli API
  factory Course.fromApiJson(Map<String, dynamic> json) {
    final int? id = (json['id'] as num?)?.toInt();
    final int? userId = (json['userId'] as num?)?.toInt();
    final String title = json['title'] as String? ?? '';
    final String? body = json['body'] as String?;

    return Course(
      id: id,
      userId: userId,
      title: title,
      body: body,
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
    if (id != null || userId != null || body != null) {
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
