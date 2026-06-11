import 'package:alrayan_admin/core/shared_widgets/custom_dropdown_formfield.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/text_field_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryRowItem extends StatelessWidget {
  const CategoryRowItem({super.key});

  String _categoryName(dynamic item) {
    final lang = CacheKeysManger.getUserLanguageFromCache();

    if (lang == "en") {
      return item.name?.en ?? "";
    }

    return item.name?.ar ?? "";
  }

  String _subCategoryName(SubCategories item) {
    final lang = CacheKeysManger.getUserLanguageFromCache();

    if (lang == "en") {
      return item.name?.en ?? "";
    }

    return item.name?.ar ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectProductPhotosCubit, SelectProductPhotosStates>(
      builder: (context, selectState) {
        final selectCubit = context.read<SelectProductPhotosCubit>();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldHeader(text: "الصنف"),
                  SizedBox(height: AppConstants.height5(context)),
                  BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
                    builder: (context, state) {
                      if (state is! GetCategoriesSuccessState) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final categories = state.categoriesModel.data ?? [];

                      return CustomDropDownButton(
                        hintText: "اختر الصنف",
                        value: selectCubit.mainCategory,
                        items: categories.map((e) => _categoryName(e)).toList(),
                        onChanged: (value) {
                          if (value == null || value.isEmpty) return;

                          final selected = categories.firstWhere(
                                (e) => _categoryName(e) == value,
                            orElse: () => categories.first,
                          );

                          selectCubit.changeMainCategory(
                            id: selected.id,
                            name: value,
                          );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "اختر الصنف الرئيسى";
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFieldHeader(
                    text: "اختر الصنف الفرعى",
                    isRequired: false,
                  ),
                  SizedBox(height: AppConstants.height5(context)),
                  BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
                    builder: (context, state) {
                      if (state is! GetCategoriesSuccessState) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final categories = state.categoriesModel.data ?? [];

                      final selectedMain = categories.where(
                            (e) => e.id == selectCubit.mainCategoryId,
                      );

                      final subItems = selectedMain.isNotEmpty
                          ? (selectedMain.first.subCategories ?? <SubCategories>[])
                          : <SubCategories>[];

                      final bool isEnabled = subItems.isNotEmpty;

                      return CustomDropDownButton(
                        hintText: "اختر الصنف الفرعى",
                        value: selectCubit.subCategory,
                        items: subItems.map((e) => _subCategoryName(e)).toList(),
                        onChanged: isEnabled
                            ? (value) {
                          if (value == null || value.isEmpty) return;

                          final selectedSub = subItems.firstWhere(
                                (e) => _subCategoryName(e) == value,
                            orElse: () => subItems.first,
                          );

                          selectCubit.changeSubCategory(
                            id: selectedSub.id,
                            name: value,
                          );
                        }
                            : null,
                        validator: (value) {
                          return null;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}