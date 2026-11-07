// Nama : Gede Supadma
// NIM : 2415051014

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// =============================================================================
// PRAKTIK 8: NOTIFICATION PERMISSION SERVICE (NotificationService)
// =============================================================================
// Mengelola permintaan izin (permission) notifikasi Firebase Cloud Messaging (FCM)
// menggunakan singleton pattern agar dapat diintegrasikan secara terpusat.
class NotificationService {
  NotificationService._internal({FirebaseMessaging? messaging})
      : _customMessaging = messaging;

  static NotificationService? _instance;

  /// Factory constructor untuk mendukung singleton pattern
  factory NotificationService() => instance;

  /// Instance singleton dari NotificationService
  static NotificationService get instance =>
      _instance ??= NotificationService._internal();

  @visibleForTesting
  static set instance(NotificationService service) => _instance = service;

  final FirebaseMessaging? _customMessaging;

  FirebaseMessaging get _messaging =>
      _customMessaging ?? FirebaseMessaging.instance;

  /// Meminta izin notifikasi kepada pengguna dengan parameter alert, badge, dan sound
  Future<AuthorizationStatus> requestPermission() async {
    try {
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('Status izin notifikasi: ${settings.authorizationStatus}');

      return settings.authorizationStatus;
    } catch (e) {
      debugPrint('Status izin notifikasi error: $e');
      return AuthorizationStatus.notDetermined;
    }
  }
}

