import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/cupertino.dart';

class TextFieldHeader extends StatelessWidget {
  const TextFieldHeader({super.key, required this.text, this.isRequired = true});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: Styles.inter16500black(context)),
        if (isRequired) ...[
          SizedBox(width: AppConstants.width5(context) / 2),
          Text("*", style: Styles.inter16500black(context).copyWith(color: AppColors.redColor)),
        ],
      ],
    );
  }
}
