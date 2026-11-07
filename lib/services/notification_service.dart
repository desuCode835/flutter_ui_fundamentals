// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// =============================================================================
// PRAKTIK 8 & 9: NOTIFICATION PERMISSION & FCM TOKEN SERVICE (NotificationService)
// =============================================================================
// Mengelola izin (permission) notifikasi dan perolehan FCM registration token
// menggunakan Firebase Cloud Messaging (FCM) versi modern dengan singleton pattern.
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

  String? _fcmToken;

  /// Token FCM yang tersimpan pada sesi perangkat saat ini
  String? get fcmToken => _fcmToken;

  bool _isRegistered = false;
  bool _isListening = false;
  final List<void Function(String token)> _refreshListeners = [];
  StreamSubscription<String>? _registeredSubscription;

  /// Meminta izin notifikasi kepada pengguna dengan parameter alert, badge, dan sound (Praktik 8)
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

  /// Memasang listener pada stream registrasi/refresh token
  void _setupTokenListener() {
    if (_isListening) return;
    try {
      _registeredSubscription = _messaging.onRegistered.listen((token) {
        final isRefreshed = _fcmToken != null && _fcmToken != token;
        _fcmToken = token;

        if (isRefreshed) {
          debugPrint('FCM Token diperbarui: $token');
        } else {
          debugPrint('FCM TOKEN: $token');
        }

        for (final listener in List.from(_refreshListeners)) {
          try {
            listener(token);
          } catch (e) {
            debugPrint('Error pada callback refresh listener: $e');
          }
        }
      });
      _isListening = true;
    } catch (e) {
      debugPrint('Belum dapat mengaktifkan listener onRegistered: $e');
    }
  }

  /// Mendaftarkan perangkat ke Firebase Cloud Messaging secara aman (Praktik 9)
  /// Menghindari registrasi berulang yang tidak diperlukan.
  Future<void> registerDevice() async {
    if (_isRegistered) return;
    try {
      _setupTokenListener();
      await _messaging.register();
      _isRegistered = true;
      debugPrint('Perangkat berhasil didaftarkan ke FCM.');
    } catch (e) {
      debugPrint('Peringatan: Gagal mendaftarkan perangkat ke FCM: $e');
    }
  }

  /// Mendapatkan FCM registration token dari perangkat Android (Praktik 9)
  /// Menggunakan mekanisme registrasi & stream onRegistered sesuai firebase_messaging 17.0.1
  /// serta fallback getToken() untuk kompatibilitas.
  Future<String?> getToken() async {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      debugPrint('FCM TOKEN: $_fcmToken');
      return _fcmToken;
    }

    try {
      _setupTokenListener();

      // Menyiapkan completer untuk menangkap token pertama yang diterima dari stream onRegistered
      final tokenCompleter = Completer<String?>();
      StreamSubscription<String>? tempSub;

      tempSub = _messaging.onRegistered.listen((token) {
        if (!tokenCompleter.isCompleted) {
          tokenCompleter.complete(token);
        }
      }, onError: (err) {
        if (!tokenCompleter.isCompleted) {
          tokenCompleter.complete(null);
        }
      });

      // Panggil registrasi perangkat
      await registerDevice();

      // Tunggu respons stream atau lanjutkan ke fallback
      String? token;
      try {
        token = await tokenCompleter.future.timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
      } finally {
        await tempSub.cancel();
      }

      // Jika belum diperoleh melalui stream, gunakan fallback getToken()
      if (token == null || token.isEmpty) {
        // ignore: deprecated_member_use
        token = await _messaging.getToken();
      }

      if (token != null && token.isNotEmpty) {
        _fcmToken = token;
        debugPrint('FCM TOKEN: $token');
      }

      return _fcmToken;
    } catch (e) {
      debugPrint('Gagal mendapatkan FCM Token: $e');
      return null;
    }
  }

  /// Mendengarkan perubahan atau pembaruan FCM Token (Praktik 9)
  void listenTokenRefresh(void Function(String token) onRefresh) {
    _refreshListeners.add(onRefresh);
    _setupTokenListener();

    // Jika token saat ini sudah tersedia, panggil callback langsung
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      onRefresh(_fcmToken!);
    }
  }

  /// Menghentikan subscription listener saat diperlukan
  void dispose() {
    _registeredSubscription?.cancel();
    _registeredSubscription = null;
    _refreshListeners.clear();
    _isListening = false;
  }
}
