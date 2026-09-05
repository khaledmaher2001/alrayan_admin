import 'dart:async';

import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/search_widget.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_low_stock_products/get_low_stock_products_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/view_models/get_low_stock_products/get_low_stock_products_state.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/home_analytics_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LowStockProductsViewBody extends StatefulWidget {
  const LowStockProductsViewBody({super.key});

  @override
  State<LowStockProductsViewBody> createState() =>
      _LowStockProductsViewBodyState();
}

class _LowStockProductsViewBodyState extends State<LowStockProductsViewBody> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;
  bool isLoading = false;

  Future<void> pagination() async {
    final cubit = context.read<GetLowStockProductsCubit>();
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
          .read<GetLowStockProductsCubit>()
          .getLowStockProducts(search: searchController.text);
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
            title: "المخزون المنخفض",
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
              "كل المنتجات التي وصلت لحد منخفض وتحتاج متابعة أو إعادة توفير",
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
                    .read<GetLowStockProductsCubit>()
                    .getLowStockProducts(search: value);
              },
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Expanded(
            child:
                BlocBuilder<GetLowStockProductsCubit, GetLowStockProductsState>(
              builder: (context, state) {
                final cubit = context.read<GetLowStockProductsCubit>();

                if (state is GetLowStockProductsLoading) {
                  return const CustomLoadingItem();
                }

                if (state is GetLowStockProductsError) {
                  return _ErrorState(
                    message: state.error,
                    onRetry: () => cubit.getLowStockProducts(),
                  );
                }

                if (cubit.products.isEmpty) {
                  return cubit.search.isEmpty
                      ? const _EmptyState(
                          title: "لا يوجد منتجات منخفضة المخزون",
                          subtitle: "كل المنتجات مخزونها جيد حاليا",
                        )
                      : const _EmptyState(
                          title: "لا يوجد نتائج",
                          subtitle: "لا يوجد منتجات مطابقة لبحثك",
                        );
                }

                return RefreshIndicator(
                  onRefresh: () => cubit.getLowStockProducts(),
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width20(context),
                      vertical: AppConstants.height10(context),
                    ),
                    itemBuilder: (context, index) {
                      if (index == cubit.products.length) {
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

                      return LowStockProductListItem(
                        product: cubit.products[index],
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppConstants.height10(context)),
                    itemCount: cubit.products.length + (cubit.hasMore ? 1 : 0),
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
              Icons.inventory_2_outlined,
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
