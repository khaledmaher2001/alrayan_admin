import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';

import '../utils/text_styles/styles.dart';

cherryToast({
  required String text,
  bool isSuccess = true,
  required BuildContext context,
}) async {
  if (isSuccess) {
    CherryToast.success(title: Text(text, style: Styles.inter16500black(context))).show(context);
  } else {
    CherryToast.error(title: Text(text, style: Styles.inter16500black(context))).show(context);
  }
}
