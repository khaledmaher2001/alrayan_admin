import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'dart:async';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_states.dart';
import 'package:alrayan_admin/features/products/presentation/views/widgets/filter_products_item.dart';
import 'package:alrayan_admin/features/products/presentation/views/widgets/main_product_item.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/utils/constants.dart';

class ProductsViewBody extends StatefulWidget {
  const ProductsViewBody({super.key});

  @override
  State<ProductsViewBody> createState() => _ProductsViewBodyState();
}

class _ProductsViewBodyState extends State<ProductsViewBody> {
  TextEditingController search = TextEditingController();
  ScrollController scrollController = ScrollController();
  Timer? _searchDebounce;

  void _searchProducts(String value) {
    context.read<GetProductsCubit>().getProducts(
      categoryId: context.read<ChangeCategoryCubit>().mainCategoryId,
      subCategoryId: context.read<ChangeCategoryCubit>().subCategoryId,
      name: value.trim(),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchProducts(value);
    });
  }

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      // Pagination bookkeeping (page++, hasMore, in-flight guard) lives in
      // the cubit now — this just asks it to load the next page.
      context.read<GetProductsCubit>().loadMore();
    }
  }

  @override
  void initState() {
    scrollController.addListener(_onScroll);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetProductsCubit>().getProducts(
        categoryId: context.read<ChangeCategoryCubit>().mainCategoryId,
        subCategoryId: context.read<ChangeCategoryCubit>().subCategoryId,
      );
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    search.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height15(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
            child: DefaultTextFormField(
              textInputType: TextInputType.text,
              controller: search,
              hintText: "s_search_for_a_product".tr(),
              onChange: _onSearchChanged,
              onFilledSubmit: (value) {
                // Enter/search-key press searches immediately, skipping
                // the debounce wait.
                _searchDebounce?.cancel();
                _searchProducts(value);
              },
            ),
          ),
          SizedBox(height: AppConstants.height15(context)),
          // CategoriesListItem(),
          FilterProductsItem(),
          SizedBox(height: AppConstants.height10(context)),
          // SubCategoriesListItem(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<GetProductsCubit>().getProducts(
                  categoryId: context.read<ChangeCategoryCubit>().mainCategoryId,
                  subCategoryId: context.read<ChangeCategoryCubit>().subCategoryId,
                  name: search.text.trim(),
                );
              },
              child: BlocBuilder<GetProductsCubit, GetProductsStates>(
                builder: (context, state) {
                  if (state is GetProductsErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: DsColor.danger),
                          SizedBox(height: AppConstants.height10(context)),
                          Text(
                            "s_couldn_t_load_products".tr(),
                            style: Styles.inter16500black(context),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.height10(context)),
                          ElevatedButton.icon(
                            onPressed: () => context.read<GetProductsCubit>().getProducts(
                              categoryId: context.read<ChangeCategoryCubit>().mainCategoryId,
                              subCategoryId: context.read<ChangeCategoryCubit>().subCategoryId,
                            ),
                            icon: const Icon(Icons.refresh),
                            label: Text("s_retry".tr()),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is GetProductsSuccessState) {
                    final products = context.read<GetProductsCubit>().productsList;
                    if (products.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(AssetData.emptyCart, height: 120),
                                SizedBox(height: AppConstants.height10(context)),
                                Text("s_no_products_2".tr(), style: Styles.inter16500black(context)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    // One product per row; bottom padding keeps the last row clear of the add button.
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.sm, DsSpace.page, 96),
                      separatorBuilder: (_, _) => const SizedBox(height: DsSpace.sm),
                      itemCount: products.length +
                          (context.read<GetProductsCubit>().isLoadingMore
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        if (index >= products.length) {
                          return const _LoadingTile();
                        }
                        return MainProductItem(productDetails: products[index]);
                      },
                    );
                  }
                  return Skeletonizer(
                    enabled: true,
                    child: GridView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        vertical: AppConstants.height10(context),
                        horizontal: AppConstants.width20(context),
                      ),
                      itemCount: 6,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConstants.width10(context),
                        mainAxisSpacing: AppConstants.height10(context),
                        childAspectRatio: .71,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 150, width: double.infinity, color: DsColor.border),
                              SizedBox(height: AppConstants.height10(context)),
                              Container(height: 20, width: 100, color: DsColor.border),
                              SizedBox(height: AppConstants.height10(context)),
                              Container(height: 15, width: 60, color: DsColor.border),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
