import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/services/local_services/cache_helper.dart';
import 'onboarding_item.dart';

class _OnBoardingStep {
  _OnBoardingStep({
    required this.image,
    required this.title,
    required this.highlightedWord,
    required this.description,
  });

  final String image;
  final String title;
  final String highlightedWord;
  final String description;
}

// A getter so the texts follow the current language.
List<_OnBoardingStep> get _steps => [
  _OnBoardingStep(
    image: AssetData.onboarding1,
    title: "s_manage_your_whole_store".tr(),
    highlightedWord: "s_whole_store".tr(),
    description:
        "s_manage_products_categories_stock_ads".tr(),
  ),
  _OnBoardingStep(
    image: AssetData.onboarding2,
    title: "s_smarter_decisions_more_sales".tr(),
    highlightedWord: "s_smarter".tr(),
    description:
        "s_track_sales_and_analyse_customers_or".tr(),
  ),
  _OnBoardingStep(
    image: AssetData.onboarding3,
    title: "s_marketing_and_delivery_under_your_co".tr(),
    highlightedWord: "s_your_control".tr(),
    description:
        "s_create_coupons_and_the_lucky_wheel_s".tr(),
  ),
];

class OnBoardingViewBody extends StatefulWidget {
  const OnBoardingViewBody({super.key});

  @override
  State<OnBoardingViewBody> createState() => _OnBoardingViewBodyState();
}

class _OnBoardingViewBodyState extends State<OnBoardingViewBody> {
  final PageController controller = PageController(initialPage: 0);
  int currentIndex = 0;

  bool get isLastScreen => currentIndex >= _steps.length - 1;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _steps.length) return;
    controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnBoarding() {
    CacheHelper.saveData(key: "onBoarding", value: true);
    GoRouter.of(context).go("/loginView");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width10(context),
            ),
            child: Opacity(
              opacity: isLastScreen ? 0 : 1,
              child: IgnorePointer(
                ignoring: isLastScreen,
                child: TextButton(
                  onPressed: _finishOnBoarding,
                  child: Text(
                    "s_skip".tr(),
                    style: Styles.inter16400white(context).copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: _steps.length,
            onPageChanged: (index) => setState(() => currentIndex = index),
            itemBuilder: (context, index) {
              final step = _steps[index];
              return OnBoardingItem(
                key: ValueKey(index),
                image: step.image,
                title: step.title,
                highlightedWord: step.highlightedWord,
                description: step.description,
                noOfScreen: _steps.length,
                currentScreenNo: index,
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width30(context),
          ),
          child: currentIndex == 0
              ? DefaultButton(
                  onPress: () => _goToPage(currentIndex + 1),
                  text: "s_continue".tr(),
                  borderRadius: AppConstants.sp10(context),
                )
              : Row(
                  children: [
                    Expanded(
                      child: DefaultButton(
                        onPress: () => _goToPage(currentIndex - 1),
                        text: "s_back".tr(),
                        hasBorder: true,
                        backgroundColor: Colors.white,
                        textColor: AppColors.primaryColor,
                        borderColor: AppColors.primaryColor,
                        elevation: 0,
                        borderRadius: AppConstants.sp10(context),
                      ),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    Expanded(
                      child: DefaultButton(
                        onPress: () {
                          if (isLastScreen) {
                            _finishOnBoarding();
                          } else {
                            _goToPage(currentIndex + 1);
                          }
                        },
                        text: isLastScreen ? "s_start_managing".tr() : "s_continue".tr(),
                        borderRadius: AppConstants.sp10(context),
                      ),
                    ),
                  ],
                ),
        ),
        SizedBox(height: AppConstants.height20(context)),
      ],
    );
  }
}
