import 'package:alrayan_admin/core/shared_widgets/custom_dropdown_formfield.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/text_field_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryRowItem extends StatefulWidget {
  const CategoryRowItem({super.key});

  @override
  State<CategoryRowItem> createState() => _CategoryRowItemState();
}

class _CategoryRowItemState extends State<CategoryRowItem> {
  late SelectProductPhotosCubit cubit;

  @override
  void initState() {
    cubit = context.read<SelectProductPhotosCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    value: cubit.mainCategory,
                    // اسم المختار لعرضه
                    items: categories
                        .map(
                          (e) =>
                              CacheKeysManger.getUserLanguageFromCache() == "en" ? e.name!.en ?? "" : e.name!.ar ?? "",
                        )
                        .toList(),
                    onChanged: (value) {
                      // لقطة للكاتيجوري المختار
                      final selected = categories.firstWhere(
                        (e) =>
                            (CacheKeysManger.getUserLanguageFromCache() == "en"
                                ? e.name!.en ?? ""
                                : e.name!.ar ?? "") ==
                            (value ?? ""),
                        orElse: () => categories.first,
                      );

                      setState(() {
                        cubit.mainCategory = value;
                        cubit.mainCategoryId = selected.id;
                        cubit.subCategory = null;
                        cubit.subCategoryId = null;
                      });
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
              TextFieldHeader(text: "اختر الصنف الفرعى", isRequired: false),
              SizedBox(height: AppConstants.height5(context)),
              BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
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
                          (e) =>
                              CacheKeysManger.getUserLanguageFromCache() == "ar" ? e.name!.ar ?? "" : e.name!.en ?? "",
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
                            setState(() {
                              cubit.subCategory = value;
                              cubit.subCategoryId = selectedSub.id;
                            });
                          }
                        : null,
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return "اختر الصنف الفرعى";
                      // }
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
  }
}
