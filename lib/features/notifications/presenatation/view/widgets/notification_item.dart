import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:readmore/readmore.dart';

import '../../../../../core/utils/services/local_services/cache_keys.dart';
import '../../../data/model/notifications_model.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key, required this.data, required this.index,
  });
  final Items data;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        color: data.recipients!.first.isRead!
            ? Colors.white
            : Color(0xffF2F2F2)
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
                Text(data.title??'',
                    style: Styles.inter14500black(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor)),
                SizedBox(height: AppConstants.height5(context)),
                ReadMoreText(
                    data.message??'',
                    trimMode: TrimMode.Line,
                    trimLines: 2,
                    style: Styles.inter14500black(context),
                    colorClickableText: AppColors.gray,
                    trimCollapsedText: 'عرض المزيد',
                    trimExpandedText: 'عرض اقل',
                    lessStyle: Styles.inter14500black(context)
                        .copyWith(color: AppColors.gray),
                    moreStyle: Styles.inter14500black(context).copyWith(
                      color: AppColors.gray,
                    )),
                SizedBox(height: AppConstants.height10(context)),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: AppColors.gray,
                      size: AppConstants.sp20(context),
                    ),
                    SizedBox(width: AppConstants.width5(context)),
                    Text(DateFormat(
                        "d MMMM , y  h:mm a",
                        CacheKeysManger
                            .getUserLanguageFromCache())
                        .format(DateTime.parse(data.createdAt??
                        '')),
                        // DateFormat('h:mm a').format(DateTime.parse(data.createdAt ?? "")

                        // ),
                        style: Styles.inter14500black(context).copyWith(
                          color: AppColors.gray,
                        )),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
