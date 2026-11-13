import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/features/coupons/data/models/coupons_model.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/delete_coupon/delete_coupon_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/view_model/get_coupons/get_coupons_cubit.dart';
import 'package:alrayan_admin/features/coupons/presentation/views/widgets/coupon_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/shared_widgets/empty_widget.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../../core/utils/assets/assets.dart';
import '../../../../core/utils/navigation_utility.dart';
import '../../../../core/utils/services/remote_services/service_locator.dart';
import '../../data/repo/coupons_repo_impl.dart';
import 'create_coupon_view.dart';

enum _CouponFilter { all, active, expired }

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  _CouponFilter filter = _CouponFilter.all;
  String query = '';

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<GetCouponsCubit>().loadMore();
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    searchController.addListener(() {
      setState(() => query = searchController.text.trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetCouponsCubit>().getCoupons();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  bool _isExpired(Items coupon) {
    final validTo = DateTime.tryParse(coupon.validTo ?? "");
    if (validTo == null) return false;
    return validTo.isBefore(DateTime.now());
  }

  List<Items> _applyFilters(List<Items> source) {
    return source.where((coupon) {
      if (filter == _CouponFilter.active && _isExpired(coupon)) return false;
      if (filter == _CouponFilter.expired && !_isExpired(coupon)) return false;
      if (query.isNotEmpty && !(coupon.code ?? '').toLowerCase().contains(query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeleteCouponCubit(getIt<CouponsRepoImpl>()),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "coupon_add",
          onPressed: () => NavigationUtils.navigateTo(context: context, destinationScreen: const CreateCouponView()),
          icon: const Icon(Icons.add_rounded),
          label: Text("s_create_coupon".tr()),
        ),
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<GetCouponsCubit, GetCouponsState>(
                builder: (context, state) {
                  final total = state is GetCouponsSuccessState
                      ? (state.model.data?.metadata?.totalItems ?? context.read<GetCouponsCubit>().couponsList.length)
                      : null;
                  return DsTopBar(
                    title: "s_discount_coupons".tr(),
                    subtitle: total == null ? null : "i_x_coupons_9".tr(namedArgs: {"a": DsFormat.count(total)}),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.sm, DsSpace.page, 0),
                child: DsSearchField(hint: "s_search_by_coupon_code".tr(), controller: searchController),
              ),
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: DsSpace.page, vertical: DsSpace.sm),
                  children: [
                    for (final f in _CouponFilter.values) ...[
                      DsChip(
                        label: switch (f) { _CouponFilter.all => "s_all".tr(), _CouponFilter.active => "s_active".tr(), _CouponFilter.expired => "s_ended".tr() },
                        selected: filter == f,
                        onTap: () => setState(() => filter = f),
                      ),
                      const SizedBox(width: DsSpace.sm),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<GetCouponsCubit, GetCouponsState>(builder: (context, state) {
                  if (state is GetCouponsSuccessState) {
                    final couponsList = context.read<GetCouponsCubit>().couponsList;
                    final filtered = _applyFilters(couponsList);
                    return BlocListener<DeleteCouponCubit, DeleteCouponState>(
                      listener: (context, deleteState) {
                        if (deleteState is DeleteCouponSuccessState) {
                          toast(text: deleteState.message, color: DsColor.success);
                          setState(() {
                            context.read<GetCouponsCubit>().couponsList.removeAt(context.read<DeleteCouponCubit>().selectedIndex);
                          });
                        } else if (deleteState is DeleteCouponErrorState) {
                          toast(text: deleteState.error, color: DsColor.danger);
                        }
                      },
                      child: couponsList.isEmpty
                          ? EmptyWidget(icon: AssetData.coupons, iconColor: DsColor.textSubtle, title: "s_no_coupons_yet".tr(), description: "s_create_new_coupons_to_encourage_cust".tr())
                          : filtered.isEmpty
                              ? DsMessage(icon: Icons.search_off_rounded, title: "s_no_matching_coupons".tr())
                              : RefreshIndicator(
                                  onRefresh: () => context.read<GetCouponsCubit>().getCoupons(),
                                  child: ListView.separated(
                                    controller: scrollController,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    // Bottom room so the FAB never covers the last card.
                                    padding: const EdgeInsets.only(top: DsSpace.xs, bottom: 96),
                                    itemCount: filtered.length + (context.read<GetCouponsCubit>().isLoadingMore ? 1 : 0),
                                    separatorBuilder: (context, index) => const SizedBox(height: DsSpace.md),
                                    itemBuilder: (context, index) => index == filtered.length
                                        ? const Center(child: Padding(padding: EdgeInsets.all(DsSpace.lg), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
                                        : CouponItem(couponData: filtered[index], index: couponsList.indexOf(filtered[index])),
                                  ),
                                ),
                    );
                  } else if (state is GetCouponsErrorState) {
                    return DsMessage(
                      icon: Icons.cloud_off_rounded,
                      title: state.error,
                      actionLabel: "s_retry".tr(),
                      onAction: () => context.read<GetCouponsCubit>().getCoupons(),
                    );
                  }
                  return const _CouponsShimmer();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CouponsShimmer extends StatelessWidget {
  const _CouponsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: DsSpace.page, vertical: DsSpace.xs),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: DsSpace.md),
      itemBuilder: (_, __) => const DsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [DsSkeleton(width: 40, height: 40, radius: DsRadius.md), SizedBox(width: DsSpace.md), DsSkeleton(width: 90, height: 18), Spacer(), DsSkeleton(width: 56, height: 22, radius: DsRadius.pill)]),
            SizedBox(height: DsSpace.lg),
            DsSkeleton(width: 160),
            SizedBox(height: DsSpace.md),
            DsSkeleton(height: 40, radius: DsRadius.md),
            SizedBox(height: DsSpace.lg),
            Row(children: [DsSkeleton(width: 80, height: 12), Spacer(), DsSkeleton(width: 90, height: 12)]),
          ],
        ),
      ),
    );
  }
}
