import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/shimmer_helpers.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/text_styles/styles.dart';
import '../../view_models/get_top_products_cubit/get_top_products_cubit.dart';

/// "المنتجات الأكثر طلبا" as a clean ranked list — each row shows the
/// product's rank, photo, name, sales count and revenue, sorted by
/// totalSold descending, with the top 3 picked out via the brand palette.
class TopProductsViewBody extends StatelessWidget {
  const TopProductsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.height20(context)),
          CustomAppBar(
            title: "المنتجات الاكثر طلبا",
            textColor: Colors.black,
            withNotifications: false,
            hasBack: true,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Text(
              "حاول توفير المنتجات الاكثر طلبا باستمرار",
              style: Styles.inter14600gray(context),
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Expanded(
            child: BlocBuilder<GetTopProductsCubit, GetTopProductsState>(
              builder: (context, state) {
                if (state is! GetTopProductsLoaded) return const _TopProductsShimmer();
                if (state.users.isEmpty) {
                  return Center(
                    child: Text("لا يوجد منتجات حتى الآن", style: Styles.inter14600gray(context)),
                  );
                }

                final sorted = [...state.users]..sort(
                    (a, b) => (b.totalSold ?? 0).compareTo(a.totalSold ?? 0),
                  );

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width20(context),
                    vertical: AppConstants.height10(context),
                  ),
                  itemCount: sorted.length,
                  separatorBuilder: (context, index) => SizedBox(height: AppConstants.height15(context)),
                  itemBuilder: (context, index) {
                    return _RankedProductItem(product: sorted[index], rank: index + 1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductsShimmer extends StatelessWidget {
  const _TopProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return appShimmer(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width20(context),
          vertical: AppConstants.height10(context),
        ),
        itemCount: 6,
        separatorBuilder: (context, index) => SizedBox(height: AppConstants.height15(context)),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(AppConstants.sp10(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: Row(
              children: [
                shimmerBox(context, width: AppConstants.width20(context) * 1.3, height: AppConstants.width20(context) * 1.3),
                SizedBox(width: AppConstants.width10(context)),
                shimmerBox(context, width: AppConstants.width20(context) * 2.2, height: AppConstants.width20(context) * 2.2),
                SizedBox(width: AppConstants.width10(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerBox(context, width: double.infinity, height: AppConstants.height15(context)),
                      SizedBox(height: AppConstants.height5(context)),
                      shimmerBox(context, width: MediaQuery.of(context).size.width * .3, height: AppConstants.height10(context)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Color _rankColor(int rank) {
  switch (rank) {
    case 1:
      return AppColors.primarySwatchColor;
    case 2:
      return AppColors.secondaryColor;
    case 3:
      return AppColors.redColor;
    default:
      return rank.isEven ? AppColors.secondaryColor : AppColors.primarySwatchColor;
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

class _RankedProductItem extends StatelessWidget {
  const _RankedProductItem({required this.product, required this.rank});

  final TopSellingProducts product;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor(rank);
    final imageSize = AppConstants.width20(context) * 2.2;
    final isTopThree = rank <= 3;

    return Container(
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: isTopThree ? Border.all(color: rankColor.withOpacity(.3)) : null,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 3),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppConstants.width20(context) * 1.3,
            height: AppConstants.width20(context) * 1.3,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: Text(
              "#$rank",
              style: Styles.inter14600black(context).copyWith(color: rankColor, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: AppConstants.width10(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            child: DefaultCachedNetworkImage(
              imageUrl: product.image ?? '',
              imageWidth: imageSize,
              imageHeight: imageSize,
              fit: BoxFit.cover,
              char: product.name?.isNotEmpty == true ? product.name![0] : '',
              color: rankColor,
            ),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.inter14600black(context),
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  "مباع ${product.totalSold ?? 0} مرة",
                  style: Styles.inter10400grey(context),
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  "الإيراد: ${_formatMoney(product.revenue)} ج.م",
                  style: Styles.inter10400grey(context).copyWith(color: rankColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
