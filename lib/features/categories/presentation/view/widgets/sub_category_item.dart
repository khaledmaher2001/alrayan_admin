import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/categories/presentation/view/create_sub_category_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/sub_categories_model.dart';

class SubCategoryItem extends StatelessWidget {
  const SubCategoryItem({super.key, required this.index, required this.subCategoriesModel});

  final int index;
  final Data subCategoriesModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width10(context),
          vertical: AppConstants.height5(context),
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        ),
        child: Row(
          children: [
            DefaultCachedNetworkImage(
              imageUrl: subCategoriesModel.icon ?? "",
              fit: BoxFit.fill,
              imageHeight: AppConstants.height30(context),
              imageWidth: AppConstants.height30(context),
            ),
            SizedBox(width: AppConstants.width15(context)),
            Expanded(
              child: Text(
                subCategoriesModel.name!.ar ?? "",
                style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
            IconButton(
              onPressed: () {
                NavigationUtils.navigateTo(
                  context: context,
                  destinationScreen: CreateSubCategoryView(
                    subCategoryData: subCategoriesModel,
                    mainCategoryId: subCategoriesModel.mainCategoryId!,
                  ),
                );
              },
              icon: SvgPicture.asset(AssetData.edit, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
