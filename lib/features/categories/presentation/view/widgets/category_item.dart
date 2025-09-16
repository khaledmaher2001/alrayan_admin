import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/categories/presentation/view/create_category_view.dart';
import 'package:alrayan_admin/features/categories/presentation/view/sub_categories_view.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.index, required this.categoriesModel});

  final int index;
  final Data categoriesModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationUtils.navigateTo(
          context: context,
          destinationScreen: SubCategoriesView(mainCategoryId: categoriesModel.id!),
        );
      },
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * .155,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              color: Colors.grey,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              child: DefaultCachedNetworkImage(imageUrl: categoriesModel.icon ?? "", fit: BoxFit.fill),
            ),
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            child: IconButton(
              onPressed: () {
                NavigationUtils.navigateTo(
                  context: context,
                  destinationScreen: CreateCategoryView(categoryData: categoriesModel),
                );
              },
              icon: Container(
                padding: EdgeInsets.all(AppConstants.sp5(context)),
                decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                child: SvgPicture.asset(AssetData.edit, color: Colors.white),
              ),
            ),
          ),

          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              height: MediaQuery.of(context).size.height * .05,
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.sp10(context)),
                  bottomRight: Radius.circular(AppConstants.sp10(context)),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                  begin: AlignmentDirectional.bottomCenter,
                  end: AlignmentDirectional.topCenter,
                ),
              ),
              child: Text(
                CacheKeysManger.getUserLanguageFromCache() == "en"
                    ? categoriesModel.name!.en ?? ""
                    : categoriesModel.name!.ar ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Styles.inter14600black(context).copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
