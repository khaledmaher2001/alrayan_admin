import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

/// Renders any key in [raw] that isn't already covered by [knownKeys] as an
/// Arabic-labeled `label : value` row. Always visible — no tap needed —
/// since this is server data an admin needs to see at a glance. Used across
/// the delivery-wallet, transactions and release-log screens: those API
/// responses have no documented schema, so this is how the real server
/// response stays fully visible instead of being silently dropped.
///
/// Keys are translated via [_arabicLabels] when recognized. A key the
/// server has never been observed sending isn't guessable, so it falls
/// back to being shown as-is (its raw, English, spelling) rather than
/// inventing a label for it.
class ExtraFieldsSection extends StatelessWidget {
  const ExtraFieldsSection({
    super.key,
    required this.raw,
    required this.knownKeys,
  });

  final Map<String, dynamic> raw;
  final Set<String> knownKeys;

  @override
  Widget build(BuildContext context) {
    final extraEntries = raw.entries
        .where((e) => !knownKeys.contains(e.key) && e.value != null)
        .toList();

    if (extraEntries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: AppConstants.height10(context)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppConstants.sp10(context)),
        decoration: BoxDecoration(
          color: DsColor.page,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: DsColor.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppConstants.sp15(context),
                  color: DsColor.textMuted,
                ),
                SizedBox(width: AppConstants.width5(context)),
                Text(
                  "additional_data".tr(),
                  style: Styles.inter12500Black(context).copyWith(
                    color: DsColor.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height5(context)),
            ...List.generate(extraEntries.length, (index) {
              final e = extraEntries[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index != 0)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppConstants.height5(context) / 2,
                      ),
                      child: Divider(color: DsColor.border, height: 1),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          arabicFieldLabel(e.key),
                          style: Styles.inter12500Black(
                            context,
                          ).copyWith(color: DsColor.textMuted),
                        ),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      Flexible(
                        child: Text(
                          formatFieldValue(e.key, e.value),
                          textAlign: TextAlign.end,
                          style: Styles.inter12500Black(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Arabic label for a raw server field name, e.g. `walletBalance` →
/// "الرصيد". Falls back to the raw (English) key when it isn't recognized —
/// shared with any other widget (e.g. the wallet tab's stat tiles) that
/// renders fields straight from raw JSON, so labels stay consistent
/// wherever the same key shows up.
String arabicFieldLabel(String key) => _arabicLabels[key] ?? key;

/// Arabic-formats a raw field value: booleans, known enum strings, a
/// timestamp for a field [key] recognized as a date ([_dateKeys]) — shown in
/// the same `yyyy-MM-dd hh:mm a` style used everywhere else in the delivery
/// module rather than a raw ISO string — and, for a field recognized as a
/// money amount ([_moneyKeys]), a numeric value gets the "ج.م" suffix the
/// rest of the app uses for currency. Anything else is shown as-is.
String formatFieldValue(String key, dynamic value) {
  if (value is bool) return value ? "s_yes".tr() : "s_no".tr();
  if (value is String && _dateKeys.contains(key)) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return DateFormat("yyyy-MM-dd  hh:mm a").format(parsed.toLocal());
    }
  }
  if (value is String && _arabicValues.containsKey(value)) {
    return _arabicValues[value]!;
  }
  if (value is num && _moneyKeys.contains(key)) return "$value ${"s_egp".tr()}";
  return "$value";
}

/// Field names whose string value is an ISO timestamp — used to format the
/// value as a readable date and time instead of dumping the raw ISO string.
Set<String> _dateKeys = {'createdAt', 'updatedAt', 'deletedAt', 'date'};

/// Field names whose numeric value is a currency amount rather than a plain
/// count/id/percentage — used to append "ج.م" in [formatFieldValue].
Set<String> _moneyKeys = {
  'amount',
  'value',
  'walletBalance',
  'balance',
  'currentBalance',
  'balanceAfter',
  'runningBalance',
  'balanceDelta',
  'shippingAmount',
  'earningAmount',
  'amountCollected',
  'remittedAmount',
  'deliveryFee',
  'shippingFee',
  'deliveryCost',
  'deliveryValue',
  'collectedAmount',
  'totalCollected',
  'collectedTotal',
  'thisMonthGrossCollected',
  'thisMonthEarnings',
  'thisMonthRemitted',
  'allTimeRemitted',
  'allTimeEarnings',
  'allTimeGrossCollected',
};

/// Arabic translations for enum-style string values seen (or plausible)
/// coming back from the server, e.g. transaction `type` or `paymentMethod`.
Map<String, String> _arabicValues = {
  'order_earning': "s_order_earnings".tr(),
  'remittance': "s_cash_handed_to_the_store".tr(),
  'manual_adjustment': "s_manual_balance_adjustment".tr(),
  'bonus': "s_bonus".tr(),
  'penalty': "s_deduction".tr(),
  'refund': "s_refund".tr(),
  'cash_on_delivery': "s_cash_on_delivery".tr(),
  'card': "s_card".tr(),
  'wallet': "s_wallet".tr(),
};

/// Best-effort translation of raw API field names actually seen (or
/// plausible) across the delivery wallet/transactions/release-log/account
/// endpoints. Add to this map as new server field names show up.
Map<String, String> _arabicLabels = {
  'id': "s_id".tr(),
  'rejectionReason': "ds_rejection_reason".tr(),
  'thisMonthGrossCollected': "s_collected_this_month".tr(),
  'thisMonthEarnings': "s_earnings_this_month".tr(),
  'thisMonthRemitted': "s_handed_to_the_store_this_month".tr(),
  'allTimeRemitted': "s_total_handed_to_the_store".tr(),
  'allTimeEarnings': "s_total_earnings".tr(),
  'allTimeGrossCollected': "s_total_collected".tr(),
  'userId': "s_user_id".tr(),
  'profileId': "s_profile_id".tr(),
  'deliveryUserId': "s_courier_id".tr(),
  'fullName': "s_full_name".tr(),
  'email': "s_email_2".tr(),
  'phoneNumber': "s_phone_number".tr(),
  'vehicleName': "s_vehicle_name".tr(),
  'vehiclePlateNumber': "s_plate_number".tr(),
  'earningPercentage': "s_earnings_rate".tr(),
  'commissionPercentage': "s_earnings_rate".tr(),
  'profitPercentage': "s_earnings_rate".tr(),
  'maxActiveOrders': "s_maximum_active_orders".tr(),
  'maxActiveOrdersOverride': "s_maximum_active_orders".tr(),
  'walletBalance': "s_balance".tr(),
  'balance': "s_balance".tr(),
  'currentBalance': "s_balance".tr(),
  'isAvailableForDelivery': "s_available_for_delivery".tr(),
  'createdAt': "s_created_on".tr(),
  'updatedAt': "s_updated_on".tr(),
  'deletedAt': "s_deleted_on".tr(),
  'type': "s_type".tr(),
  'amount': "s_amount".tr(),
  'value': "s_value".tr(),
  'paymentMethod': "s_payment_method".tr(),
  'shippingAmount': "s_delivery_fee".tr(),
  'earningAmount': "s_courier_net_earnings".tr(),
  'amountCollected': "s_amount_collected".tr(),
  'remittedAmount': "s_amount_handed_to_the_store".tr(),
  'balanceDelta': "s_balance_change".tr(),
  'description': "s_description".tr(),
  'notes': "s_notes".tr(),
  'note': "s_note".tr(),
  'date': "s_date".tr(),
  'balanceAfter': "s_balance_after".tr(),
  'runningBalance': "s_balance_after".tr(),
  'order': "s_order".tr(),
  'orderId': "s_order_id".tr(),
  'orderNumber': "s_order_number".tr(),
  'deliveryFee': "s_delivery_fee".tr(),
  'shippingFee': "s_delivery_fee".tr(),
  'deliveryCost': "s_delivery_fee".tr(),
  'deliveryValue': "s_delivery_fee".tr(),
  'collectedAmount': "s_amount_collected".tr(),
  'totalCollected': "s_amount_collected".tr(),
  'collectedTotal': "s_amount_collected".tr(),
  'status': "s_status".tr(),
  'paymentStatus': "s_payment_status".tr(),
  'currency': "s_currency".tr(),
  'referenceId': "s_reference_number".tr(),
  'transactionId': "s_transaction_number".tr(),
  'reason': "s_reason".tr(),
  'courier': "s_courier".tr(),
  'courierId': "s_courier_id".tr(),
  'courierName': "s_courier_name".tr(),
  'adminId': "s_admin_id".tr(),
  'adminName': "s_admin_name".tr(),
  'customerId': "s_customer_id".tr(),
  'customerName': "s_customer_name".tr(),
  'address': "s_address".tr(),
  'success': "s_success".tr(),
  'message': "s_message".tr(),
};
