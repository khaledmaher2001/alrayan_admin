import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/search_widget.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_orders/get_delivery_orders_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_orders/get_delivery_orders_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_order_item.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeliveryOrdersViewBody extends StatefulWidget {
  const DeliveryOrdersViewBody({super.key});

  @override
  State<DeliveryOrdersViewBody> createState() => _DeliveryOrdersViewBodyState();
}

/// The four quick status filters shown as pills — each maps to the server
/// filters this endpoint actually supports (`unassigned`, `finished`); a
/// courier already scoped in via [GetDeliveryOrdersCubit.filters] (e.g.
/// reached from a courier's own order history) is preserved across taps.
class _StatusFilter {
  const _StatusFilter(this.labelKey, this.query);

  final String labelKey;
  final Map<String, dynamic> query;
}

const List<_StatusFilter> _statusFilters = [
  _StatusFilter('all', {}),
  _StatusFilter('order_filter_awaiting_courier', {'unassigned': 'true'}),
  _StatusFilter('order_filter_in_delivery', {
    'unassigned': 'false',
    'finished': 'false',
  }),
  _StatusFilter('order_filter_delivered', {'finished': 'true'}),
];

class _DeliveryOrdersViewBodyState extends State<DeliveryOrdersViewBody> {
  final ScrollController scrollController = ScrollController();
  final searchController = TextEditingController();
  int selectedStatusFilter = 0;

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<GetDeliveryOrdersCubit>().loadMore();
    }
  }

  void _applyStatusFilter(int index) {
    final cubit = context.read<GetDeliveryOrdersCubit>();
    final existingCourier = cubit.filters['deliveryUserId'];
    cubit.setFilters({
      if (existingCourier != null) 'deliveryUserId': existingCourier,
      ..._statusFilters[index].query,
    });
    cubit.getDeliveryOrders(withLoading: true);
    setState(() => selectedStatusFilter = index);
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width20(context),
          ),
          child: SearchWidget(
            hint: "search_delivery_order_hint".tr(),
            searchController: searchController,
            // The server only filters orders by `orderNumber` — searching by
            // customer name too only works over the currently loaded page(s),
            // so this stays a local filter rather than a server round-trip.
            onSearch: (value) => setState(
              () => context.read<GetDeliveryOrdersCubit>().clientSearchQuery =
                  value,
            ),
          ),
        ),
        SizedBox(height: AppConstants.height10(context)),
        SizedBox(
          height: AppConstants.height30(context) * 1.4,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            scrollDirection: Axis.horizontal,
            itemCount: _statusFilters.length,
            separatorBuilder: (_, _) =>
                SizedBox(width: AppConstants.width10(context)),
            itemBuilder: (context, index) {
              final selected = selectedStatusFilter == index;
              return GestureDetector(
                onTap: () => _applyStatusFilter(index),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width15(context),
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryColor : Colors.white,
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryColor
                          : DsColor.border,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppConstants.sp30(context),
                    ),
                  ),
                  child: Text(
                    _statusFilters[index].labelKey.tr(),
                    style: Styles.inter14500black(context).copyWith(
                      color: selected ? Colors.white : DsColor.text2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppConstants.height10(context)),
        Expanded(
          child: BlocBuilder<GetDeliveryOrdersCubit, GetDeliveryOrdersStates>(
            builder: (context, state) {
              if (state is GetDeliveryOrdersErrorState) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width20(context),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: DsColor.danger,
                          size: 48,
                        ),
                        SizedBox(height: AppConstants.height10(context)),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: Styles.inter14500black(context),
                        ),
                        SizedBox(height: AppConstants.height15(context)),
                        ElevatedButton(
                          onPressed: () => context
                              .read<GetDeliveryOrdersCubit>()
                              .getDeliveryOrders(withLoading: true),
                          child: Text("retry".tr()),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is GetDeliveryOrdersSuccessState) {
                final cubit = context.read<GetDeliveryOrdersCubit>();
                final list = cubit.visibleOrders;
                if (list.isEmpty) {
                  return Center(child: SvgPicture.asset(AssetData.emptyCategory));
                }
                return RefreshIndicator(
                  onRefresh: () => cubit.getDeliveryOrders(withLoading: true),
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: AppConstants.height15(context)),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          if (index == 0)
                            SizedBox(height: AppConstants.height5(context)),
                          DeliveryOrderItem(order: list[index]),
                          if (context
                                  .read<GetDeliveryOrdersCubit>()
                                  .isLoadingMore &&
                              index == list.length - 1)
                            Padding(
                              padding: EdgeInsets.all(
                                AppConstants.sp10(context),
                              ),
                              child: CustomLoadingItem(
                                size:
                                    MediaQuery.of(context).size.width * 0.08,
                              ),
                            ),
                          if (index == list.length - 1)
                            SizedBox(
                              height: AppConstants.height30(context),
                            ),
                        ],
                      );
                    },
                  ),
                );
              }

              return const CustomLoadingItem();
            },
          ),
        ),
      ],
    );
  }
}
