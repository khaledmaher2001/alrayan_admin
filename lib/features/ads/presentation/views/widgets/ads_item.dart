import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:alrayan_admin/features/ads/presentation/views/add_ads_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/shared_widgets/custom_loading_item.dart';
import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/navigation_utility.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../view_models/delete_banner/delete_banner_cubit.dart';

class AdsItem extends StatelessWidget {
  const AdsItem({
    super.key,
    required this.instance,
    required this.onDeleteTap,
  });

  final Data instance;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width * .22;

    return Container(
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                child: DefaultCachedNetworkImage(
                  imageUrl: instance.imagePath ?? "",
                  imageWidth: imageSize,
                  imageHeight: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: AppConstants.width10(context) - 2,
                        vertical: AppConstants.height10(context) - 2,
                      ),
                      decoration: BoxDecoration(
                        color: instance.type == "discount"
                            ? AppColors.primaryColor.withOpacity(.15)
                            : AppColors.gray.withOpacity(.15),
                        borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                      ),
                      child: Text(
                        instance.type == "discount" ? "عرض علي منتج" : "اعلان عادي",
                        style: Styles.inter12500Black(context).copyWith(
                          color: instance.type == "discount" ? AppColors.primaryColor : AppColors.gray,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    Text(
                      instance.title ?? '',
                      style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Text(
                      instance.description ?? '',
                      style: Styles.inter14600gray(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (instance.product != null) ...[
                      SizedBox(height: AppConstants.height5(context)),
                      Text(
                        "المنتج المرتبط: ${instance.product?.name ?? ''}",
                        style: Styles.inter10400grey(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: AppConstants.height5(context)),
                    Row(
                      children: [
                        Icon(Icons.link, size: 14, color: AppColors.gray),
                        SizedBox(width: AppConstants.width5(context)),
                        Expanded(
                          child: Text(
                            instance.link != null && instance.link!.isNotEmpty ? instance.link! : "لا يوجد رابط",
                            style: Styles.inter10400grey(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height15(context)),
          Divider(color: AppColors.gray.withOpacity(.2), height: 1),
          SizedBox(height: AppConstants.height5(context)),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: AddAdsView(editingBanner: instance),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context) - 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("تعديل", style: Styles.inter14500black(context)),
                        SizedBox(width: AppConstants.width5(context)),
                        SvgPicture.asset(AssetData.edit, width: AppConstants.width15(context)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: AppConstants.height20(context) * 1.2,
                child: VerticalDivider(color: AppColors.gray.withOpacity(.2), width: 1),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    onDeleteTap();
                  },
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context) - 2),
                    child: BlocBuilder<DeleteBannersCubit, DeleteBannersState>(
                      builder: (context, state) {
                        final deleteCubit = context.read<DeleteBannersCubit>();
                        final isCurrentDeleting =
                            state is DeleteBannersLoading && deleteCubit.selectedBanner == instance.id;

                        if (isCurrentDeleting) {
                          return Center(
                            child: CustomLoadingItem(
                              size: AppConstants.sp20(context),
                              color: AppColors.redColor,
                            ),
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "حذف",
                              style: Styles.inter14500black(context).copyWith(color: AppColors.redColor),
                            ),
                            SizedBox(width: AppConstants.width5(context)),
                            SvgPicture.asset(
                              AssetData.delete,
                              width: AppConstants.width15(context),
                              colorFilter: ColorFilter.mode(AppColors.redColor, BlendMode.srcIn),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
