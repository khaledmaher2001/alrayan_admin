import 'package:flutter/material.dart';

import '../../../../../core/utils/colors/colors.dart';

class ProgressDots extends StatelessWidget {
  const ProgressDots({super.key, required this.isActiveScreen});

  final bool isActiveScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .01),
      height: MediaQuery.of(context).size.width * .022,
      width: isActiveScreen
          ? MediaQuery.of(context).size.width * .066
          : MediaQuery.of(context).size.width * .022,
      decoration: BoxDecoration(
          color: isActiveScreen
              ? AppColors.primarySwatchColor
              : const Color(0xffD6D6D6),
          borderRadius: BorderRadius.all(
              Radius.circular(MediaQuery.of(context).size.width * .02))),
    );
  }
}
