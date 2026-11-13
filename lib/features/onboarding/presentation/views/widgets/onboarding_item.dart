import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'progress_dots.dart';

/// Purely presentational onboarding step: illustration (over the shared
/// background pattern), progress dots, title (with one highlighted word)
/// and description — each revealed with a staggered entrance animation.
/// Paging (next/previous/skip) is handled by [OnBoardingViewBody].
class OnBoardingItem extends StatelessWidget {
  const OnBoardingItem({
    super.key,
    required this.image,
    required this.noOfScreen,
    required this.currentScreenNo,
    required this.title,
    required this.highlightedWord,
    required this.description,
  });

  /// Dashboard-mockup illustration for this step.
  final String image;
  final String title;

  /// The word/phrase inside [title] to render in the primary color. Must
  /// appear verbatim inside [title].
  final String highlightedWord;
  final String description;

  final int noOfScreen;

  final int currentScreenNo;

  List<InlineSpan> _titleSpans(BuildContext context) {
    final index = title.indexOf(highlightedWord);
    if (index < 0) return [TextSpan(text: title)];

    final before = title.substring(0, index);
    final after = title.substring(index + highlightedWord.length);
    return [
      if (before.isNotEmpty) TextSpan(text: before),
      TextSpan(
        text: highlightedWord,
        style: TextStyle(color: AppColors.primaryColor),
      ),
      if (after.isNotEmpty) TextSpan(text: after),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final illustrationSize = MediaQuery.of(context).size.width ;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: illustrationSize,
          height: illustrationSize,
          child: Padding(
            padding: EdgeInsets.all(illustrationSize * .02),
            child: Image.asset(image, fit: BoxFit.contain),
          ),
        )
            .animate()
            .fadeIn(duration: 450.ms)
            .scale(
              begin: const Offset(.85, .85),
              end: const Offset(1, 1),
              curve: Curves.easeOutBack,
              duration: 450.ms,
            ),
        SizedBox(height: AppConstants.height20(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int index = 0; index < noOfScreen; index++)
              ProgressDots(isActiveScreen: index == currentScreenNo),
          ],
        ).animate().fadeIn(delay: 150.ms, duration: 350.ms),
        SizedBox(height: AppConstants.height20(context)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width30(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Styles.DIN32700(context),
                  children: _titleSpans(context),
                ),
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms)
                  .slideY(
                    begin: .25,
                    end: 0,
                    curve: Curves.easeOut,
                    duration: 400.ms,
                  ),
              SizedBox(height: AppConstants.height5(context)),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Styles.DIN16700(context).copyWith(
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(
                    begin: .25,
                    end: 0,
                    curve: Curves.easeOut,
                    duration: 400.ms,
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
