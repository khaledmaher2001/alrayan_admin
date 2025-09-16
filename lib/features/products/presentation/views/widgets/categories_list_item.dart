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

class CategoriesListItem extends StatelessWidget {
  const CategoriesListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.04,
      child: BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
        builder: (context, categoriesState) {
          if (categoriesState is GetCategoriesSuccessState) {
            return BlocBuilder<ChangeCategoryCubit, ChangeCategoryStates>(
              builder: (context, changeState) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: AppConstants.width10(context)),
                  itemBuilder: (context, index) {
                    final category = categoriesState.categoriesModel.data![index];
                    final textPainter = TextPainter(
                      text: TextSpan(
                        text: CacheKeysManger.getUserLanguageFromCache() == "en"
                            ? category.name!.en ?? ""
                            : category.name!.ar ?? "",
                        style: Styles.inter14600black(context),
                      ),
                      textDirection: TextDirection.ltr,
                    )..layout();
                    final textWidth = textPainter.width;
                    return Row(
                      children: [
                        if (index == 0) SizedBox(width: AppConstants.width20(context)),
                        GestureDetector(
                          onTap: () {
                            context.read<ChangeCategoryCubit>().selectCategory(
                              categoryId: category.id,
                              categoryIndex: index,
                            );
                            if ((category.subCategories ?? []).isNotEmpty) {
                              context.read<ChangeCategoryCubit>().selectSubCategory(
                                subCategoryId: category.subCategories!.first.id,
                                subCategoryIndex: 0,
                              );
                            }
                            AppConstants.searchController.clear();
                            context.read<GetProductsCubit>().getProducts(
                              categoryId: AppConstants.mainCategoryId,
                              subCategoryId: AppConstants.subCategoryId,
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                CacheKeysManger.getUserLanguageFromCache() == "en"
                                    ? category.name!.en ?? ""
                                    : category.name!.ar ?? "",
                                style: context.read<ChangeCategoryCubit>().selectedCategoryIndex == index
                                    ? Styles.inter14600black(context)
                                    : Styles.inter14500black(context),
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              if (context.read<ChangeCategoryCubit>().selectedCategoryIndex == index)
                                Container(
                                  height: AppConstants.height5(context) / 1.5,
                                  width: textWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (index == categoriesState.categoriesModel.data!.length - 1)
                          SizedBox(width: AppConstants.width20(context)),
                      ],
                    );
                  },
                  itemCount: categoriesState.categoriesModel.data!.length,
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
