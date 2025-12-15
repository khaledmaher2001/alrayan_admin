import 'package:alrayan_admin/features/ads/data/models/offer_banner_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/shared_widgets/custom_loading_item.dart';
import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../view_models/delete_banner/delete_banner_cubit.dart';
class AdsItem extends StatelessWidget {
  const AdsItem({super.key, required this.instance});
  final Data instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                child: DefaultCachedNetworkImage(
                  imageUrl: instance.imagePath??"",
                  imageWidth: MediaQuery.of(context).size.width * 0.9,
                  imageHeight: MediaQuery.of(context).size.height * 0.18,
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppConstants.sp10(context)),
                child: Row(
                  children: [
                    BlocBuilder<DeleteBannersCubit, DeleteBannersState>(
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () {
                            context.read<DeleteBannersCubit>().selectedBanner = instance.id!;

                            context.read<DeleteBannersCubit>().deleteBanner(id: instance.id!);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.sp10(context),
                              vertical: AppConstants.sp5(context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                            ),
                            child:
                            state is DeleteBannersLoading &&
                                context.read<DeleteBannersCubit>().selectedBanner == instance.id
                                ? CustomLoadingItem(size: AppConstants.sp20(context), color: Colors.white)
                                : SvgPicture.asset(AssetData.delete, color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: AppConstants.height10(context),),
          Text(instance.title??'',style: Styles.inter18500Black(context),),
          SizedBox(height: AppConstants.height5(context),),
          Text(instance.description??'',style: Styles.inter14600gray(context),),
        ],
      ),
    );
  }
}
