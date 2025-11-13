import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
class TopCustomerItem extends StatelessWidget {
  const TopCustomerItem({super.key, required this.instance});
  final TopCustomers instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppConstants.sp10(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(
              0,
              0,
            ), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "العملاء الاكثر تفاعلا",
                  style: Styles.inter16500black(context),
                ),
              ),
              SizedBox(width: AppConstants.width20(context)),
              InkWell(
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => AllReviewsView()));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width15(context),
                    vertical:
                    AppConstants.height10(context) / 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.shade50,
                    borderRadius: BorderRadius.circular(
                      AppConstants.sp5(context),
                    ),
                  ),
                  child: Text(
                    "عرض الكل",
                    style: Styles.inter10400grey(
                      context,
                    ).copyWith(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          Text(
            "حاول انشاء كوبونات خصم تشجيعا للعملاء الاكثر طلبا",
            style: Styles.inter10400grey(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                  AppConstants.sp5(context),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp10(context),
                  ),
                  color: AppColors.gray.withOpacity(.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp10(context),
                  ),
                  child: Container(
                    height:
                    MediaQuery.of(context).size.width * .12,
                    width:
                    MediaQuery.of(context).size.width * .12,
                    child: Center(
                      child: Text(
                        instance.fullName!
                            .substring(0, 1)
                            .toUpperCase(),
                        style: Styles.inter18500Black(context),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instance.fullName!,
                      style: Styles.inter14500black(context),
                    ),
                    SizedBox(
                      height: AppConstants.height5(context),
                    ),
                    Text(
                      instance.email!,
                      style: Styles.inter10400grey(context),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "الطلبات",
                    style: Styles.inter14500black(context),
                  ),
                  Text(
                    "${instance.orderCount} طلب",
                    style: Styles.inter10400grey(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
