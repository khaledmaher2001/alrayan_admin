import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/shimmer_helpers.dart';
import 'package:alrayan_admin/features/coupons/data/models/coupons_model.dart';
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

enum _CouponFilter { all, active, expired }

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  _CouponFilter filter = _CouponFilter.all;
  String query = '';

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
    super.initState();
    scrollController.addListener(pagination);
    searchController.addListener(() {
      setState(() => query = searchController.text.trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetCouponsCubit>().getCoupons();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  bool _isExpired(Items coupon) {
    final validTo = DateTime.tryParse(coupon.validTo ?? "");
    if (validTo == null) return false;
    return validTo.isBefore(DateTime.now());
  }

  List<Items> _applyFilters(List<Items> source) {
    return source.where((coupon) {
      if (filter == _CouponFilter.active && _isExpired(coupon)) return false;
      if (filter == _CouponFilter.expired && !_isExpired(coupon)) return false;
      if (query.isNotEmpty && !(coupon.code ?? '').toLowerCase().contains(query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
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
              CustomAppBar(title: "كوبونات الخصم".tr(),textColor: Colors.black,hasBack: true,withNotifications: false,),
              SizedBox(height: AppConstants.height15(context)),
              BlocBuilder<GetCouponsCubit, GetCouponsState>(
                buildWhen: (previous, current) => current is GetCouponsSuccessState,
                builder: (context, state) {
                  if (state is! GetCouponsSuccessState) return const SizedBox.shrink();
                  final total = state.model.data?.metadata?.totalItems ?? context.read<GetCouponsCubit>().couponsList.length;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.width15(context),
                            vertical: AppConstants.height5(context),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.shade50,
                            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                          ),
                          child: Text(
                            "$total كوبونات",
                            style: Styles.inter12500Black(context).copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: AppConstants.height15(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                child: _CouponFilterTabs(
                  selected: filter,
                  onChanged: (value) => setState(() => filter = value),
                ),
              ),
              SizedBox(height: AppConstants.height10(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                child: TextField(
                  controller: searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "ابحث بكود الكوبون",
                    hintStyle: Styles.inter14600gray(context),
                    prefixIcon: Icon(Icons.search, color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.gray.withOpacity(.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppConstants.height15(context)),
              Expanded(
                child: BlocBuilder<GetCouponsCubit, GetCouponsState>(builder: (context, state) {
                  if (state is GetCouponsSuccessState) {
                    final couponsList = context.read<GetCouponsCubit>().couponsList;
                    final filtered = _applyFilters(couponsList);
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
                            child: couponsList.isNotEmpty
                                ? (filtered.isEmpty
                                    ? Center(
                                        child: Text(
                                          "لا توجد كوبونات مطابقة",
                                          style: Styles.inter14600gray(context),
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: () => context.read<GetCouponsCubit>().getCoupons(),
                                        child: ListView.separated(
                                        controller: scrollController,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (context, index) => CouponItem(
                                            couponData: filtered[index], index: couponsList.indexOf(filtered[index])),
                                        separatorBuilder: (context, index) => SizedBox(height: AppConstants.height20(context),),
                                        itemCount: filtered.length),
                                    ))
                                :Padding(
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
                    return const _CouponsShimmer();
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

class _CouponsShimmer extends StatelessWidget {
  const _CouponsShimmer();

  @override
  Widget build(BuildContext context) {
    return appShimmer(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width20(context),
          vertical: AppConstants.height10(context),
        ),
        itemCount: 4,
        separatorBuilder: (context, index) => SizedBox(height: AppConstants.height20(context)),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(AppConstants.sp15(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    shimmerBox(context, width: 80, height: AppConstants.height20(context), radius: 30),
                    const Spacer(),
                    shimmerBox(context, width: 90, height: AppConstants.height20(context), radius: 30),
                  ],
                ),
                SizedBox(height: AppConstants.height15(context)),
                shimmerBox(context, width: MediaQuery.of(context).size.width * .5, height: AppConstants.height15(context)),
                SizedBox(height: AppConstants.height10(context)),
                Row(
                  children: [
                    Expanded(child: shimmerBox(context, width: double.infinity, height: AppConstants.height20(context) * 1.5)),
                    SizedBox(width: AppConstants.width20(context)),
                    Expanded(child: shimmerBox(context, width: double.infinity, height: AppConstants.height20(context) * 1.5)),
                  ],
                ),
                SizedBox(height: AppConstants.height15(context)),
                shimmerBox(context, width: double.infinity, height: 1, radius: 0),
                SizedBox(height: AppConstants.height10(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    shimmerBox(context, width: 80, height: AppConstants.height15(context)),
                    shimmerBox(context, width: 90, height: AppConstants.height15(context)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CouponFilterTabs extends StatelessWidget {
  const _CouponFilterTabs({required this.selected, required this.onChanged});

  final _CouponFilter selected;
  final ValueChanged<_CouponFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp5(context) / 2),
      decoration: BoxDecoration(
        color: AppColors.gray.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Row(
        children: [
          _buildTab(context, "الكل", _CouponFilter.all),
          _buildTab(context, "نشط", _CouponFilter.active),
          _buildTab(context, "منتهي", _CouponFilter.expired),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, _CouponFilter value) {
    final isSelected = selected == value;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context)),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Styles.inter14600gray(context).copyWith(
              color: isSelected ? Colors.white : AppColors.gray,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
