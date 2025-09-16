import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';

import '../../../../../core/utils/colors/colors.dart';
import 'double_text.dart';

class DividedRow extends StatelessWidget {
  const DividedRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1,
            color: AppColors.gray,
          ),
        ),
        DoubleText(
          firstText: "dontHaveAccount".tr(),
          secondText: "register".tr(),
          onPress: TapGestureRecognizer()
            ..onTap = () {
              GoRouter.of(context).push("/registerView");
            },
        ),
        const Expanded(
          child: Divider(
            thickness: 2,
            color: AppColors.gray,
          ),
        ),
      ],
    );
  }
}
