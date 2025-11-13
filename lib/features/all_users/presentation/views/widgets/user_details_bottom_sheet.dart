import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/features/all_users/data/models/all_users_model.dart';
import 'package:alrayan_admin/features/all_users/presentation/views/widgets/user_orders_chart.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/statistics_home_item.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';


class UserDetailsBottomSheet extends StatefulWidget {
  const UserDetailsBottomSheet({super.key, required this.userData});
  final Items userData;

  @override
  State<UserDetailsBottomSheet> createState() => _UserDetailsBottomSheetState();
}

class _UserDetailsBottomSheetState extends State<UserDetailsBottomSheet> {
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.81,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
         ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.height15(context)),
          Align(
            alignment: AlignmentDirectional.center,
            child: Container(
              height: AppConstants.height5(context),
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(AppConstants.sp10(context)),
                  color: AppColors.gray),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppConstants.height10(context),),
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
                            child: SizedBox(
                              height:
                              MediaQuery.of(context).size.width * .12,
                              width:
                              MediaQuery.of(context).size.width * .12,
                              child: Center(
                                child: Text(
                                  widget.userData.fullName!
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
                                widget.userData.fullName!,
                                style: Styles.inter14500black(context),
                              ),
                              SizedBox(
                                height: AppConstants.height5(context),
                              ),
                              Text(
                                widget.userData.email!,
                                style: Styles.inter10400grey(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height20(context),),
                    Row(
                      children: [
                        StatisticsHomeItem(icon: AssetData.accountStatus, title: "حالة الحساب", value: "نشطة",size: MediaQuery.of(context).size.width*.07,),
                        SizedBox(width: AppConstants.width10(context),),
                        StatisticsHomeItem(icon: AssetData.totalMoney, title: "قيمة الشراء", value: "2,530",size: MediaQuery.of(context).size.width*.07,),
                      ],
                    ),
                    SizedBox(height: AppConstants.height20(context),),
                    Row(
                      children: [
                        StatisticsHomeItem(icon: AssetData.orders, title: "الطلبات", value: "135",size: MediaQuery.of(context).size.width*.07,),
                        SizedBox(width: AppConstants.width10(context),),
                        StatisticsHomeItem(icon: AssetData.confirmed, title: "مقبولة", value: "123",size: MediaQuery.of(context).size.width*.07,),
                        SizedBox(width: AppConstants.width10(context),),
                        StatisticsHomeItem(icon: AssetData.cancelled, title: "ملغية", value: "12",size: MediaQuery.of(context).size.width*.07,),
                        SizedBox(width: AppConstants.width10(context),),
                        StatisticsHomeItem(icon: AssetData.coupons, title: "الكوبونات", value: "25",size: MediaQuery.of(context).size.width*.07,),
                      ],
                    ),
                    SizedBox(height: AppConstants.height20(context),),
                    Text("احصائيات الطلبات",style: Styles.inter16500black(context),),
                    SizedBox(height: AppConstants.height10(context),),
                    UserOrdersChart(),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppConstants.height20(context),),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: DefaultButton(onPress: (){}, text: "ايقاف الحساب مؤقتا",height: AppConstants.height15(context),borderRadius: AppConstants.sp10(context),),
          ),
          SizedBox(height: AppConstants.height20(context)),
        ],
      ),
    );
  }
}
