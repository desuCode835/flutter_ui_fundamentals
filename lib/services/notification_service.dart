// Nama : Gede Supadma
// NIM : 2415051014

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

// =============================================================================
// PRAKTIK 10: BACKGROUND MESSAGE HANDLER
// =============================================================================
/// Top-level background message handler untuk Firebase Cloud Messaging (Praktik 10)
/// Wajib berada di luar class NotificationService dan menggunakan anotasi @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('[BACKGROUND] Notification received');
  debugPrint('[BACKGROUND] Judul: ${message.notification?.title}');
  debugPrint('[BACKGROUND] Isi: ${message.notification?.body}');
  debugPrint('[BACKGROUND] Data: ${message.data}');
}

// =============================================================================
// PRAKTIK 8, 9, 10: NOTIFICATION SERVICE (NotificationService)
// =============================================================================
/// Mengelola izin notifikasi, token FCM, dan penerimaan notifikasi
/// pada kondisi Foreground, Background, dan Terminated menggunakan singleton pattern.
class NotificationService {
  NotificationService._internal({FirebaseMessaging? messaging})
      : _customMessaging = messaging;

  static NotificationService? _instance;

  /// Global key untuk menampilkan SnackBar di aplikasi tanpa context langsung (Praktik 10)
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
  bool _isInitialized = false;
  final List<void Function(String token)> _refreshListeners = [];
  StreamSubscription<String>? _registeredSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  /// Inisialisasi terpusat penerimaan notifikasi FCM (Praktik 10)
  /// Bertanggung jawab untuk:
  /// 1. Meminta permission notifikasi via requestPermission().
  /// 2. Memastikan FCM Token diperoleh via getToken().
  /// 3. Mengatur foreground presentation options jika didukung platform.
  /// 4. Mengaktifkan listener notifikasi foreground (onMessage) & menampilkan SnackBar.
  /// 5. Mengaktifkan listener interaksi notifikasi di background (onMessageOpenedApp).
  /// 6. Menangani notifikasi ketika aplikasi dibuka dari kondisi terminated (getInitialMessage).
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Meminta permission notifikasi
      await requestPermission();

      // 2. Mengambil FCM Token perangkat & registrasi
      await getToken();

      // 3. Mengatur foreground presentation options jika didukung platform
      try {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        debugPrint('setForegroundNotificationPresentationOptions dilewati: $e');
      }

      // 4. Listener notifikasi foreground (Aplikasi sedang dibuka pengguna)
      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FOREGROUND] Notification received');
        debugPrint('[FOREGROUND] Judul: ${message.notification?.title}');
        debugPrint('[FOREGROUND] Isi: ${message.notification?.body}');
        debugPrint('[FOREGROUND] Data: ${message.data}');

        _showForegroundSnackBar(message);
      });

      // 5. Listener ketika pengguna mengetuk notifikasi saat aplikasi di background
      _messageOpenedSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[BACKGROUND CLICKED] Pengguna membuka notifikasi FCM.');
        debugPrint('[BACKGROUND CLICKED] Judul: ${message.notification?.title}');
        debugPrint('[BACKGROUND CLICKED] Isi: ${message.notification?.body}');
        debugPrint('[BACKGROUND CLICKED] Data: ${message.data}');
      });

      // 6. Penanganan notifikasi ketika aplikasi dibuka dari kondisi terminated
      final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          '[TERMINATED] Aplikasi dibuka dari kondisi terminated melalui notifikasi',
        );
        debugPrint('[TERMINATED] Judul: ${initialMessage.notification?.title}');
        debugPrint('[TERMINATED] Isi: ${initialMessage.notification?.body}');
        debugPrint('[TERMINATED] Data: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('Error saat inisialisasi NotificationService.init(): $e');
    }
  }

  /// Menampilkan SnackBar di aplikasi saat notifikasi foreground diterima (Praktik 10)
  void _showForegroundSnackBar(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notifikasi Baru';
    final body = message.notification?.body ?? '';

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xFF1E40AF),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'TUTUP',
          textColor: Colors.amberAccent,
          onPressed: () {
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

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
    _foregroundSubscription?.cancel();
    _foregroundSubscription = null;
    _messageOpenedSubscription?.cancel();
    _messageOpenedSubscription = null;
    _refreshListeners.clear();
    _isListening = false;
  }
}
