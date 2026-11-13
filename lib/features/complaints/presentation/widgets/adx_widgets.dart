import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';

import '../../data/admin_complaints_repo.dart';

/// "9 Oct 2026, 7:54 PM" in the app language, with 0-9 digits like the rest of the app.
String adxDate(BuildContext context, DateTime d, {bool time = true}) {
  final lang = context.locale.languageCode;
  final pattern = time ? (lang == 'ar' ? 'd MMM yyyy، h:mm a' : 'd MMM yyyy, h:mm a') : 'd MMM yyyy';
  return DateFormat(pattern, lang).format(d).replaceAllMapped(
        RegExp('[٠-٩]'),
        (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0x0660 + 0x30),
      );
}

// Status meaning colours (not brand colours): waiting, in progress, needs customer, done, closed.
const _statusColors = {
  'pending': (Color(0xFFFFF4D6), Color(0xFF8A5A00)),
  'in_review': (Color(0xFFE3F0FF), Color(0xFF1F5FAD)),
  'in_progress': (Color(0xFFE3F0FF), Color(0xFF1F5FAD)),
  'awaiting_customer': (Color(0xFFFFE9D6), Color(0xFFB04A00)),
  'resolved': (Color(0xFFE2F5E8), Color(0xFF15803D)),
  'approved': (Color(0xFFE2F5E8), Color(0xFF15803D)),
  'rejected': (Color(0xFFEEEEEE), Color(0xFF555555)),
};

class AdxChip extends StatelessWidget {
  const AdxChip({super.key, required this.text, required this.bg, required this.fg, this.icon});
  final String text;
  final Color bg, fg;
  final IconData? icon;

  factory AdxChip.status(String status) {
    final (bg, fg) = _statusColors[status] ?? (const Color(0xFFEEEEEE), const Color(0xFF555555));
    return AdxChip(text: AdxLabels.status(status), bg: bg, fg: fg);
  }

  factory AdxChip.priority(String p) => switch (p) {
        'high' => AdxChip(text: AdxLabels.priority(p), bg: const Color(0xFFFDECEC), fg: const Color(0xFFB91C1C), icon: Icons.priority_high_rounded),
        'low' => AdxChip(text: AdxLabels.priority(p), bg: const Color(0xFFF1F2F4), fg: const Color(0xFF4B5563)),
        _ => AdxChip(text: AdxLabels.priority(p), bg: const Color(0xFFF1F2F4), fg: const Color(0xFF374151)),
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 13, color: fg),
            Text(text, style: Styles.inter10400grey(context).copyWith(color: fg, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class AdxStat extends StatelessWidget {
  const AdxStat({super.key, required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffEDEDED)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: Styles.inter18500Black(context).copyWith(color: color, fontWeight: FontWeight.w700)),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Styles.inter10400grey(context)),
            ],
          ),
        ),
      );
}

class AdxComplaintCard extends StatelessWidget {
  const AdxComplaintCard({super.key, required this.c, required this.onTap});
  final AdminComplaint c;
  final VoidCallback onTap;

  static const _typeIcons = {
    'complaint': Icons.report_problem_outlined,
    'inquiry': Icons.help_outline,
    'suggestion': Icons.lightbulb_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        side: BorderSide(color: c.isOverdue ? const Color(0xFFF5C2C2) : const Color(0xffEDEDED)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppConstants.sp15(context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: .08), shape: BoxShape.circle),
                child: Icon(_typeIcons[c.type] ?? Icons.forum_outlined, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Styles.inter14600black(context)),
                        ),
                        const SizedBox(width: 8),
                        AdxChip.status(c.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AdxLabels.type(c.type)} · ${AdxLabels.category(c.category)} · ${c.customer?.label ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.inter12500Black(context).copyWith(color: const Color(0xff6B7280)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('#${c.id} · ${adxDate(context, c.updatedAt, time: false)}', style: Styles.inter10400grey(context)),
                        if (c.priority != 'normal') AdxChip.priority(c.priority),
                        if (c.isOverdue) AdxChip(text: 'adx_late'.tr(), bg: const Color(0xFFFDECEC), fg: const Color(0xFFB91C1C), icon: Icons.schedule_rounded),
                        if (c.assignedTo == null && c.status != 'resolved' && c.status != 'rejected')
                          AdxChip(text: 'adx_unassigned'.tr(), bg: const Color(0xFFFFF4D6), fg: const Color(0xFF8A5A00)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdxMessage extends StatelessWidget {
  const AdxMessage({super.key, required this.icon, required this.title, this.action});
  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: .08), shape: BoxShape.circle),
                child: Icon(icon, size: 38, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 14),
              Text(title, textAlign: TextAlign.center, style: Styles.inter16500black(context)),
              if (action != null) ...[const SizedBox(height: 8), action!],
            ],
          ),
        ),
      );
}
