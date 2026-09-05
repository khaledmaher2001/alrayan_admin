import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_remittances/get_remittances_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/remittances_filter_sheet.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/remittances_view_body.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة طلبات تسليم الفلوس من المندوبين — `GET /delivery/wallet/remittances`.
class RemittancesView extends StatelessWidget {
  const RemittancesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetRemittancesCubit(getIt<DeliveryRepoImpl>())
            ..getRemittances(withLoading: true),
      child: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: AppConstants.height10(context)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width15(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomBackButton(),
                      Text(
                        "delivery_remittances".tr(),
                        textAlign: TextAlign.center,
                        style: Styles.inter18500Black(context),
                      ),
                      IconButton(
                        onPressed: () => showRemittancesFilterSheet(
                          context: context,
                          remittancesCubit: context
                              .read<GetRemittancesCubit>(),
                        ),
                        icon: Icon(
                          Icons.filter_alt,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppConstants.height10(context)),
                const Expanded(child: RemittancesViewBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
