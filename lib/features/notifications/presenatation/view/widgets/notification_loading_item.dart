import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/constants.dart';

class NotificationLoadingItem extends StatelessWidget {
  const NotificationLoadingItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => Container(
              padding: EdgeInsets.all(AppConstants.sp20(context)),
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppConstants.sp10(context)),
                    decoration: BoxDecoration(

                        shape: BoxShape.circle,
                        color: Color(0xffFAFAFA)),
                    child: SvgPicture.asset(AssetData.bell),
                  ),
                  SizedBox(width: AppConstants.width15(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor:Colors.grey[400]!,
                          highlightColor: Colors.grey[200]!,
                          child: Container(
                            height: MediaQuery.of(context).size.width * .025,
                            width: MediaQuery.of(context).size.width * .22,
                            decoration: BoxDecoration(
                                color: AppColors.gray,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.sp30(context))),
                          ),
                        ),
                        SizedBox(height: AppConstants.height5(context)),
                        Shimmer.fromColors(
                          baseColor:Colors.grey[400]!,
                          highlightColor: Colors.grey[200]!,
                          child: Container(
                            height: MediaQuery.of(context).size.width * .02,
                            width: MediaQuery.of(context).size.width * .8,
                            decoration: BoxDecoration(
                                color: AppColors.gray,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.sp30(context))),
                          ),
                        ),
                        SizedBox(height: AppConstants.height5(context)),
                        Shimmer.fromColors(
                          baseColor:Colors.grey[400]!,
                          highlightColor: Colors.grey[200]!,
                          child: Container(
                            height: MediaQuery.of(context).size.width * .02,
                            width: MediaQuery.of(context).size.width * .8,
                            decoration: BoxDecoration(
                                color: AppColors.gray,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.sp30(context))),
                          ),
                        ),
                        SizedBox(height: AppConstants.height5(context)),
                        Shimmer.fromColors(
                          baseColor:Colors.grey[400]!,
                          highlightColor: Colors.grey[200]!,
                          child: Container(
                            height: MediaQuery.of(context).size.width * .02,
                            width: MediaQuery.of(context).size.width * .8,
                            decoration: BoxDecoration(
                                color: AppColors.gray,
                                borderRadius: BorderRadius.circular(
                                    AppConstants.sp30(context))),
                          ),
                        ),
                        SizedBox(height: AppConstants.height10(context)),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: AppColors.gray,
                              size: AppConstants.sp20(context),
                            ),
                            SizedBox(width: AppConstants.width5(context)),
                            Shimmer.fromColors(
                              baseColor:Colors.grey[400]!,
                              highlightColor: Colors.grey[200]!,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.width * .025,
                                width: MediaQuery.of(context).size.width * .22,
                                decoration: BoxDecoration(
                                    color: AppColors.gray,
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.sp30(context))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            separatorBuilder: (context, index) =>
                Divider(color: Color(0xffF2F2F2),height: 0,),
            itemCount: 8,
          ),
        ),
      ],
    );
  }
}
