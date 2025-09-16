import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/products_details_view.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class MainProductItem extends StatelessWidget {
  const MainProductItem({super.key, required this.productDetails});

  final Items productDetails;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationUtils.navigateTo(
          context: context,
          destinationScreen: ProductsDetailsView(
            productData: productDetails,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp20(context)),
          border: Border.all(color: Color(0xffE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.sp10(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: AppConstants.height20(context)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.01),
                          child: DefaultCachedNetworkImage(
                            imageUrl: productDetails.images!.isNotEmpty
                                ? productDetails.images!.first.attach ?? ""
                                : "",
                            fit: BoxFit.contain,
                            imageWidth: MediaQuery.of(context).size.width,
                            imageHeight: MediaQuery.of(context).size.height * 0.14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                       CacheKeysManger.getUserLanguageFromCache()=="en"?productDetails.name!.en ?? "": productDetails.name!.ar ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.inter16500black(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: AppConstants.width5(context)),

                Text(
                  "${productDetails.priceAfterDiscount.toStringAsFixed(2)} ج.م",
                  style: Styles.inter14600black(context).copyWith(color: AppColors.primaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: AppConstants.width5(context)),
                Text(
                  productDetails.discount != 0.0 && productDetails.discount != 0 && productDetails.discount != null
                      ? "${productDetails.price} ج.م"
                      : "",
                  style: Styles.inter14600black(context).copyWith(
                    color: const Color(0xffC8C8C8),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: const Color(0xffC8C8C8),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height15(context)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width10(context),
                vertical: AppConstants.height5(context),
              ),
              margin: EdgeInsets.symmetric(horizontal: AppConstants.width10(context)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                color: AppColors.primaryColor,
              ),
              alignment: AlignmentDirectional.center,
              child: Text("عرص التفاصيل", style: Styles.inter14600black(context).copyWith(color: Colors.white)),
            ),
            SizedBox(height: AppConstants.height10(context)),
          ],
        ),
      ),
    );
  }
}
