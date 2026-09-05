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
                  color: Colors.red.shade50,
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
            "إلغاء الطلب",
            textAlign: TextAlign.center,
            style: Styles.inter16500black(context),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            "سيؤدي هذا الإجراء إلى إنهاء الطلب نهائيًا ولا يمكن التراجع عنه.",
            style: Styles.inter14500black(
              context,
            ).copyWith(color: Colors.red.shade400),
          ),
          SizedBox(height: AppConstants.height15(context)),
          Text("سبب الإلغاء", style: Styles.inter14500black(context)),
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
              hintText: "اكتب سبب إلغاء الطلب",
              hintStyle: Styles.hintText(context),
              filled: true,
              fillColor: const Color(0xffF5F6FA),
              contentPadding: EdgeInsets.all(AppConstants.sp10(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                borderSide: BorderSide(
                  color: showError ? AppColors.redColor : Colors.grey.shade300,
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
              "سبب الإلغاء مطلوب",
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
                    "إلغاء الطلب",
                    style: Styles.inter16500black(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "رجوع",
                  style: Styles.inter16500black(
                    context,
                  ).copyWith(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
