import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
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
  const CategoriesView({super.key, this.asPage = false});

  /// Opened from "More" as its own page (needs a back button) rather than as a tab.
  final bool asPage;

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
          if (asPage)
            SafeArea(
              bottom: false,
              child: CustomAppBar(title: "more_categories".tr(), hasBack: true, withNotifications: false, textColor: Colors.black),
            )
          else ...[
            SizedBox(height: AppConstants.height10(context)),
            Text("s_categories".tr(), textAlign: TextAlign.center, style: Styles.inter18500Black(context)),
          ],
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
              child: BlocBuilder<GetCategoriesCubit, GetCategoriesStates>(
                builder: (context, state) {
                  if (state is GetCategoriesLoadingState || state is GetCategoriesInitState) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is GetCategoriesErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: DsColor.danger),
                          SizedBox(height: AppConstants.height10(context)),
                          Text(
                            "s_couldn_t_load_categories".tr(),
                            style: Styles.inter16500black(context),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.height10(context)),
                          ElevatedButton.icon(
                            onPressed: () => context.read<GetCategoriesCubit>().getCategories(),
                            icon: const Icon(Icons.refresh),
                            label: Text("s_retry".tr()),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is GetCategoriesSuccessState) {
                    return state.categoriesModel.data!.isNotEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await context.read<GetCategoriesCubit>().getCategories();
                            },
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: AppConstants.height10(context),
                                crossAxisSpacing: AppConstants.width10(context),
                                childAspectRatio: .8,
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
                        : RefreshIndicator(
                            onRefresh: () async {
                              await context.read<GetCategoriesCubit>().getCategories();
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Center(child: SvgPicture.asset(AssetData.emptyCategory)),
                              ),
                            ),
                          );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
