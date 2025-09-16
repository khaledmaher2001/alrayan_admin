import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/categories/presentation/view/create_category_view.dart';
import 'package:alrayan_admin/features/categories/presentation/view/widgets/category_item.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationUtils.navigateTo(context: context, destinationScreen: CreateCategoryView());
        },
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          SizedBox(height: AppConstants.height10(context)),
          Text("التصنيفات", textAlign: TextAlign.center, style: Styles.inter18500Black(context)),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
              child: BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
                builder: (context, state) {
                  if (state is GetCategoriesSuccessState) {
                    return state.categoriesModel.data!.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await context.read<GetCategoriesCubit>().getCategories();
                            },
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, // Number of columns
                                mainAxisSpacing: AppConstants.height10(context),
                                crossAxisSpacing: AppConstants.width10(context),
                                childAspectRatio: .8, // Adjust to fit design
                              ),
                              itemCount: state.categoriesModel.data!.length,
                              itemBuilder: (context, index) =>
                                  CategoryItem(categoriesModel: state.categoriesModel.data![index], index: index)
                                      .animate(delay: (80 * index).ms)
                                      .slideY(begin: 0.4, end: 0, curve: Curves.easeOutQuad, duration: 450.ms)
                                      .fadeIn(duration: 400.ms)
                                      .scale(
                                        begin: const Offset(0.9, 0.9),
                                        end: const Offset(1, 1),
                                        curve: Curves.easeOut,
                                        duration: 350.ms,
                                      ),
                            ),
                          )
                        : Center(child: SvgPicture.asset(AssetData.emptyCategory));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
