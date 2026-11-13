import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:readmore/readmore.dart';

import '../../../data/model/notifications_model.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key, required this.data, required this.index,
  });
  final Items data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isRead = data.recipients?.first.isRead ?? false;

    // Stack + PositionedDirectional accent bar — not IntrinsicHeight (its
    // sizing pass isn't implemented safely by ReadMoreText's custom layout
    // and crashes) and not a non-uniform BorderDirectional (BoxDecoration
    // rejects a borderRadius when the border's sides aren't all one color).
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xffE3E7EC)),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppConstants.sp15(context) + 4,
                end: AppConstants.sp15(context),
                top: AppConstants.sp15(context),
                bottom: AppConstants.sp15(context),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppConstants.sp10(context)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffE3E7EC)),
                    ),
                    child: Icon(Icons.notifications_none_rounded, color: AppColors.secondaryColor, size: 20),
                  ),
                  SizedBox(width: AppConstants.width15(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data.title ?? '',
                                style: Styles.inter16500black(context),
                              ),
                            ),
                            if (!isRead) ...[
                              SizedBox(width: AppConstants.width5(context)),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: AppConstants.height5(context)),
                        ReadMoreText(
                            data.message??'',
                            trimMode: TrimMode.Line,
                            trimLines: 2,
                            style: Styles.inter14500black(context).copyWith(color: const Color(0xff6A7282)),
                            colorClickableText: AppColors.primaryColor,
                            trimCollapsedText: "s_show_more".tr(),
                            trimExpandedText: "s_show_less".tr(),
                            lessStyle: Styles.inter14500black(context)
                                .copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                            moreStyle: Styles.inter14500black(context).copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: AppConstants.height10(context)),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: DsColor.textSubtle,
                              size: AppConstants.sp15(context),
                            ),
                            SizedBox(width: AppConstants.width5(context)),
                            // Shared date format (Latin digits, like every other date in the app).
                            Text(DsFormat.dateTime(context, data.createdAt), style: DsText.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
