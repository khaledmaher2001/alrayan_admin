import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/helpers/cairo_time.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../data/models/scheduled_notification_model.dart';

/// Status pill colours (text, faint background).
(Color, Color) scheduledStatusColors(String status) => switch (status) {
      'scheduled' => (DsColor.info, DsColor.infoBg),
      'sending' => (DsColor.warning, DsColor.warningBg),
      'sent' => (DsColor.success, DsColor.successBg),
      'failed' => (DsColor.danger, DsColor.dangerBg),
      _ => (DsColor.text2, DsColor.fill),
    };

class ScheduledNotificationCard extends StatelessWidget {
  const ScheduledNotificationCard({
    super.key,
    required this.item,
    required this.canSend,
    required this.cancelling,
    required this.onEdit,
    required this.onCopy,
    required this.onCancel,
  });

  final ScheduledNotificationModel item;
  final bool canSend;
  final bool cancelling;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final r = item;
    final (fg, bg) = scheduledStatusColors(r.status);
    final audience = r.audience == 'users'
        ? "sn_some_customers".tr(namedArgs: {"n": DsFormat.count(r.usersCount ?? r.userIds.length)})
        : "sn_all_customers".tr();
    final target = "sn_target_${r.targetScreen}".tr() + (r.targetLabel != null ? ' · ${r.targetLabel}' : '');

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(DsRadius.sm),
                child: (r.imageUrl ?? '').isNotEmpty
                    ? Image.network(r.imageUrl!, width: 44, height: 44, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const _IconTile())
                    : const _IconTile(),
              ),
              const SizedBox(width: DsSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.bodyStrong),
                    Text(r.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: DsText.caption),
                    if (r.createdByName != null)
                      Text("sn_by".tr(namedArgs: {"name": r.createdByName!}), style: DsText.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpace.md),
          Wrap(
            spacing: DsSpace.sm,
            runSpacing: DsSpace.xs,
            children: [
              DsStatusBadge(status: null, label: "sn_st_${r.status}".tr(), fg: fg, bg: bg),
              if (r.repeat != 'none')
                DsStatusBadge(status: null, icon: Icons.repeat_rounded, label: "sn_repeat_${r.repeat}".tr(), fg: DsColor.info, bg: DsColor.infoBg),
            ],
          ),
          const SizedBox(height: DsSpace.sm),
          _Line(icon: Icons.group_outlined, text: audience),
          _Line(icon: Icons.touch_app_outlined, text: "${"sn_col_target".tr()}: $target"),
          if (r.nextRunAt != null)
            _Line(
              icon: Icons.schedule_rounded,
              text: (r.repeat != 'none' && r.runCount > 0 ? "${"sn_next".tr()}: " : "") + CairoTime.format(context, r.nextRunAt),
            ),
          if (r.lastRunAt != null)
            _Line(icon: Icons.history_rounded, text: "${"sn_last".tr()}: ${CairoTime.format(context, r.lastRunAt)}"),
          if (r.nextRunAt == null && r.lastRunAt == null)
            _Line(icon: Icons.schedule_rounded, text: CairoTime.format(context, r.sendAt)),
          if (r.lastRecipients != null)
            _Line(icon: Icons.mark_email_read_outlined, text: "sn_sent_to".tr(namedArgs: {"n": DsFormat.count(r.lastRecipients)})),
          if (r.repeat != 'none' && r.runCount > 0)
            _Line(icon: Icons.repeat_rounded, text: "sn_runs".tr(namedArgs: {"n": DsFormat.count(r.runCount)})),
          if (r.lastError != null)
            _Line(icon: Icons.error_outline_rounded, text: r.lastError!, color: DsColor.danger),
          if (canSend) ...[
            const SizedBox(height: DsSpace.sm),
            const Divider(height: 1, color: DsColor.divider),
            const SizedBox(height: DsSpace.xs),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: DsSpace.xs,
              children: [
                if (r.isScheduled)
                  TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18), label: Text("sn_edit".tr())),
                TextButton.icon(onPressed: onCopy, icon: const Icon(Icons.copy_rounded, size: 18), label: Text("sn_again".tr())),
                if (r.isScheduled)
                  TextButton.icon(
                    onPressed: cancelling ? null : onCancel,
                    style: TextButton.styleFrom(foregroundColor: DsColor.danger),
                    icon: cancelling
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.close_rounded, size: 18),
                    label: Text("sn_stop".tr()),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile();

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        color: DsColor.primarySoft,
        child: const Icon(Icons.notifications_outlined, color: DsColor.primary, size: 20),
      );
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color ?? DsColor.textMuted),
            const SizedBox(width: DsSpace.sm),
            Expanded(child: Text(text, style: DsText.caption.copyWith(color: color ?? DsColor.text2))),
          ],
        ),
      );
}
