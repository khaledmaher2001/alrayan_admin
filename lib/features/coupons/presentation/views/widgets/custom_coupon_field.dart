import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/material.dart';

class CustomCouponField extends StatelessWidget {
  const CustomCouponField({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    required this.keyboardType, required this.validationText, this.onTap, this.readOnly=false,
  });

  final String title, hint,validationText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Function()? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: Styles.inter14600black(context)),
            Text("*", style: Styles.inter14600black(context).copyWith(color: AppColors.redColor)),
          ],
        ),
        SizedBox(height: AppConstants.height5(context)),
        DefaultTextFormField(
          onTap: onTap,
          validation: (String? value) {
            if (value == null || value.isEmpty) {
              return validationText;
            }
            return null;
          },
          style: Styles.inter14600black(context),
          fillColor: const Color(0xffF7F7F8),
          contentPaddingHorizontal: AppConstants.width15(context),
          hintText: hint,
          textInputType: keyboardType,
          controller: controller,
          readOnly: readOnly,
          contentPaddingVertical: AppConstants.height15(context),
        ),
      ],
    );
  }
}
