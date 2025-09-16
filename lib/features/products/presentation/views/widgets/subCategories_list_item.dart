import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_states.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/change_category/change_category_states.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubCategoriesListItem extends StatelessWidget {
  const SubCategoriesListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      child: BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
        builder: (context, categoriesState) {
          if (categoriesState is GetCategoriesSuccessState) {
            return BlocBuilder<ChangeCategoryCubit, ChangeCategoryStates>(
              builder: (context, changeState) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: AppConstants.width10(context)),
                  itemBuilder: (context, index) {
                    final subCategory = categoriesState
                        .categoriesModel
                        .data![context.read<ChangeCategoryCubit>().selectedCategoryIndex]
                        .subCategories![index];

                    return Row(
                      children: [
                        if (index == 0) SizedBox(width: AppConstants.width20(context)),
                        GestureDetector(
                          onTap: () {
                            context.read<ChangeCategoryCubit>().selectSubCategory(
                              subCategoryId: subCategory.id!,
                              subCategoryIndex: index,
                            );
                            AppConstants.searchController.clear();
                            context.read<GetProductsCubit>().getProducts(
                              categoryId: AppConstants.mainCategoryId,
                              subCategoryId: AppConstants.subCategoryId,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.width10(context),
                              vertical: AppConstants.height5(context),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                              color: context.read<ChangeCategoryCubit>().selectedSubCategoryIndex == index
                                  ? AppColors.primaryColor.shade100
                                  : null,
                              border: Border.all(
                                color: context.read<ChangeCategoryCubit>().selectedSubCategoryIndex == index
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                              ),
                            ),
                            child: Text(
                              CacheKeysManger.getUserLanguageFromCache() == "ar"
                                  ? subCategory.name!.ar ?? ""
                                  : subCategory.name!.en ?? "",
                              style: Styles.inter14600black(context).copyWith(
                                color: context.read<ChangeCategoryCubit>().selectedSubCategoryIndex == index
                                    ? AppColors.primaryColor
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        if (index ==
                            categoriesState
                                    .categoriesModel
                                    .data![context.read<ChangeCategoryCubit>().selectedCategoryIndex]
                                    .subCategories!
                                    .length -
                                1)
                          SizedBox(width: AppConstants.width20(context)),
                      ],
                    );
                  },
                  itemCount: categoriesState
                      .categoriesModel
                      .data![context.read<ChangeCategoryCubit>().selectedCategoryIndex]
                      .subCategories!
                      .length,
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
