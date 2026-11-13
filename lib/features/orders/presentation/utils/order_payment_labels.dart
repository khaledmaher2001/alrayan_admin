import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String paymentStatusLabel(String? status) {
  if (status == 'partially_paid') return "s_partially_paid".tr();
  if (status == 'partially_refunded') return "s_partially_refunded".tr();
  const known = ['pending', 'paid', 'failed', 'refunded'];
  if (status == null || !known.contains(status)) return status ?? '-';
  return 'payment_status_$status'.tr();
}

Color paymentStatusColor(String? status) {
  switch (status) {
    case 'paid':
      return DsColor.success.withValues(alpha: 0.15);
    case 'pending':
      return DsColor.warning.withValues(alpha: 0.15);
    case 'failed':
      return DsColor.danger.withValues(alpha: 0.15);
    default:
      return DsColor.textMuted.withValues(alpha: 0.15);
  }
}

Color paymentStatusTextColor(String? status) {
  switch (status) {
    case 'paid':
      return DsColor.success;
    case 'pending':
      return DsColor.warning;
    case 'failed':
      return DsColor.danger;
    default:
      return DsColor.text2;
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
