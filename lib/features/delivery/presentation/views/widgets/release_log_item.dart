import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/models/release_log_model.dart';
import 'package:alrayan_admin/features/delivery/presentation/utils/release_type_labels.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/extra_fields_section.dart';
import 'package:alrayan_admin/features/orders/presentation/utils/order_status_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ReleaseLogItem extends StatelessWidget {
  const ReleaseLogItem({super.key, required this.log});

  final ReleaseLog log;

  static const int _reasonPreviewLength = 90;

  @override
  Widget build(BuildContext context) {
    final date = _parseDate(log.createdAt);
    final reason = log.reason;
    final isLongReason = reason != null && reason.length > _reasonPreviewLength;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: releaseTypeColor(log.releaseType)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.sp15(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (log.releaseType != null)
                          _TypeBadge(type: log.releaseType!),
                        const Spacer(),
                        if (date != null) _Timeline(date: date),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),
                    Divider(height: 1, color: Colors.grey.shade200),
                    SizedBox(height: AppConstants.height10(context)),
                    _InfoLine(
                      label: "order_number".tr(),
                      value:
                          log.orderNumber ??
                          (log.orderId != null ? '#${log.orderId}' : '-'),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    _InfoLine(
                      label: "courier".tr(),
                      value:
                          log.courierName ??
                          (log.courierId != null ? '#${log.courierId}' : '-'),
                    ),
                    if ((log.courierPhone ?? '').isNotEmpty) ...[
                      SizedBox(height: AppConstants.height5(context)),
                      _InfoLine(
                        label: "phone_number".tr(),
                        value: log.courierPhone!,
                      ),
                    ],
                    if (log.statusBefore != null ||
                        log.statusAfter != null) ...[
                      SizedBox(height: AppConstants.height10(context)),
                      _StatusTransition(
                        before: log.statusBefore,
                        after: log.statusAfter,
                      ),
                    ],
                    if (reason != null) ...[
                      SizedBox(height: AppConstants.height10(context)),
                      Text(
                        "release_reason".tr(),
                        style: Styles.inter14500black(
                          context,
                        ).copyWith(color: const Color(0xff9CA4AB)),
                      ),
                      SizedBox(height: AppConstants.height5(context) / 2),
                      Text(
                        isLongReason
                            ? '${reason.substring(0, _reasonPreviewLength)}…'
                            : reason,
                        style: Styles.inter14600black(context),
                      ),
                      if (isLongReason)
                        GestureDetector(
                          onTap: () => _showReasonDialog(context, reason),
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: AppConstants.height5(context) / 2,
                            ),
                            child: Text(
                              "read_more".tr(),
                              style: Styles.inter12500Black(context).copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                    if ((log.performedByName ?? '').isNotEmpty) ...[
                      SizedBox(height: AppConstants.height10(context)),
                      _InfoLine(
                        label: "performed_by".tr(),
                        value: log.performedByRole != null
                            ? "${log.performedByName} (${log.performedByRole})"
                            : log.performedByName!,
                      ),
                    ],
                    ExtraFieldsSection(
                      raw: log.raw,
                      knownKeys: const {
                        'id',
                        'reason',
                        'createdAt',
                        'order',
                        'orderId',
                        'courier',
                        'courierId',
                        'courierName',
                        'courierPhone',
                        'releaseType',
                        'release_type',
                        'type',
                        'statusBefore',
                        'status_before',
                        'previousStatus',
                        'fromStatus',
                        'oldStatus',
                        'statusAfter',
                        'status_after',
                        'newStatus',
                        'toStatus',
                        'resultingStatus',
                        'performedBy',
                        'actor',
                        'admin',
                        'createdBy',
                        'performedByName',
                        'actorName',
                        'adminName',
                        'performedByRole',
                        'actorRole',
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReasonDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          "release_reason".tr(),
          style: Styles.inter16500black(context),
        ),
        content: SingleChildScrollView(
          child: Text(reason, style: Styles.inter14500black(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text("close".tr()),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String? isoDate) {
    if (isoDate == null) return null;
    return DateTime.tryParse(isoDate)?.toLocal();
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final color = releaseTypeColor(type);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width10(context),
        vertical: AppConstants.height5(context) / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Text(
        releaseTypeLabel(type),
        style: Styles.inter12500Black(
          context,
        ).copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusTransition extends StatelessWidget {
  const _StatusTransition({this.before, this.after});

  final String? before;
  final String? after;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusChip(
            label: "status_before".tr(),
            status: before,
            color: Colors.grey.shade600,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width5(context),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: AppConstants.sp15(context),
            color: Colors.grey.shade500,
          ),
        ),
        Expanded(
          child: _StatusChip(
            label: "status_after".tr(),
            status: after,
            color: releaseOutcomeColor(after),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.status,
    required this.color,
  });

  final String label;
  final String? status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Styles.inter12500Black(
            context,
          ).copyWith(color: const Color(0xff9CA4AB)),
        ),
        SizedBox(height: AppConstants.height5(context) / 2),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width10(context),
            vertical: AppConstants.height5(context) / 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(OrderStatusUi.icon(status), size: 12, color: color),
              SizedBox(width: AppConstants.width5(context)),
              Flexible(
                child: Text(
                  status == null ? '-' : AppConstants.getStatusText(status),
                  overflow: TextOverflow.ellipsis,
                  style: Styles.inter12500Black(
                    context,
                  ).copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: Styles.inter14500black(
              context,
            ).copyWith(color: const Color(0xff9CA4AB)),
          ),
          TextSpan(text: value, style: Styles.inter14600black(context)),
        ],
      ),
    );
  }
}

/// The little date/dot + time/clock stack shown at the top-end of the card.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.redColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Text(
              DateFormat(
                "d MMMM yyyy",
                CacheKeysManger.getUserLanguageFromCache(),
              ).format(date),
              style: Styles.inter14500black(context),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 8,
              child: Center(
                child: Container(
                  width: 1,
                  height: AppConstants.height15(context),
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Icon(
              Icons.access_time_rounded,
              size: 14,
              color: Colors.grey.shade500,
            ),
            SizedBox(width: AppConstants.width5(context)),
            Text(
              DateFormat(
                "hh:mm a",
                CacheKeysManger.getUserLanguageFromCache(),
              ).format(date),
              style: Styles.inter12500Black(
                context,
              ).copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
