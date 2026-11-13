import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../local_services/cache_keys.dart';
import 'api_service.dart';
import 'service_locator.dart';

/// Keeps the server's copy of this device's OneSignal id current.
///
/// Since 2026-11 the app has its own OneSignal app, so an update gives the
/// device a new id. Login already sends it; this also sends it when the id
/// changes and once per start while signed in, so people who update without
/// logging in again keep getting notifications.
class PushSubscriptionSync {
  static String? _lastSent;

  static void start() {
    OneSignal.User.pushSubscription.addObserver((state) => _send(state.current.id));
    registerNow();
  }

  /// At start and after sign-in: OneSignal can take a few seconds to have the id.
  static Future<void> registerNow() async {
    for (final wait in const [0, 2, 5, 10, 20]) {
      if (wait > 0) await Future.delayed(Duration(seconds: wait));
      final id = OneSignal.User.pushSubscription.id;
      if (id != null && id.isNotEmpty) {
        await _send(id);
        return;
      }
    }
  }

  static Future<void> _send(String? id) async {
    if (id == null || id.isEmpty || id == _lastSent) return;
    if (CacheKeysManger.tokenStatus().isEmpty) return;
    try {
      await getIt.get<ApiService>().postData(endPoint: 'auth/player-id', sendToken: true, data: {'playerId': id});
      _lastSent = id;
    } catch (_) {
      // Offline or signed out: login sends it again later.
    }
  }
}
