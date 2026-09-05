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
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppConstants.sp15(context),
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: AppConstants.width5(context)),
                Text(
                  "additional_data".tr(),
                  style: Styles.inter12500Black(context).copyWith(
                    color: Colors.grey.shade600,
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
                      child: Divider(color: Colors.grey.shade200, height: 1),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          arabicFieldLabel(e.key),
                          style: Styles.inter12500Black(
                            context,
                          ).copyWith(color: Colors.grey.shade600),
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
  if (value is bool) return value ? "نعم" : "لا";
  if (value is String && _dateKeys.contains(key)) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return DateFormat("yyyy-MM-dd  hh:mm a").format(parsed.toLocal());
    }
  }
  if (value is String && _arabicValues.containsKey(value)) {
    return _arabicValues[value]!;
  }
  if (value is num && _moneyKeys.contains(key)) return "$value ج.م";
  return "$value";
}

/// Field names whose string value is an ISO timestamp — used to format the
/// value as a readable date and time instead of dumping the raw ISO string.
const Set<String> _dateKeys = {'createdAt', 'updatedAt', 'deletedAt', 'date'};

/// Field names whose numeric value is a currency amount rather than a plain
/// count/id/percentage — used to append "ج.م" in [formatFieldValue].
const Set<String> _moneyKeys = {
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
const Map<String, String> _arabicValues = {
  'order_earning': 'أرباح طلب',
  'remittance': 'تسليم مبلغ للمحل',
  'manual_adjustment': 'تعديل يدوي للرصيد',
  'bonus': 'مكافأة',
  'penalty': 'خصم',
  'refund': 'استرداد',
  'cash_on_delivery': 'الدفع عند الاستلام',
  'card': 'بطاقة',
  'wallet': 'محفظة',
};

/// Best-effort translation of raw API field names actually seen (or
/// plausible) across the delivery wallet/transactions/release-log/account
/// endpoints. Add to this map as new server field names show up.
const Map<String, String> _arabicLabels = {
  'id': 'المعرف',
  'thisMonthGrossCollected': 'إجمالي التحصيل هذا الشهر',
  'thisMonthEarnings': 'أرباح هذا الشهر',
  'thisMonthRemitted': 'المسلَّم للمحل هذا الشهر',
  'allTimeRemitted': 'إجمالي المسلَّم للمحل',
  'allTimeEarnings': 'إجمالي الأرباح',
  'allTimeGrossCollected': 'إجمالي التحصيل',
  'userId': 'معرف المستخدم',
  'profileId': 'معرف الملف',
  'deliveryUserId': 'معرف المندوب',
  'fullName': 'الاسم الكامل',
  'email': 'البريد الإلكتروني',
  'phoneNumber': 'رقم الهاتف',
  'vehicleName': 'اسم المركبة',
  'vehiclePlateNumber': 'رقم لوحة المركبة',
  'earningPercentage': 'نسبة الأرباح',
  'commissionPercentage': 'نسبة الأرباح',
  'profitPercentage': 'نسبة الأرباح',
  'maxActiveOrders': 'الحد الأقصى للطلبات النشطة',
  'maxActiveOrdersOverride': 'الحد الأقصى للطلبات النشطة',
  'walletBalance': 'الرصيد',
  'balance': 'الرصيد',
  'currentBalance': 'الرصيد',
  'isAvailableForDelivery': 'متاح للتوصيل',
  'createdAt': 'تاريخ الإنشاء',
  'updatedAt': 'تاريخ التحديث',
  'deletedAt': 'تاريخ الحذف',
  'type': 'النوع',
  'amount': 'المبلغ',
  'value': 'القيمة',
  'paymentMethod': 'طريقة الدفع',
  'shippingAmount': 'قيمة التوصيل',
  'earningAmount': 'صافي ربح المندوب',
  'amountCollected': 'المبلغ المحصل',
  'remittedAmount': 'المبلغ المُسلَّم للمحل',
  'balanceDelta': 'التغير في الرصيد',
  'description': 'الوصف',
  'notes': 'ملاحظات',
  'note': 'ملاحظة',
  'date': 'التاريخ',
  'balanceAfter': 'الرصيد بعد العملية',
  'runningBalance': 'الرصيد بعد العملية',
  'order': 'الطلب',
  'orderId': 'معرف الطلب',
  'orderNumber': 'رقم الطلب',
  'deliveryFee': 'قيمة التوصيل',
  'shippingFee': 'قيمة التوصيل',
  'deliveryCost': 'قيمة التوصيل',
  'deliveryValue': 'قيمة التوصيل',
  'collectedAmount': 'المبلغ المحصل',
  'totalCollected': 'المبلغ المحصل',
  'collectedTotal': 'المبلغ المحصل',
  'status': 'الحالة',
  'paymentStatus': 'حالة الدفع',
  'currency': 'العملة',
  'referenceId': 'رقم المرجع',
  'transactionId': 'رقم العملية',
  'reason': 'السبب',
  'courier': 'المندوب',
  'courierId': 'معرف المندوب',
  'courierName': 'اسم المندوب',
  'adminId': 'معرف المسؤول',
  'adminName': 'اسم المسؤول',
  'customerId': 'معرف العميل',
  'customerName': 'اسم العميل',
  'address': 'العنوان',
  'success': 'نجاح',
  'message': 'رسالة',
};
