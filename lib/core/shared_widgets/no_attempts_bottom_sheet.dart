import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/main_layout/presentation/views/main_layout_view.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/utils/constants.dart';
import '../utils/colors/colors.dart';
import '../utils/text_styles/styles.dart';

class NoAttemptsBottomSheet extends StatefulWidget {
  const NoAttemptsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return NoAttemptsBottomSheet();
      },
    );
  }

  @override
  State<NoAttemptsBottomSheet> createState() => _NoAttemptsBottomSheetState();
}

class _NoAttemptsBottomSheetState extends State<NoAttemptsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.height10(context),
          horizontal: AppConstants.width20(context),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: AppConstants.height5(context),
              width: MediaQuery.sizeOf(context).width * .45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppConstants.width20(context),
                ),
                color: Colors.grey.withOpacity(.3),
              ),
            ),
            SizedBox(height: AppConstants.height10(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("لا محاولات".tr(), style: Styles.inter18500Black(context)),
              ],
            ),
            SizedBox(height: AppConstants.height15(context)),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)*2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(AssetData.noSpin,width: MediaQuery.of(context).size.width*.3,color: AppColors.gray.withOpacity(.5),),
                      Text(
                        "لا توجد ليدك اي محاولات اخري".tr(),
                        style: Styles.inter14600gray(context),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppConstants.height20(context)),
                      Text(
                        "أبدا في التسوق وقم بعملية شراء حتي تتمكن من لعب عجلة الحظ الخاصة بك".tr(),
                        style: Styles.inter14600gray(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: AppConstants.height20(context),),
            DefaultButton(onPress: (){
              context.read<ChangeNavBarStatusCubit>().currentIndex=0;
              NavigationUtils.navigateReplacement(context: context, destinationScreen: MainLayoutView());
            }, text: "أبدا التسوق الان",borderRadius: AppConstants.sp10(context),),
            SizedBox(height: AppConstants.height20(context),),

          ],
        ),
      )
    );
  }
}
