import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/top_products/presentation/views/top_products_view.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class MostOrderedItem extends StatelessWidget {
  const MostOrderedItem({super.key, required this.instance, required this.fromHome});
  final TopSellingProducts instance;
  final bool fromHome;

  @override
  Widget build(BuildContext context) {
    // Matches the avatar size used in TopCustomerItem ("الأكثر تفاعلا")
    // so the two home cards look consistent side by side.
    final imageSize = MediaQuery.of(context).size.width * .12;

    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppConstants.sp10(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(
              0,
              0,
            ), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fromHome) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    "المنتجات الاكثر طلبا",
                    style: Styles.inter16500black(context),
                  ),
                ),
                SizedBox(width: AppConstants.width20(context)),
                InkWell(
                  onTap: () {
                    NavigationUtils.navigateTo(context: context, destinationScreen: TopProductsView());
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width15(context), vertical: AppConstants.height10(context) / 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.shade50,
                      borderRadius: BorderRadius.circular(
                        AppConstants.sp5(context),
                      ),
                    ),
                    child: Text(
                      "عرض الكل",
                      style: Styles.inter10400grey(context).copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                )
              ],
            ),
            Text(
              "حاول توفير اكبر كمية من المنتجات التي عليها طلب كبير",
              style: Styles.inter10400grey(context),
            ),
            SizedBox(height: AppConstants.height20(context)),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                child: DefaultCachedNetworkImage(
                  imageUrl: instance.image ?? '',
                  imageHeight: imageSize,
                  imageWidth: imageSize,
                  fit: BoxFit.cover,
                  char: instance.name?.isNotEmpty == true ? instance.name![0] : '',
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: AppConstants.width15(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instance.name ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.inter14500black(context),
                    ),
                    SizedBox(
                      height: AppConstants.height5(context),
                    ),
                    Text(
                      "مباع ${instance.totalSold ?? 0} مرة",
                      style: Styles.inter10400grey(context),
                    ),
                    if (instance.revenue != null) ...[
                      SizedBox(height: AppConstants.height5(context) / 2),
                      Text(
                        "الإيراد: ${_formatMoney(instance.revenue)} ج.م",
                        style: Styles.inter10400grey(context).copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatMoney(dynamic value) {
  final number = value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
  final asString = number.toStringAsFixed(number % 1 == 0 ? 0 : 2);
  final parts = asString.split('.');
  final digits = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return parts.length > 1 ? '$digits.${parts[1]}' : digits;
}
