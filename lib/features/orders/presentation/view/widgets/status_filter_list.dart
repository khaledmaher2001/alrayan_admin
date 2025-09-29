import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatusFilterList extends StatefulWidget {
  const StatusFilterList({super.key});

  @override
  State<StatusFilterList> createState() => _StatusFilterListState();
}

class _StatusFilterListState extends State<StatusFilterList> {
  late OrderStatusFilterCubit cubit;

  @override
  void initState() {
    cubit = context.read<OrderStatusFilterCubit>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.051,
      child: BlocBuilder<OrderStatusFilterCubit, OrderStatusFilterStates>(
        builder: (context, state) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 1),
            itemBuilder: (context, index) => Row(
              children: [
                if (index == 0) SizedBox(width: AppConstants.width15(context)),
                GestureDetector(
                  onTap: () {
                    if(cubit.selectedFilterIndex!=index){
                      cubit.selectIndex(index: index);
                      context.read<GetOrdersCubit>().getOrders(status: cubit.status[index]);
                    }

                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width15(context),
                      vertical: AppConstants.height5(context) / 2,
                    ),
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                      color: cubit.selectedFilterIndex == index ? AppColors.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: cubit.selectedFilterIndex == index ? AppColors.primaryColor : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                    ),
                    child: Text(
                      index == 0 ? "الكل" : AppConstants.getStatusText(cubit.status[index]),
                      style: Styles.inter14500black(
                        context,
                      ).copyWith(color: cubit.selectedFilterIndex == index ? Colors.white : Colors.grey.shade700),
                    ),
                  ),
                ),
                if (index == cubit.status.length - 1) SizedBox(width: AppConstants.width15(context)),
              ],
            ),
            separatorBuilder: (context, index) => SizedBox(width: AppConstants.width10(context)),
            itemCount: cubit.status.length,
          );
        },
      ),
    );
  }
}
