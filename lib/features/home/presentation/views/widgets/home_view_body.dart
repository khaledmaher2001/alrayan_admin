import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/all_users/presentation/views/all_users_view.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_states.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/most_ordered_item.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/orders_status_item.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/reviews_summary_statistics.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/statistics_home_item.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/top_customer_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetHomeStatisticsCubit, GetHomeStatisticsStates>(
      builder: (context, state) {
        if (state is GetHomeStatisticsSuccessState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: Column(
                children: [
                  SizedBox(height: AppConstants.height20(context)),
                  Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width*.15,
                          height: MediaQuery.of(context).size.width*.15,
                          decoration: BoxDecoration(
                        color: Color(0xff1e1d2f),
                        shape: BoxShape.circle
                      ),child: Padding(
                        padding: EdgeInsets.all(AppConstants.sp10(context)),
                        child: Image.asset(AssetData.logoBackSecondry,fit: BoxFit.contain,),
                      )),
                      SizedBox(width: AppConstants.width10(context),),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("أهلا بك",style: Styles.inter18500Black(context)),
                          Text("أستاذ محمد الريان",style: Styles.inter16500black(context).copyWith(
                            color: AppColors.gray
                          )),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: AppConstants.height20(context)),
                  Row(
                    children: [
                      StatisticsHomeItem(
                        icon: AssetData.totalCustomers,
                        onTap: (){
                          NavigationUtils.navigateTo(context: context, destinationScreen: AllUsersView());
                        },
                        title: "عدد العملاء",
                        value: state.model.overview!.totalCustomers.toString(),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      StatisticsHomeItem(
                        icon: AssetData.totalOrders,
                        title: "عدد الطلبات",
                        value: state.model.overview!.totalOrders.toString(),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      StatisticsHomeItem(
                        icon: AssetData.totalMoney,
                        title: "المبيعات",
                        value: state.model.overview!.totalRevenue.toString(),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.height20(context)),
                  OrdersStatusItem(instance: state.model.orderStats!),
                  SizedBox(height: AppConstants.height10(context)),
                  ReviewsSummaryStatistic(instance: state.model.reviewStats!),
                  SizedBox(height: AppConstants.height10(context)),
                  MostOrderedItem(
                    instance:
                        state.model.productStats!.topSellingProducts!.first,
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  TopCustomerItem(instance: state.model.topCustomers!.first),
                  SizedBox(height: AppConstants.height20(context)),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: SizedBox(
              height: AppConstants.height30(context),
              width: AppConstants.height30(context),
              child: const CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
