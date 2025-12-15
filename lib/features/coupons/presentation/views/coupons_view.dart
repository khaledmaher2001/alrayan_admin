import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/delete_coupon/delete_coupon_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/get_coupons/get_coupons_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/coupon_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/shared_widgets/custom_button.dart';
import '../../../../core/shared_widgets/empty_widget.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/utils/assets/assets.dart';
import '../../../../core/utils/colors/colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/navigation_utility.dart';
import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../../../core/utils/text_styles/styles.dart';
import '../../data/repo/coupons_repo_impl.dart';
import 'create_coupon_view.dart';

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  pagination() async {
    if (context.read<GetCouponsCubit>().page < context.read<GetCouponsCubit>().couponsModel!.data!.metadata!.totalPages! &&
        scrollController.position.maxScrollExtent == scrollController.position.pixels &&
        !isLoading) {
      setState(() {
        isLoading = true;
        context.read<GetCouponsCubit>().page++;
      });
      await context.read<GetCouponsCubit>().getCoupons(withLoading: false);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    scrollController.addListener(pagination);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>DeleteCouponCubit(getIt<CouponsRepoImpl>()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: AppConstants.height15(context)),
              CustomAppBar(title: "كوبونات الخصم".tr(),textColor: Colors.black,hasBack: true,),
              SizedBox(height: AppConstants.height20(context)),
              Expanded(
                child: BlocBuilder<GetCouponsCubit, GetCouponsState>(builder: (context, state) {
                  if (state is GetCouponsSuccessState) {
                    return Column(
                      children: [
                        Expanded(
                          child:  BlocListener<DeleteCouponCubit,DeleteCouponState>(
                            listener: (context,deleteState){
                              if(deleteState is DeleteCouponSuccessState){
                                toast(text: deleteState.message, color: Colors.green);
                                setState(() {
                                  context.read<GetCouponsCubit>().couponsList.removeAt( context.read<DeleteCouponCubit>().selectedIndex);
                                });
                              }else if(deleteState is DeleteCouponErrorState){
                                toast(text: deleteState.error, color: AppColors.redColor);
                              }
                            },
                            child: context.read<GetCouponsCubit>().couponsList.isNotEmpty?ListView.separated(
                                controller: scrollController,
                                itemBuilder: (context, index) => CouponItem(
                                    couponData: context.read<GetCouponsCubit>().couponsList[index], index: index),
                                separatorBuilder: (context, index) => SizedBox(height: AppConstants.height20(context),),
                                itemCount: context.read<GetCouponsCubit>().couponsList.length):Padding(
                                  padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                                  child: EmptyWidget(icon: AssetData.coupons,iconColor: Colors.grey,title: "لا توجد كوبونات الان",description: "برجاء إنشاء كوبونات جديدة للمستخدمين لتحفيزهم على زيادة عمليات الشراء والاستفادة من العروض.",),
                                ),
                          ),
                        ),
                        if(isLoading)
                          Center(child: SizedBox(
                              width:AppConstants.width20(context),
                              height:AppConstants.width20(context),
                              child: const CircularProgressIndicator())),

                      ],
                    );
                  } else if (state is GetCouponsErrorState) {
                    return Center(
                        child: Text(
                      state.error,
                      style: Styles.inter14500black(context),
                    ));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
              ),
              SizedBox(height: AppConstants.height15(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                child: DefaultButton(
                  onPress: (){
                    NavigationUtils.navigateTo(context: context, destinationScreen: const CreateCouponView());
                  },
                  text: "انشاء كوبون".tr(),
                  borderRadius: AppConstants.sp10(context),
                ),
              ),
              SizedBox(height: AppConstants.height10(context)),
            ],
          ),
        ),
      ),
    );
  }
}