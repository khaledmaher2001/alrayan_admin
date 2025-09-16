import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/categories/presentation/view/create_sub_category_view.dart';
import 'package:alrayan_admin/features/categories/presentation/view/widgets/sub_category_item.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_sub_categories/get_sub_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_sub_categories/get_sub_categories_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SubCategoriesView extends StatefulWidget {
  const SubCategoriesView({super.key, required this.mainCategoryId});

  final int mainCategoryId;

  @override
  State<SubCategoriesView> createState() => _SubCategoriesViewState();
}

class _SubCategoriesViewState extends State<SubCategoriesView> {
  @override
  void initState() {
    context.read<GetSubCategoriesCubit>().getSubCategories(mainCategoryId: widget.mainCategoryId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationUtils.navigateTo(context: context, destinationScreen: CreateSubCategoryView(
            mainCategoryId: widget.mainCategoryId,
          ));
        },
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppConstants.height10(context)),
            Text("الأقسام الفرعية", textAlign: TextAlign.center, style: Styles.inter18500Black(context)),
            SizedBox(height: AppConstants.height20(context)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<GetSubCategoriesCubit>().getSubCategories(mainCategoryId: widget.mainCategoryId);
                  },
                  child: BlocBuilder<GetSubCategoriesCubit, GetSubCategoriesStates>(
                    builder: (context, state) {
                      if (state is GetSubCategoriesSuccessState) {
                        return state.subCategoriesModel.data!.isNotEmpty
                            ? ListView.separated(
                                itemBuilder: (context, index) => SubCategoryItem(
                                  index: index,
                                  subCategoriesModel: state.subCategoriesModel.data![index],
                                ),
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: AppConstants.height10(context)),
                                itemCount: state.subCategoriesModel.data!.length,
                              )
                            : Center(child: SvgPicture.asset(AssetData.emptyCategory));
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
