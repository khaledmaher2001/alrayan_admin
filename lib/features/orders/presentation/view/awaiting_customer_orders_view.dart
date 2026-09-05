import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/awaiting_customer_orders_view_body.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_awaiting_customer_orders/get_awaiting_customer_orders_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// شاشة "طلبات بانتظار العميل" — الطلبات التي حرّرها عامل التوصيل لتعذّر
/// الوصول للعميل، وتحتاج تدخّل الإدارة. `GET /orders?status=awaiting_customer`.
class AwaitingCustomerOrdersView extends StatelessWidget {
  const AwaitingCustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetAwaitingCustomerOrdersCubit(getIt<OrdersRepoImpl>())
            ..getOrders(withLoading: true),
      child: Scaffold(
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
              const Expanded(child: AwaitingCustomerOrdersViewBody()),
            ],
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
                    "طلبات بانتظار العميل",
                    textAlign: TextAlign.center,
                    style: Styles.inter18500Black(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              "طلبات حرّرها عامل التوصيل لتعذّر الوصول للعميل",
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
      ],
    );
  }
}
