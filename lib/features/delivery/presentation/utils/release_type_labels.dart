import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The two documented release types produced when a courier releases an
/// order, plus their Arabic display text and status colors.
const List<String> releaseTypes = ['courier_voluntary', 'customer_unreachable'];

String releaseTypeLabel(String? type) {
  switch (type) {
    case 'courier_voluntary':
      return "مشكلة من عامل التوصيل";
    case 'customer_unreachable':
      return "تعذّر التواصل مع العميل";
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
      return Colors.orange.shade700;
    case 'customer_unreachable':
      return Colors.amber.shade800;
    default:
      return Colors.grey.shade600;
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
      return Colors.green.shade700;
    case 'cancelled':
    case 'refunded':
      return Colors.red.shade700;
    case 'awaiting_customer':
      return Colors.amber.shade800;
    default:
      return Colors.grey.shade600;
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
