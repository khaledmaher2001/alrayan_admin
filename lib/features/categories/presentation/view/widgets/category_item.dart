import 'package:easy_localization/easy_localization.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/categories/presentation/view/create_category_view.dart';
import 'package:alrayan_admin/features/categories/presentation/view/sub_categories_view.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.index, required this.categoriesModel});

  final int index;
  final Data categoriesModel;

  @override
  Widget build(BuildContext context) {
    final name = CacheKeysManger.getUserLanguageFromCache() == "en" ? categoriesModel.name?.en ?? "" : categoriesModel.name?.ar ?? "";
    // Image on top, name on a white strip (readable with or without a picture),
    // edit as a small action on that strip; tapping the tile opens sub-categories.
    return SizedBox(
      height: MediaQuery.of(context).size.height * .155,
      child: Material(
        color: DsColor.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.lg), side: const BorderSide(color: DsColor.border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: SubCategoriesView(mainCategoryId: categoriesModel.id!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => DefaultCachedNetworkImage(
                    imageUrl: categoriesModel.icon ?? "",
                    imageWidth: c.maxWidth,
                    imageHeight: c.maxHeight,
                    fit: BoxFit.cover,
                    char: name.isNotEmpty ? name.characters.first : null,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const SizedBox(width: DsSpace.sm),
                    Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.label)),
                    IconButton(
                      tooltip: "s_edit".tr(),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      onPressed: () => NavigationUtils.navigateTo(context: context, destinationScreen: CreateCategoryView(categoryData: categoriesModel)),
                      icon: const Icon(Icons.edit_outlined, size: 18, color: DsColor.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
