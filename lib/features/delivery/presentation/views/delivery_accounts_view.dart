import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/delete_delivery_account/delete_delivery_account_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_cubit.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_account_form_sheet.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_accounts_view_body.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة مندوبي التوصيل — `GET /delivery/accounts`.
class DeliveryAccountsView extends StatelessWidget {
  const DeliveryAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetDeliveryAccountsCubit(getIt<DeliveryRepoImpl>())
                ..getDeliveryAccounts(withLoading: true),
        ),
        BlocProvider(
          create: (_) => DeleteDeliveryAccountCubit(getIt<DeliveryRepoImpl>()),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xffF7F7F8),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            shape: const CircleBorder(),
            onPressed: () {
              final listCubit = context.read<GetDeliveryAccountsCubit>();
              showDeliveryAccountFormSheet(
                context: context,
                onSuccess: () =>
                    listCubit.getDeliveryAccounts(withLoading: true),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: AppConstants.height10(context)),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
                  child: _buildHeader(context),
                ),
                SizedBox(height: AppConstants.height15(context)),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
                  child: const _StatsBar(),
                ),
                SizedBox(height: AppConstants.height15(context)),
                const Expanded(child: DeliveryAccountsViewBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("delivery_couriers".tr(),textAlign: TextAlign.center, style: Styles.inter18500Black(context))),

              ],
            ),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              "متابعة الطلبات المحررة من الدليفري",
              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
            ),
          ],
        ),
        PositionedDirectional(
          start: 0,
          child: InkWell(
            onTap: () => NavigationUtils.navigateBack(context: context),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: AppConstants.width20(context) * 2.2,
              height: AppConstants.width20(context) * 2.2,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.gray.withValues(alpha: .15)),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}

/// "المتاحون الآن / إجمالي المندوبين" الشريط الداكن أعلى القائمة.
class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GetDeliveryAccountsCubit>();
    final total = cubit.accountsModel?.data?.metadata?.totalItems ?? cubit.accountsList.length;
    final available = cubit.accountsList.where((a) => a.isAvailableForDelivery == true).length;

    return ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
          child: Container(
            width: double.infinity,
            color: AppColors.secondaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
              vertical: AppConstants.height15(context),
            ),
            child: Row(
              children: [
                Icon(Icons.groups_rounded, color: Colors.white, size: 28),
                SizedBox(width: AppConstants.width15(context)),
                Expanded(
                  child: Column(
                    children: [
                      Text("إجمالي المندوبين", style: Styles.inter12500Black(context).copyWith(color: Colors.white70)),
                      SizedBox(height: AppConstants.height5(context)),
                      Text("$total", style: Styles.inter18500Black(context).copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.white.withValues(alpha: .2)),
                Expanded(
                  child: Column(
                    children: [
                      Text("المتاحون الآن", style: Styles.inter12500Black(context).copyWith(color: Colors.white70)),
                      SizedBox(height: AppConstants.height5(context)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          ),
                          SizedBox(width: AppConstants.width5(context)),
                          Text("$available", style: Styles.inter18500Black(context).copyWith(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
