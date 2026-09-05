import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
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
                SizedBox(height: AppConstants.height10(context)),
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: AppConstants.width15(context),
                  ),
                  child: _buildHeader(context),
                ),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "delivery_release_logs".tr(),
                    textAlign: TextAlign.center,
                    style: Styles.inter18500Black(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              "متابعة الطلبات المحررة من الدليفري",
              style: Styles.inter14500black(
                context,
              ).copyWith(color: const Color(0xff9CA4AB)),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gray.withValues(alpha: .15),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            ),
          ),
        ),
        PositionedDirectional(
          end: 0,
          child: Builder(
            builder: (context) {
              final hasFilters = context
                  .watch<GetReleaseLogsCubit>()
                  .hasActiveFilters;
              return InkWell(
                onTap: () => showReleaseLogsFilterSheet(
                  context: context,
                  logsCubit: context.read<GetReleaseLogsCubit>(),
                ),
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: AppConstants.width20(context) * 2.2,
                  height: AppConstants.width20(context) * 2.2,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.shade50,
                  ),
                  child: Icon(
                    hasFilters
                        ? Icons.filter_alt_rounded
                        : Icons.filter_alt_outlined,
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
