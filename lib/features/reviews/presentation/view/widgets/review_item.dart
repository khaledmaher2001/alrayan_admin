import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/features/reviews/data/models/reviews_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'order_bottom_sheet.dart';

/// One customer review: who, stars and date, the comment, and a text action
/// to open the related order.
class ReviewItem extends StatelessWidget {
  const ReviewItem({super.key, required this.data, required this.index});

  final Items data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final name = data.user?.fullName ?? '';
    final initials = name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
    final rating = double.tryParse('${data.rating}') ?? 0;
    final date = DateTime.tryParse(data.createdAt ?? '');
    return DsCard(
      padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, DsSpace.md, DsSpace.sm, DsSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: DsColor.primarySoft, shape: BoxShape.circle),
                child: Text(initials, style: DsText.label.copyWith(color: DsColor.onPrimarySoft)),
              ),
              const SizedBox(width: DsSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.bodyStrong),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _Stars(rating: rating),
                        if (date != null) ...[
                          const SizedBox(width: DsSpace.sm),
                          Text(DsFormat.date(context, data.createdAt), style: DsText.caption),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((data.comment ?? '').isNotEmpty) ...[
            const SizedBox(height: DsSpace.md),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: DsSpace.sm),
              child: Text(data.comment!, style: DsText.body.copyWith(color: DsColor.text2)),
            ),
          ],
          if (data.order?.id != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
                  builder: (context) => OrderBottomSheet(orderId: data.order!.id!),
                ),
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: Text("s_view_order".tr()),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '${rating.toStringAsFixed(1)} / 5',
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              Icon(
                rating >= i ? Icons.star_rounded : (rating >= i - .5 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                size: 16,
                color: rating >= i - .5 ? const Color(0xFFF5A623) : DsColor.border,
              ),
          ],
        ),
      );
}
