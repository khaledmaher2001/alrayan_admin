import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_item.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/status_filter_list.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_states.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrdersViewBody extends StatefulWidget {
  const OrdersViewBody({super.key});

  @override
  State<OrdersViewBody> createState() => _OrdersViewBodyState();
}

class _OrdersViewBodyState extends State<OrdersViewBody> {
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;

  Future<void> pagination() async {
    final cubit = context.read<GetOrdersCubit>();
    final filterCubit = context.read<OrderStatusFilterCubit>();

    if (cubit.ordersModel == null) return;

    if (cubit.page < cubit.ordersModel!.data!.metadata!.totalPages! &&
        scrollController.position.maxScrollExtent ==
            scrollController.position.pixels &&
        !isLoading) {
      isLoading = true;

      setState(() {
        cubit.page++;
      });

      await cubit
          .getOrders(
        withLoading: false,
        status: filterCubit.status[filterCubit.selectedFilterIndex],
      )
          .then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  void initState() {
    scrollController.addListener(pagination);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(pagination);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height10(context)),
          Text(
            "الطلبات",
            textAlign: TextAlign.center,
            style: Styles.inter18500Black(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          const StatusFilterList(),
          SizedBox(height: AppConstants.height20(context)),

          Expanded(
            child: BlocBuilder<GetOrdersCubit, GetOrdersStates>(
              builder: (context, state) {
                if (state is GetOrdersSuccessState) {
                  final getOrdersCubit = context.read<GetOrdersCubit>();
                  final filterCubit = context.read<OrderStatusFilterCubit>();

                  final selectedStatus =
                  filterCubit.status[filterCubit.selectedFilterIndex];

                  final displayOrders = List.of(getOrdersCubit.ordersList);

                  if (selectedStatus != "" && selectedStatus != "pending") {
                    displayOrders.sort(
                          (a, b) => DateTime.parse(
                        b.createdAt ?? "",
                      ).compareTo(
                        DateTime.parse(a.createdAt ?? ""),
                      ),
                    );
                  }

                  return displayOrders.isNotEmpty
                      ? Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await getOrdersCubit.getOrders(
                              status: selectedStatus,
                            );
                          },
                          child: ListView.separated(
                            controller: scrollController,
                            physics:
                            const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  OrdersItem(
                                    orderData: displayOrders[index],
                                  ),
                                  if (index == displayOrders.length - 1)
                                    SizedBox(
                                      height: AppConstants.height20(
                                        context,
                                      ),
                                    ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) =>
                                SizedBox(
                                  height: AppConstants.height15(context),
                                ),
                            itemCount: displayOrders.length,
                          ),
                        ),
                      ),

                      if (isLoading)
                        Padding(
                          padding: EdgeInsets.all(
                            AppConstants.sp10(context),
                          ),
                          child: CustomLoadingItem(
                            size:
                            MediaQuery.of(context).size.width * 0.08,
                          ),
                        ),
                    ],
                  )
                      : Center(
                    child: SvgPicture.asset(AssetData.emptyCategory),
                  );
                }

                return const CustomLoadingItem();
              },
            ),
          ),
        ],
      ),
    );
  }
}