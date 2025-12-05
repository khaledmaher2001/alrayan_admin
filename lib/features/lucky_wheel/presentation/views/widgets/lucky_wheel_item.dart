import 'package:alrayan_admin/features/lucky_wheel/data/models/lucky_wheel_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import 'custom_switch.dart';
class LuckyWheelItem extends StatelessWidget {
  const LuckyWheelItem({super.key, required this.instance, required this.index});
  final Rewards instance;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width20(context),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppConstants.sp10(context),
          ),
          color: AppColors.gray.withOpacity(.1),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                  AppConstants.sp10(context),
                ),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadiusDirectional.horizontal(
                    start: Radius.circular(
                      AppConstants.sp10(context),
                    ),
                  ),
                  color: Colors.red,
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: Styles.DIN24500(context),
                  ),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    AppConstants.sp20(context),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(
                                    AppConstants.sp5(context),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(
                                      AppConstants.sp5(
                                        context,
                                      ),
                                    ),
                                    color: AppColors.redColor
                                        .withOpacity(.1),
                                  ),
                                  child: Text(
                                   instance
                                        .couponCode??'',
                                    style:
                                    Styles.inter14500black(
                                      context,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                  AppConstants.height5(
                                    context,
                                  ),
                                ),
                                Text(
                                  instance
                                      .discountType??'',
                                  style:
                                  Styles.inter14600gray(
                                    context,
                                  ).copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                  AppConstants.height5(
                                    context,
                                  ),
                                ),
                                Text(
                                  instance
                                      .displayText!,
                                  style:
                                  Styles.inter14600gray(
                                    context,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: AppConstants.height10(
                                context,
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      AppConstants.sp5(
                                        context,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AssetData.edit,
                                      width:
                                      MediaQuery.of(
                                        context,
                                      ).size.width *
                                          .06,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: AppConstants.width10(
                                    context,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      AppConstants.sp5(
                                        context,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AssetData.delete,
                                      width:
                                      MediaQuery.of(
                                        context,
                                      ).size.width *
                                          .06,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            "نسبة ظهورة",
                            style: Styles.inter14600gray(
                              context,
                            ).copyWith(color: Colors.black),
                          ),
                          SizedBox(
                            height: AppConstants.height5(
                              context,
                            ),
                          ),
                          Text(
                            "%${instance.probability!*100}",
                            style: Styles.DIN20500(context)
                                .copyWith(
                              color:
                              AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: AppConstants.height10(
                              context,
                            ),
                          ),
                          Text(
                            "تفعيل العنصر",
                            style: Styles.inter14600gray(
                              context,
                            ).copyWith(color: Colors.black),
                          ),
                          SizedBox(
                            height: AppConstants.height5(
                              context,
                            ),
                          ),
                          SmallSwitch(
                            value: instance
                                .isActive??false,
                            onChanged: (v) {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
