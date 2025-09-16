import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class DoubleText extends StatelessWidget {
  DoubleText(
      {super.key,
      required this.firstText,
      required this.secondText,
      this.secondTextStyle,
      this.onPress,
     } );

  final String firstText;
  final String secondText;
  TextStyle? secondTextStyle;
  GestureRecognizer? onPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width10(context)),
      child: RichText(
        text: TextSpan(
            style: Styles.inter16500black(context),
            text: firstText,
            children: <InlineSpan>[
              TextSpan(
                recognizer:onPress ,
                  text: secondText,
                  style: secondTextStyle ?? Styles.inter16500black(context).copyWith(color: AppColors.primaryColor))
            ]),
      ),
    );
  }
}
