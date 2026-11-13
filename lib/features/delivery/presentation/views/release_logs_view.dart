import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_release_logs/get_release_logs_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/release_logs_filter_sheet.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/release_logs_view_body.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة سجلات تحرير الطلبات — `GET /delivery/release-logs`.
class ReleaseLogsView extends StatelessWidget {
  const ReleaseLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetReleaseLogsCubit(getIt<DeliveryRepoImpl>())
            ..getReleaseLogs(withLoading: true),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xffF7F7F8),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: AppConstants.height15(context)),
                const Expanded(child: ReleaseLogsViewBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DsTopBar(
      title: "delivery_release_logs".tr(),
      subtitle: "s_follow_orders_released_by_couriers".tr(),
      actions: [
        Builder(
          builder: (context) => DsIconButton(
            icon: Icons.tune_rounded,
            label: "filters".tr(),
            badge: context.watch<GetReleaseLogsCubit>().hasActiveFilters,
            onPressed: () => showReleaseLogsFilterSheet(context: context, logsCubit: context.read<GetReleaseLogsCubit>()),
          ),
        ),
      ],
    );
  }
}
