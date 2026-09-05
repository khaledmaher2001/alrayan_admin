import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String paymentStatusLabel(String? status) {
  const known = ['pending', 'paid', 'failed', 'refunded'];
  if (status == null || !known.contains(status)) return status ?? '-';
  return 'payment_status_$status'.tr();
}

Color paymentStatusColor(String? status) {
  switch (status) {
    case 'paid':
      return Colors.green.withValues(alpha: 0.15);
    case 'pending':
      return Colors.orange.withValues(alpha: 0.15);
    case 'failed':
      return Colors.red.withValues(alpha: 0.15);
    default:
      return Colors.grey.withValues(alpha: 0.15);
  }
}

Color paymentStatusTextColor(String? status) {
  switch (status) {
    case 'paid':
      return Colors.green.shade800;
    case 'pending':
      return Colors.orange.shade800;
    case 'failed':
      return Colors.red.shade800;
    default:
      return Colors.grey.shade800;
  }
}

String paymentMethodLabel(String? method) {
  switch (method) {
    case 'cash_on_delivery':
      return 'payment_method_cash_on_delivery'.tr();
    case 'card':
      return 'payment_method_card'.tr();
    case 'wallet':
      return 'payment_method_wallet'.tr();
    default:
      return method ?? '-';
  }
}
