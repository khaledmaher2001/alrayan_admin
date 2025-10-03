import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_states.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/pie_chart_item.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/review_summery_item.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/statistics_home_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                      StatisticsHomeItem(
                        icon: AssetData.totalCustomers,
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
                  Container(
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
                        Text(
                          "متابعة حالة الطلبات",
                          style: Styles.inter16500black(context),
                        ),
                        Text(
                          "رسم توضيحي يوضح نسب الطلبات حتي الان",
                          style: Styles.inter10400grey(context),
                        ),
                        SizedBox(height: AppConstants.height20(context)),
                        PieChartItem(instance: state.model.orderStats!,),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  Container(
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
                        Text(
                          "تقييمات العملاء ( 232 ) تقييم",
                          style: Styles.inter16500black(context),
                        ),
                        SizedBox(height: AppConstants.height10(context)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: 4.5,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  ignoreGestures: true,
                                  glowColor: const Color(0xffF5BE00),
                                  itemPadding: EdgeInsetsDirectional.only(
                                    end: AppConstants.width10(context),
                                  ),
                                  unratedColor: Colors.grey[300],
                                  itemBuilder: (context, _) => SvgPicture.asset(
                                    AssetData.star5,
                                    color: Color(0xffF5BE00),
                                  ),
                                  itemSize:
                                      MediaQuery.of(context).size.width * 0.06,
                                  onRatingUpdate: (rating) {},
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "4.5",
                                      style: Styles.inter24600black(context),
                                    ),
                                    SizedBox(
                                      width: AppConstants.width5(context),
                                    ),
                                    Text(
                                      "من 5 نجوم",
                                      style: Styles.inter16500black(
                                        context,
                                      ).copyWith(color: AppColors.gray),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: AppConstants.height10(context),
                                ),
                              ],
                            ),
                            SizedBox(height: AppConstants.height20(context)),
                            ReviewSummeryItem(
                              title: "ممتاز",
                              percentage: 60,
                              main: Color(0xFF4CAF50),
                              back: Color(0xFFE8F5E9),
                            ),
                            SizedBox(height: AppConstants.height10(context)),
                            ReviewSummeryItem(
                              title: "جيد جدا",
                              percentage: 25,
                              main: Color(0xFF26A69A),
                              back: Color(0xFFE0F2F1),
                            ),
                            SizedBox(height: AppConstants.height10(context)),
                            ReviewSummeryItem(
                              title: "متوسط",
                              percentage: 5,
                              main: Color(0xFFFFC107),
                              back: Color(0xFFFFF8E1),
                            ),
                            SizedBox(height: AppConstants.height10(context)),
                            ReviewSummeryItem(
                              title: "جيد",
                              percentage: 5,
                              main: Color(0xFFFF9800),
                              back: Color(0xFFFFF3E0),
                            ),
                            SizedBox(height: AppConstants.height10(context)),
                            ReviewSummeryItem(
                              title: "مقبول",
                              percentage: 5,
                              main: Color(0xFFF44336),
                              back: Color(0xFFFFEBEE),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  Container(
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
                        Text(
                          "المنتجات الاكثر طلبا",
                          style: Styles.inter16500black(context),
                        ),
                        Text(
                          "حاول توفير اكبر كمية من المنتجات التي عليها طلب كبير",
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
                                child: DefaultCachedNetworkImage(
                                  imageUrl:
                                      "https://pics.clipartpng.com/midle/Cheese_PNG_Clipart-3141.png",
                                  imageHeight:
                                      MediaQuery.of(context).size.width * .12,
                                  imageWidth:
                                      MediaQuery.of(context).size.width * .12,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(width: AppConstants.width10(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "جبنة براميلي",
                                    style: Styles.inter14500black(context),
                                  ),
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  Text(
                                    "منتجات الالبان",
                                    style: Styles.inter10400grey(context),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "المخزن",
                                  style: Styles.inter14500black(context),
                                ),
                                Text(
                                  "125 قطعة في المخزن",
                                  style: Styles.inter10400grey(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  Container(
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
                        Text(
                          "العملاء الاكثر تفاعلا",
                          style: Styles.inter16500black(context),
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
                                child: DefaultCachedNetworkImage(
                                  imageUrl:
                                      "https://t4.ftcdn.net/jpg/02/97/24/51/360_F_297245133_gBPfK0h10UM3y7vfoEiBC3ZXt559KZar.jpg",
                                  imageHeight:
                                      MediaQuery.of(context).size.width * .12,
                                  imageWidth:
                                      MediaQuery.of(context).size.width * .12,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: AppConstants.width10(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "أحمد فايز عبدالفتاح",
                                    style: Styles.inter14500black(context),
                                  ),
                                  SizedBox(
                                    height: AppConstants.height5(context),
                                  ),
                                  Text(
                                    "ahmed.drengg@gmail.com",
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
                                  "125 طلب",
                                  style: Styles.inter10400grey(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
