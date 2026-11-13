import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/material.dart';

/// Dialog shown before `PUT /orders/:id/cancel`. Collects a mandatory
/// cancellation reason and passes it to [onConfirm].
Future<void> showCancelOrderDialog({
  required BuildContext context,
  required void Function(String reason) onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => _CancelOrderDialog(onConfirm: onConfirm),
  );
}

class _CancelOrderDialog extends StatefulWidget {
  const _CancelOrderDialog({required this.onConfirm});

  final void Function(String reason) onConfirm;

  @override
  State<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  final TextEditingController reasonController = TextEditingController();
  bool showError = false;

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => showError = true);
      return;
    }
    Navigator.of(context).pop();
    widget.onConfirm(reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DsColor.dangerBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: MediaQuery.of(context).size.width * .08,
                  color: AppColors.redColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            "s_cancel_order".tr(),
            textAlign: TextAlign.center,
            style: Styles.inter16500black(context),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            "s_this_ends_the_order_for_good_and_can".tr(),
            style: Styles.inter14500black(
              context,
            ).copyWith(color: DsColor.danger),
          ),
          SizedBox(height: AppConstants.height15(context)),
          Text("s_cancellation_reason".tr(), style: Styles.inter14500black(context)),
          SizedBox(height: AppConstants.height5(context)),
          TextField(
            controller: reasonController,
            maxLines: 3,
            textAlign: TextAlign.right,
            style: Styles.inter14500black(context),
            onChanged: (_) {
              if (showError) setState(() => showError = false);
            },
            decoration: InputDecoration(
              hintText: "s_write_the_cancellation_reason".tr(),
              hintStyle: Styles.hintText(context),
              filled: true,
              fillColor: const Color(0xffF5F6FA),
              contentPadding: EdgeInsets.all(AppConstants.sp10(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                borderSide: BorderSide(color: DsColor.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                borderSide: BorderSide(
                  color: showError ? AppColors.redColor : DsColor.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          if (showError) ...[
            SizedBox(height: AppConstants.height5(context)),
            Text(
              "s_cancellation_reason_is_required".tr(),
              style: Styles.inter12500Black(
                context,
              ).copyWith(color: AppColors.redColor),
            ),
          ],
          SizedBox(height: AppConstants.height20(context)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    "s_cancel_order".tr(),
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "s_back_2".tr(),
                  style: Styles.inter16500black(
                    context,
                  ).copyWith(color: DsColor.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
