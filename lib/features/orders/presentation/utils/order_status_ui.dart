import 'package:flutter/material.dart';

/// Icon language for the new orders design — colors still come from
/// [AppConstants.getStatusColor]/[getTextColor] so the whole app keeps one
/// source of truth for "what color is this status".
class OrderStatusUi {
  OrderStatusUi._();

  static IconData icon(String? status) {
    switch (status) {
      case "pending":
        return Icons.access_time_rounded;
      case "confirmed":
        return Icons.check_circle_rounded;
      case "processing":
        return Icons.settings_suggest_rounded;
      case "shipped":
        return Icons.local_shipping_rounded;
      case "delivered":
        return Icons.task_alt_rounded;
      case "cancelled":
        return Icons.cancel_rounded;
      case "refunded":
        return Icons.replay_circle_filled_rounded;
      default:
        return Icons.grid_view_rounded; // "s_all".tr()
    }
  }
}
