import 'package:flutter/material.dart';

import '../utils/text_styles/styles.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackBar({
  required String message,
  required Color color,
  required BuildContext context,
}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Text(message,textAlign: TextAlign.center,style: Styles.inter16400white(context),)),
          ],
        ),
        backgroundColor: color,
      ),
    );