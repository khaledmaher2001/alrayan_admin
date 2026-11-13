import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The two documented release types produced when a courier releases an
/// order, plus their Arabic display text and status colors.
const List<String> releaseTypes = ['courier_voluntary', 'customer_unreachable'];

String releaseTypeLabel(String? type) {
  switch (type) {
    case 'courier_voluntary':
      return "s_problem_from_the_courier".tr();
    case 'customer_unreachable':
      return "s_couldn_t_reach_the_customer".tr();
    default:
      return type == null || type.isEmpty ? '-' : type;
  }
}

/// `courier_voluntary` → warning tone; `customer_unreachable` → a
/// "needs follow-up" tone. Uses the app's Material palette so it stays
/// consistent with the rest of the dashboard.
Color releaseTypeColor(String? type) {
  switch (type) {
    case 'courier_voluntary':
      return DsColor.warning;
    case 'customer_unreachable':
      return DsColor.warning;
    default:
      return DsColor.textMuted;
  }
}

/// Color for the order status *after* a release action, per the requested
/// scheme: reopened → success, cancelled → danger.
Color releaseOutcomeColor(String? status) {
  switch (status) {
    case 'pending':
    case 'reopened':
    case 'confirmed':
    case 'awaiting_courier':
      return DsColor.success;
    case 'cancelled':
    case 'refunded':
      return DsColor.danger;
    case 'awaiting_customer':
      return DsColor.warning;
    default:
      return DsColor.textMuted;
  }
}

String releaseTypeLabelTr(String? type) {
  switch (type) {
    case 'courier_voluntary':
      return "release_type_courier_voluntary".tr();
    case 'customer_unreachable':
      return "release_type_customer_unreachable".tr();
    default:
      return type == null || type.isEmpty ? '-' : type;
  }
}
