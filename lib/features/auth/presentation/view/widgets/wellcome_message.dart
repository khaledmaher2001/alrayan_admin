import 'package:flutter/material.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage(
      {super.key, required this.title, required this.supTitle});

  final String title;
  final String supTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Styles.inter28600black(context).copyWith(
                color: Colors.white
              ),
            ),
          ],
        ),
        SizedBox(
          height: AppConstants.height10(context),
        ),
        Text(
          supTitle,
          style: Styles.inter14600gray(context).copyWith(
            color: Colors.white
          ),
        ),
      ],
    );
  }
}
