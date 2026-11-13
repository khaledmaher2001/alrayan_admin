import 'dart:async';

import 'package:alrayan_admin/core/utils/roots/app_router.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/complaints/presentation/admin_complaint_details_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/courier_details_loader_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/remittances_view.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view/order_details_loader_view.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/product_details_loader_view.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_cubit.dart';
import 'package:alrayan_admin/features/profile/presentation/view_model/get_profile/get_profile_state.dart';
import 'package:alrayan_admin/features/reviews/presentation/view/reviews_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Turns a tapped push notification into the screen it is about.
///
/// The backend puts `{screen, params}` in the push's `additionalData`. The
/// OneSignal click listener (registered in `main`) hands it to [handleRaw] in
/// every app state. The payload is kept until the main layout is up for a
/// signed-in staff member ([markAppReady], called by `MainLayoutView`), so a
/// tap that cold-starts the app — or arrives while on the login screen — is
/// applied after the splash/login instead of being lost under it.
class NotificationNavigationHandler {
  NotificationNavigationHandler._();

  static int _readyLayouts = 0; // mounted main layouts
  static bool get _appReady => _readyLayouts > 0;
  static Map<String, dynamic>? _pendingRawData;
  static bool _flushing = false;

  static String? _lastKey;
  static DateTime? _lastHandledAt;

  /// The main layout is showing (after splash or login): apply any buffered tap.
  static void markAppReady() {
    _readyLayouts++;
    _flushPending();
  }

  /// The main layout went away (logout): buffer taps until the next login.
  static void markAppNotReady() {
    if (_readyLayouts > 0) _readyLayouts--;
  }

  /// Entry point for OneSignal's `additionalData`.
  static void handleRaw(Map<String, dynamic>? rawData) {
    if (rawData == null) return;
    debugPrint("NotificationNavigationHandler: push additionalData -> $rawData");
    _pendingRawData = rawData;
    if (_appReady) _flushPending();
  }

  static Future<void> _flushPending() async {
    if (_flushing || _pendingRawData == null) return;
    if (CacheKeysManger.tokenStatus().isEmpty) return; // not signed in yet
    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;

    _flushing = true;
    try {
      // Permission checks need the staff member's profile; right after a
      // cold start or login it is usually still loading.
      await _waitForProfile(context.read<GetProfileCubit>());

      final rawData = _pendingRawData;
      final navigator = AppRouter.rootNavigatorKey.currentState;
      if (rawData == null || navigator == null || !_appReady || !navigator.mounted) return;
      _pendingRawData = null;
      _navigate(rawData, navigator);
    } finally {
      _flushing = false;
    }
  }

  static Future<void> _waitForProfile(GetProfileCubit cubit) async {
    bool settled(GetProfileStates s) => s is GetProfileSuccessState || s is GetProfileErrorState;
    if (settled(cubit.state)) return;
    try {
      await cubit.stream.firstWhere(settled).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Carry on; without a profile the screens let the server decide.
    }
  }

  /// Reads [key] from `params` (backend shape) or from the top level.
  static Object? _param(Map<String, dynamic> rawData, String key) {
    final params = rawData['params'];
    if (params is Map && params[key] != null) return params[key];
    return rawData[key];
  }

  static int? _intParam(Map<String, dynamic> rawData, String key) {
    final value = _param(rawData, key);
    if (value == null) return null;
    return value is int ? value : int.tryParse(value.toString());
  }

  static void _navigate(Map<String, dynamic> rawData, NavigatorState navigator) {
    final screen = rawData['screen']?.toString();
    if (screen == null) return;

    final context = navigator.context;
    switch (screen) {
      case 'AdminOrderDetails':
        final orderId = _intParam(rawData, 'orderId');
        if (orderId == null || _isDuplicate(screen, orderId)) return;
        if (!_allowed(context, 'orders')) return _openHome(navigator);
        _push(navigator, OrderDetailsLoaderView(orderId: orderId));
        break;

      case 'AdminOrders':
        if (_isDuplicate(screen, null)) return;
        if (!_allowed(context, 'orders')) return _openHome(navigator);
        _openOrdersTab(navigator, _param(rawData, 'status')?.toString());
        break;

      case 'AdminProductDetails':
        final productId = _intParam(rawData, 'productId');
        if (productId == null || _isDuplicate(screen, productId)) return;
        if (!_allowed(context, 'products')) return _openHome(navigator);
        _push(navigator, ProductDetailsLoaderView(productId: productId));
        break;

      case 'AdminCourierDetails':
        final courierId = _intParam(rawData, 'courierId');
        if (courierId == null || _isDuplicate(screen, courierId)) return;
        if (!_allowed(context, 'delivery')) return _openHome(navigator);
        _push(navigator, CourierDetailsLoaderView(courierId: courierId));
        break;

      case 'AdminRemittanceDetails':
        // The remittances list has no single-remittance screen.
        if (_isDuplicate(screen, _intParam(rawData, 'transactionId'))) return;
        if (!_allowed(context, 'delivery')) return _openHome(navigator);
        _push(navigator, const RemittancesView());
        break;

      case 'reviewDetails':
        if (_isDuplicate(screen, _intParam(rawData, 'orderId'))) return;
        if (!_allowed(context, 'customers')) return _openHome(navigator);
        _push(navigator, const ReviewsView());
        break;

      case 'Complaints':
      case 'ComplaintDetails':
        final id = _intParam(rawData, 'id');
        if (id == null || _isDuplicate('ComplaintDetails', id)) return;
        if (!_allowed(context, 'customers')) return _openHome(navigator);
        _push(navigator, AdminComplaintDetailsView(id: id));
        break;

      default:
        debugPrint("NotificationNavigationHandler: unknown screen '$screen'");
    }
  }

  /// Same rule as the main layout / "More" page: full admins can do
  /// everything; while the profile is unknown the server decides.
  static bool _allowed(BuildContext context, String permission) {
    final state = context.read<GetProfileCubit>().state;
    if (state is! GetProfileSuccessState) return true;
    final profile = state.model.data;
    return profile == null || profile.can(permission);
  }

  static void _push(NavigatorState navigator, Widget screen) {
    navigator.push(MaterialPageRoute(builder: (_) => screen));
  }

  static void _openTab(NavigatorState navigator, int index) {
    navigator.popUntil((route) => route.isFirst);
    navigator.context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(index);
  }

  static void _openHome(NavigatorState navigator) => _openTab(navigator, 0);

  static void _openOrdersTab(NavigatorState navigator, String? status) {
    _openTab(navigator, 1);
    final filterCubit = navigator.context.read<OrderStatusFilterCubit>();
    final index = status == null ? -1 : filterCubit.status.indexOf(status);
    if (index >= 0 && index != filterCubit.selectedFilterIndex) {
      filterCubit.selectIndex(index: index);
      navigator.context.read<GetOrdersCubit>().getOrders(status: status);
    }
  }

  /// The same tap delivered twice (e.g. listener fired again) within 2s.
  static bool _isDuplicate(String screen, int? id) {
    final key = '$screen:$id';
    final now = DateTime.now();
    final lastAt = _lastHandledAt;
    if (_lastKey == key && lastAt != null && now.difference(lastAt) < const Duration(seconds: 2)) {
      return true;
    }
    _lastKey = key;
    _lastHandledAt = now;
    return false;
  }
}
