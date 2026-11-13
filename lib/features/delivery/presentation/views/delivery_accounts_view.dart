import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
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
                _buildHeader(context),
                const SizedBox(height: DsSpace.sm),
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
    return DsTopBar(title: "delivery_couriers".tr(), subtitle: "s_follow_orders_released_by_couriers".tr());
  }
}

/// "المتاحون الآن / إجمالي المندوبين" above the list.
class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GetDeliveryAccountsCubit>();
    final total = cubit.accountsModel?.data?.metadata?.totalItems ?? cubit.accountsList.length;
    final available = cubit.accountsList.where((a) => a.isAvailableForDelivery == true).length;

    // Same white metric strip as every other summary in the app.
    return DsMetricStrip(
      items: [
        DsMetric(label: "s_total_couriers".tr(), value: DsFormat.count(total)),
        DsMetric(label: "s_available_now".tr(), value: DsFormat.count(available), color: DsColor.success),
      ],
    );
  }
}
