import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'dart:async';

import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_home_statistics/get_home_statistics_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_item.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/order_status_filter_sheet.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/orders_stats_row.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/status_filter_list.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_states.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/order_status_filter/order_status_filter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrdersViewBody extends StatefulWidget {
  const OrdersViewBody({super.key});

  @override
  State<OrdersViewBody> createState() => _OrdersViewBodyState();
}

class _OrdersViewBodyState extends State<OrdersViewBody> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String searchQuery = "";
  Timer? _searchDebounce;
  late final GetOrdersCubit _ordersCubit = context.read<GetOrdersCubit>();

  void _onSearchChanged(String value) {
    setState(() => searchQuery = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _ordersCubit.searchOrders(value);
    });
  }

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<GetOrdersCubit>().loadMore();
    }
  }

  @override
  void initState() {
    scrollController.addListener(_onScroll);
    // The status-filter card counts come from the home dashboard stats,
    // which are otherwise only fetched once at app startup — refresh them
    // here too so a newly-created order shows up in the counts as soon as
    // this tab is opened, not just after a full app relaunch.
    context.read<GetHomeStatisticsCubit>().getHomeStatistics();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    _searchDebounce?.cancel();
    // The cubit outlives this tab: don't leave a stale server search behind.
    if (_ordersCubit.searchTerm.isNotEmpty) _ordersCubit.searchOrders("");
    super.dispose();
  }

  void _closeSearch() {
    _searchDebounce?.cancel();
    _ordersCubit.searchOrders("");
    setState(() {
      isSearching = false;
      searchQuery = "";
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height10(context)),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
            child: isSearching ? _buildSearchBar(context) : _buildHeader(context),
          ),
          const SizedBox(height: DsSpace.md),
          const StatusFilterList(),
          const SizedBox(height: DsSpace.sm),

          Expanded(
            child: BlocBuilder<GetOrdersCubit, GetOrdersStates>(
              builder: (context, state) {
                if (state is GetOrdersSuccessState) {
                  final getOrdersCubit = context.read<GetOrdersCubit>();
                  final filterCubit = context.read<OrderStatusFilterCubit>();

                  final selectedStatus =
                  filterCubit.status[filterCubit.selectedFilterIndex];

                  final query = searchQuery.trim().toLowerCase();
                  final List<Items> displayOrders;
                  if (query.isEmpty) {
                    displayOrders = List.of(getOrdersCubit.ordersList);
                  } else {
                    // Server matches by order number (any page) first, then
                    // name/phone matches among the orders already loaded.
                    final serverMatches = getOrdersCubit.searchTerm.toLowerCase() == query
                        ? getOrdersCubit.searchResults
                        : const <Items>[];
                    final seen = serverMatches.map((o) => o.id).toSet();
                    displayOrders = [
                      ...serverMatches,
                      ...getOrdersCubit.ordersList.where((o) =>
                          !seen.contains(o.id) &&
                          ((o.orderNumber ?? '').toLowerCase().contains(query) ||
                              (o.shippingAddress?.user?.fullName ?? '').toLowerCase().contains(query) ||
                              (o.shippingAddress?.phone1 ?? '').contains(query) ||
                              (o.shippingAddress?.user?.phoneNumber ?? '').contains(query))),
                    ];
                  }

                  final today = DateTime.now();
                  final todayCount = getOrdersCubit.ordersList.where((o) {
                    if (o.createdAt == null) return false;
                    final created = DateTime.tryParse(o.createdAt!)?.toLocal();
                    return created != null &&
                        created.year == today.year &&
                        created.month == today.month &&
                        created.day == today.day;
                  }).length;

                  final totalDisplayed =
                      getOrdersCubit.ordersModel?.data?.metadata?.totalItems ??
                          getOrdersCubit.ordersList.length;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: DsSpace.sm),
                        child: OrdersStatsRow(totalDisplayed: totalDisplayed, todayCount: todayCount),
                      ),
                      Expanded(
                        child: displayOrders.isNotEmpty
                            ? RefreshIndicator(
                          onRefresh: () async {
                            await Future.wait([
                              getOrdersCubit.getOrders(status: selectedStatus),
                              context.read<GetHomeStatisticsCubit>().getHomeStatistics(),
                            ]);
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
                            separatorBuilder: (context, index) => const SizedBox(height: DsSpace.sm),
                            itemCount: displayOrders.length,
                          ),
                        )
                            : Center(
                          child: query.isEmpty
                              ? SvgPicture.asset(AssetData.emptyCategory)
                              : getOrdersCubit.isSearchLoading || _searchDebounce?.isActive == true
                              ? const CustomLoadingItem()
                              : Text(
                            "s_no_matching_orders".tr(),
                            style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
                          ),
                        ),
                      ),
                      if (getOrdersCubit.isLoadingMore)
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
                    "s_orders_2".tr(),
                    textAlign: TextAlign.center,
                    style: Styles.inter18500Black(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              "s_follow_and_manage_store_orders".tr(),
              textAlign: TextAlign.center,
              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
            ),
          ],
        ),
        PositionedDirectional(
          start: 0,
          child: Row(
            children: [
              _HeaderIconButton(
                asset: AssetData.search,
                label: "ord_search_open".tr(),
                onTap: () => setState(() => isSearching = true),
              ),
            ],
          ),
        ),
        PositionedDirectional(
          end: 0,
          child: Row(
            children: [
              _HeaderIconButton(
                asset: AssetData.filter,
                label: "ord_filter_open".tr(),
                onTap: () => showOrderStatusFilterSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(icon: Icons.arrow_forward_rounded, label: "a11y_back".tr(), onTap: _closeSearch),
        SizedBox(width: AppConstants.width10(context)),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
              border: Border.all(color: const Color(0xffE3E7EC)),
            ),
            child: TextField(
              controller: searchController,
              autofocus: true,
              textAlign: TextAlign.right,
              style: Styles.inter14500black(context),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "ord_search".tr(),
                hintStyle: Styles.hintText(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({this.asset, this.icon, required this.label, required this.onTap});

  final String label;

  final String? asset;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: DsSize.touch,
        height: DsSize.touch,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: const Color(0xffE3E7EC)),
        ),
        child: asset != null
            ? SvgPicture.asset(asset!, width: AppConstants.width20(context),color: Colors.black87,)
            : Icon(icon, size: AppConstants.width20(context), color: Colors.black87),
      ),
      ),
    );
  }
}
