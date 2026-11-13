import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/details_loader_scaffold.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/find_delivery_account/find_delivery_account_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/find_delivery_account/find_delivery_account_state.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_account_details_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_management_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens a courier's details when only the courier's user id is known (push
/// notification). Falls back to the couriers list if the courier is gone.
class CourierDetailsLoaderView extends StatelessWidget {
  const CourierDetailsLoaderView({super.key, required this.courierId});

  final int courierId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FindDeliveryAccountCubit(getIt<DeliveryRepoImpl>())..find(courierId),
      child: BlocBuilder<FindDeliveryAccountCubit, FindDeliveryAccountState>(
        builder: (context, state) {
          if (state is FindDeliveryAccountSuccess) {
            final account = state.account;
            return account == null
                ? const DeliveryManagementView()
                : DeliveryAccountDetailsView(account: account);
          }
          return DetailsLoaderScaffold(
            title: "courier_details".tr(),
            body: state is FindDeliveryAccountError
                ? LoadErrorView(
                    message: state.message,
                    onRetry: () => context.read<FindDeliveryAccountCubit>().find(courierId),
                  )
                : const CustomLoadingItem(),
          );
        },
      ),
    );
  }
}
