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
import 'package:shimmer/shimmer.dart';

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
                        width: MediaQuery.of(context).size.width * .15,
                        height: MediaQuery.of(context).size.width * .15,
                        decoration: const BoxDecoration(
                          color: Color(0xff1e1d2f),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.sp10(context)),
                          child: Image.asset(
                            AssetData.logoBackSecondry,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: AppConstants.width10(context)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "أهلا بك",
                            style: Styles.inter18500Black(context),
                          ),
                          Text(
                            "أستاذ محمد الريان",
                            style: Styles.inter16500black(context).copyWith(
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.height20(context)),
                  Row(
                    children: [
                      StatisticsHomeItem(
                        icon: AssetData.totalCustomers,
                        onTap: () {
                          NavigationUtils.navigateTo(
                            context: context,
                            destinationScreen: AllUsersView(),
                          );
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
                  if(state.model.productStats!.topSellingProducts!.isNotEmpty)...[
                    MostOrderedItem(
                      instance: state.model.productStats!.topSellingProducts!.first,
                      fromHome: true,
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                  ],
                  if(state.model.topCustomers!.isNotEmpty)...[ TopCustomerItem(
                    instance: state.model.topCustomers!.first,
                    fromHome: true,
                    index: 0,
                  ),
                  SizedBox(height: AppConstants.height20(context)),]
                ],
              ),
            ),
          );
        } else {
          return const HomeViewBodyShimmer();
        }
      },
    );
  }
}

class HomeViewBodyShimmer extends StatelessWidget {
  const HomeViewBodyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width20(context),
          ),
          child: Column(
            children: [
              SizedBox(height: AppConstants.height20(context)),
              Row(
                children: [
                  _shimmerCircle(
                    size: MediaQuery.of(context).size.width * .15,
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(
                        context,
                        width: MediaQuery.of(context).size.width * .22,
                        height: AppConstants.height15(context),
                      ),
                      SizedBox(height: AppConstants.height10(context) / 2),
                      _shimmerBox(
                        context,
                        width: MediaQuery.of(context).size.width * .32,
                        height: AppConstants.height10(context),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppConstants.height20(context)),
              Row(
                children: [
                  const Expanded(child: StatisticsHomeItemShimmer()),
                  SizedBox(width: AppConstants.width10(context)),
                  const Expanded(child: StatisticsHomeItemShimmer()),
                  SizedBox(width: AppConstants.width10(context)),
                  const Expanded(child: StatisticsHomeItemShimmer()),
                ],
              ),
              SizedBox(height: AppConstants.height20(context)),
              const OrdersStatusItemShimmer(),
              SizedBox(height: AppConstants.height10(context)),
              const ReviewsSummaryStatisticShimmer(),
              SizedBox(height: AppConstants.height10(context)),
              const MostOrderedItemShimmer(),
              SizedBox(height: AppConstants.height10(context)),
              const TopCustomerItemShimmer(),
              SizedBox(height: AppConstants.height20(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsHomeItemShimmer extends StatelessWidget {
  const StatisticsHomeItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        children: [
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .08,
            height: MediaQuery.of(context).size.width * .08,
            radius: AppConstants.sp10(context),
          ),
          SizedBox(height: AppConstants.height10(context)),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .16,
            height: AppConstants.height10(context),
          ),
          SizedBox(height: AppConstants.height5(context)),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .10,
            height: AppConstants.height10(context),
          ),
        ],
      ),
    );
  }
}

class OrdersStatusItemShimmer extends StatelessWidget {
  const OrdersStatusItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .28,
            height: AppConstants.height15(context),
          ),
          SizedBox(height: AppConstants.height10(context) / 2),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .45,
            height: AppConstants.height10(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: List.generate(
                  5,
                      (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: AppConstants.height10(context),
                    ),
                    child: Row(
                      children: [
                        _shimmerBox(
                          context,
                          width: 16,
                          height: 16,
                          radius: 4,
                        ),
                        SizedBox(width: AppConstants.width5(context)),
                        _shimmerBox(
                          context,
                          width: MediaQuery.of(context).size.width * .18,
                          height: AppConstants.height10(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _shimmerCircle(size: MediaQuery.of(context).size.width / 2.3),
            ],
          ),
        ],
      ),
    );
  }
}

class ReviewsSummaryStatisticShimmer extends StatelessWidget {
  const ReviewsSummaryStatisticShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  context,
                  width: double.infinity,
                  height: AppConstants.height15(context),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .20,
                height: AppConstants.height30(context),
                radius: AppConstants.sp5(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .35,
            height: AppConstants.height20(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          ...List.generate(
            5,
                (index) => Padding(
              padding: EdgeInsets.only(bottom: AppConstants.height20(context)),
              child: Row(
                children: [
                  _shimmerBox(
                    context,
                    width: MediaQuery.of(context).size.width * .15,
                    height: AppConstants.height10(context),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: _shimmerBox(
                      context,
                      width: double.infinity,
                      height: AppConstants.height10(context),
                      radius: AppConstants.sp30(context),
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

class MostOrderedItemShimmer extends StatelessWidget {
  const MostOrderedItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  context,
                  width: double.infinity,
                  height: AppConstants.height15(context),
                ),
              ),
              SizedBox(width: AppConstants.width20(context)),
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .18,
                height: AppConstants.height30(context),
                radius: AppConstants.sp5(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context) / 2),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .50,
            height: AppConstants.height10(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            children: [
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .14,
                height: MediaQuery.of(context).size.width * .14,
                radius: AppConstants.sp10(context),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .25,
                      height: AppConstants.height10(context),
                    ),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .18,
                      height: AppConstants.height10(context),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _shimmerBox(
                    context,
                    width: MediaQuery.of(context).size.width * .12,
                    height: AppConstants.height10(context),
                  ),
                  SizedBox(height: AppConstants.height10(context) / 2),
                  _shimmerBox(
                    context,
                    width: MediaQuery.of(context).size.width * .16,
                    height: AppConstants.height10(context),
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

class TopCustomerItemShimmer extends StatelessWidget {
  const TopCustomerItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  context,
                  width: double.infinity,
                  height: AppConstants.height15(context),
                ),
              ),
              SizedBox(width: AppConstants.width20(context)),
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .18,
                height: AppConstants.height30(context),
                radius: AppConstants.sp5(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context) / 2),
          _shimmerBox(
            context,
            width: MediaQuery.of(context).size.width * .48,
            height: AppConstants.height10(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            children: [
              _shimmerBox(
                context,
                width: MediaQuery.of(context).size.width * .12,
                height: MediaQuery.of(context).size.width * .12,
                radius: AppConstants.sp10(context),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .26,
                      height: AppConstants.height10(context),
                    ),
                    SizedBox(height: AppConstants.height10(context) / 2),
                    _shimmerBox(
                      context,
                      width: MediaQuery.of(context).size.width * .30,
                      height: AppConstants.height10(context),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _shimmerBox(
                    context,
                    width: MediaQuery.of(context).size.width * .10,
                    height: AppConstants.height10(context),
                  ),
                  SizedBox(height: AppConstants.height10(context) / 2),
                  _shimmerBox(
                    context,
                    width: MediaQuery.of(context).size.width * .14,
                    height: AppConstants.height10(context),
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

Widget _shimmerBox(
    BuildContext context, {
      required double width,
      required double height,
      double? radius,
    }) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius ?? AppConstants.sp10(context)),
    ),
  );
}

Widget _shimmerCircle({required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );
}