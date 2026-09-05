import 'dart:async';

import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/search_widget.dart';
import 'package:alrayan_admin/core/shared_widgets/shimmer_helpers.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_inventory_analytics/get_inventory_analytics_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_inventory_analytics/get_inventory_analytics_state.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/home_analytics_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryAnalyticsViewBody extends StatefulWidget {
  const InventoryAnalyticsViewBody({super.key});

  @override
  State<InventoryAnalyticsViewBody> createState() =>
      _InventoryAnalyticsViewBodyState();
}

class _InventoryAnalyticsViewBodyState
    extends State<InventoryAnalyticsViewBody> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;
  bool isLoading = false;

  Future<void> pagination() async {
    final cubit = context.read<GetInventoryAnalyticsCubit>();
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 80 &&
        cubit.hasMore &&
        !isLoading) {
      setState(() => isLoading = true);
      await cubit.loadMore();
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context
          .read<GetInventoryAnalyticsCubit>()
          .getInventoryAnalytics(search: searchController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(pagination);
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    scrollController.removeListener(pagination);
    scrollController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.height20(context)),
          const CustomAppBar(
            title: "تحليل المخزون",
            textColor: Colors.black,
            withNotifications: false,
            hasBack: true,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: Text(
              "كل المنتجات مع المتاح والمباع ونسبة دوران المنتج",
              style: Styles.inter14600gray(context),
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: SearchWidget(
              hint: "ابحث عن منتج",
              searchController: searchController,
              onSearch: (value) {
                _searchDebounce?.cancel();
                context
                    .read<GetInventoryAnalyticsCubit>()
                    .getInventoryAnalytics(search: value);
              },
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Expanded(
            child: BlocBuilder<GetInventoryAnalyticsCubit,
                GetInventoryAnalyticsState>(
              builder: (context, state) {
                final cubit = context.read<GetInventoryAnalyticsCubit>();

                if (state is GetInventoryAnalyticsLoading) {
                  return const _InventoryAnalyticsShimmer();
                }

                if (state is GetInventoryAnalyticsError) {
                  return _ErrorState(
                    message: state.error,
                    onRetry: () => cubit.getInventoryAnalytics(),
                  );
                }

                if (cubit.items.isEmpty) {
                  return cubit.search.isEmpty
                      ? const _EmptyState(
                          title: "لا يوجد بيانات تحليل مخزون",
                          subtitle: "لم يتم العثور على بيانات متاحة حاليا",
                        )
                      : const _EmptyState(
                          title: "لا يوجد نتائج",
                          subtitle: "لا يوجد منتجات مطابقة لبحثك",
                        );
                }

                return RefreshIndicator(
                  onRefresh: () => cubit.getInventoryAnalytics(),
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width20(context),
                      vertical: AppConstants.height10(context),
                    ),
                    itemBuilder: (context, index) {
                      if (index == cubit.items.length) {
                        return isLoading
                            ? Padding(
                                padding:
                                    EdgeInsets.all(AppConstants.sp10(context)),
                                child: CustomLoadingItem(
                                  size:
                                      MediaQuery.of(context).size.width * .08,
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      return HomeAnalyticsCard(
                        child: InventoryAnalyticsListItem(
                          item: cubit.items[index],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppConstants.height10(context)),
                    itemCount: cubit.items.length + (cubit.hasMore ? 1 : 0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.sp20(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 42),
            SizedBox(height: AppConstants.height10(context)),
            Text(message, style: Styles.inter14500black(context)),
            SizedBox(height: AppConstants.height20(context)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: onRetry,
              child: const Text("إعادة المحاولة"),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.sp20(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: AppColors.primaryColor,
              size: 48,
            ),
            SizedBox(height: AppConstants.height10(context)),
            Text(title, style: Styles.inter16500black(context)),
            SizedBox(height: AppConstants.height5(context)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Styles.inter10400grey(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryAnalyticsShimmer extends StatelessWidget {
  const _InventoryAnalyticsShimmer();

  @override
  Widget build(BuildContext context) {
    return appShimmer(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width20(context),
          vertical: AppConstants.height10(context),
        ),
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(height: AppConstants.height10(context)),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(AppConstants.sp20(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    shimmerBox(context, width: AppConstants.width20(context) * 2, height: AppConstants.width20(context) * 2),
                    SizedBox(width: AppConstants.width10(context)),
                    Expanded(
                      child: shimmerBox(context, width: double.infinity, height: AppConstants.height15(context)),
                    ),
                    SizedBox(width: AppConstants.width10(context)),
                    shimmerBox(context, width: 50, height: AppConstants.height15(context)),
                  ],
                ),
                SizedBox(height: AppConstants.height15(context)),
                shimmerBox(context, width: double.infinity, height: AppConstants.height10(context) - 2, radius: 30),
                SizedBox(height: AppConstants.height10(context)),
                Row(
                  children: [
                    shimmerBox(context, width: 70, height: AppConstants.height20(context), radius: 30),
                    SizedBox(width: AppConstants.width10(context)),
                    shimmerBox(context, width: 70, height: AppConstants.height20(context), radius: 30),
                    SizedBox(width: AppConstants.width10(context)),
                    shimmerBox(context, width: 70, height: AppConstants.height20(context), radius: 30),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
