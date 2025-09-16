import 'package:alrayan_admin/core/shared_widgets/custom_dropdown_formfield.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_states.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_states.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterProductsItem extends StatefulWidget {
  const FilterProductsItem({super.key});

  @override
  State<FilterProductsItem> createState() => _FilterProductsItemState();
}

class _FilterProductsItemState extends State<FilterProductsItem> {
  late ChangeCategoryCubit cubit;


  final isEn = CacheKeysManger.getUserLanguageFromCache() == "en";
  late String allLabel;

  @override
  void initState() {
    cubit = context.read<ChangeCategoryCubit>();
    allLabel = isEn ? "All" : "الكل";
    if (cubit.mainCategory == null || cubit.mainCategory!.isEmpty) {
      cubit
        ..mainCategory = allLabel
        ..mainCategoryId = null
        ..subCategory = null
        ..subCategoryId = null;
      cubit.changeCategoryState();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangeCategoryCubit, ChangeCategoryStates>(
      builder: (context, changeState) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
                  builder: (context, state) {
                    if (state is! GetCategoriesSuccessState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = state.categoriesModel.data ?? [];

                    return CustomDropDownButton(
                      hintText: "اختر الصنف",
                      value: cubit.mainCategory,
                      items: [
                        allLabel,
                        ...categories.map((e) => isEn ? (e.name?.en ?? "") : (e.name?.ar ?? "")),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        if (value == allLabel) {
                          context.read<GetProductsCubit>().getProducts();
                          cubit
                            ..mainCategory = allLabel
                            ..mainCategoryId = null
                            ..subCategory = null
                            ..subCategoryId = null
                            ..changeCategoryState();
                          return;
                        }

                        final selected = categories.firstWhere(
                              (e) => (isEn ? (e.name?.en ?? "") : (e.name?.ar ?? "")) == value,
                          orElse: () => categories.first,
                        );

                        context.read<GetProductsCubit>().getProducts(categoryId: selected.id);

                        cubit
                          ..mainCategory = value
                          ..mainCategoryId = selected.id
                          ..subCategory = null
                          ..subCategoryId = null
                          ..changeCategoryState();
                      },
                      validator: (value) {
                        return null;
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
                  builder: (context, state) {
                    if (state is! GetCategoriesSuccessState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = state.categoriesModel.data ?? [];

                    // استخرج الصنف الرئيسي المختار (لو مش مختار، القائمة تكون فاضية)
                    final selectedMain = categories.where((e) => e.id == cubit.mainCategoryId);
                    final subItems = selectedMain.isNotEmpty
                        ? (selectedMain.first.subCategories ?? [])
                        : <SubCategories>[]; // نوع موديلك

                    // لو الويجت بتاعك يدعم disable، استخدمه هنا لما القائمة فاضية
                    final isEnabled = subItems.isNotEmpty;

                    return CustomDropDownButton(
                      hintText: "اختر الصنف الفرعى",
                      value: cubit.subCategory,
                      items: subItems
                          .map(
                            (e) => CacheKeysManger.getUserLanguageFromCache() == "ar"
                                ? e.name!.ar ?? ""
                                : e.name!.en ?? "",
                          )
                          .toList(),
                      onChanged: isEnabled
                          ? (value) {
                              final selectedSub = subItems.firstWhere(
                                (e) =>
                                    (CacheKeysManger.getUserLanguageFromCache() == "ar"
                                        ? e.name!.ar ?? ""
                                        : e.name!.en ?? "") ==
                                    (value ?? ""),
                                orElse: () => subItems.first,
                              );

                              context.read<GetProductsCubit>().getProducts(
                                categoryId: cubit.mainCategoryId,
                                subCategoryId: selectedSub.id,
                              );
                              cubit.subCategory = value;
                              cubit.subCategoryId = selectedSub.id;
                              cubit.changeCategoryState();
                            }
                          : null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "اختر الصنف الفرعى";
                        }
                        return null;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
