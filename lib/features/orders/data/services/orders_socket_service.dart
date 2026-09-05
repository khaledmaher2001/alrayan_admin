import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/utils/services/local_services/cache_keys.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';
import '../models/orders_model.dart';

/// Keeps a live Socket.IO connection to the admin-orders namespace so new
/// orders show up in the app in realtime instead of waiting for a manual
/// refresh / pagination.
class OrdersSocketService {
  io.Socket? _socket;
  String? _connectedToken;

  final StreamController<Items> _orderCreatedController =
      StreamController<Items>.broadcast();

  Stream<Items> get onOrderCreated => _orderCreatedController.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Opens (or re-opens, if the token changed) the connection. Safe to call
  /// repeatedly — it no-ops if already connected with the same token.
  void connect() {
    final token = CacheKeysManger.tokenStatus();
    if (token.isEmpty) return;

    if (_socket != null && _connectedToken == token) {
      if (!isConnected) {
        _socket!.connect();
      }
      return;
    }

    disconnect();
    _connectedToken = token;

    _socket = io.io(
      '${EndPoints.socketBaseUrl}${EndPoints.adminOrdersNamespace}',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token})
          .enableReconnection()
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[OrdersSocket] connected');
    });

    _socket!.on(EndPoints.orderCreatedEvent, _handleOrderCreated);

    _socket!.onDisconnect((_) {
      debugPrint('[OrdersSocket] disconnected');
    });

    _socket!.onConnectError((e) {
      debugPrint('[OrdersSocket] connect error: $e');
    });

    _socket!.onError((e) {
      debugPrint('[OrdersSocket] error: $e');
    });
  }

  void _handleOrderCreated(dynamic data) {
    try {
      final Map<String, dynamic> payload = Map<String, dynamic>.from(
        data as Map,
      );
      final dynamic orderJson = payload['order'] ?? payload;
      final order = Items.fromJson(Map<String, dynamic>.from(orderJson));
      _orderCreatedController.add(order);
    } catch (e) {
      debugPrint('[OrdersSocket] failed to parse order:created payload: $e');
    }
  }

  void disconnect() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectedToken = null;
  }

  /// Tears down and re-opens the connection from scratch. Used when the app
  /// comes back to the foreground: a socket left "connected" while the OS
  /// suspended the app can report a stale connected state that isn't really
  /// alive anymore (no ping/pong could happen while suspended), so instead
  /// of trusting it we just start clean.
  void forceReconnect() {
    disconnect();
    connect();
  }

  void dispose() {
    disconnect();
    _orderCreatedController.close();
  }
}
