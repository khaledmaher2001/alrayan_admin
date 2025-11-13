import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared_widgets/default_cached_network_image.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
class MostOrderedItem extends StatelessWidget {
  const MostOrderedItem({super.key, required this.instance});
  final TopSellingProducts instance;
  @override
  Widget build(BuildContext context) {
    return  Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  "المنتجات الاكثر طلبا",
                  style: Styles.inter16500black(context),
                ),
              ),
              SizedBox(width: AppConstants.width20(context),),
              InkWell(
                onTap: (){
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => AllReviewsView()));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context),vertical: AppConstants.height10(context)/1.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.shade50,
                    borderRadius: BorderRadius.circular(
                      AppConstants.sp5(context),
                    ),
                  ),
                  child: Text("عرض الكل", style: Styles.inter10400grey(context).copyWith(
                      color: AppColors.primaryColor
                  ),),
                ),
              )
            ],
          ),
          Text(
            "حاول توفير اكبر كمية من المنتجات التي عليها طلب كبير",
            style: Styles.inter10400grey(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                  AppConstants.sp5(context),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp10(context),
                  ),
                  color: AppColors.gray.withOpacity(.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp10(context),
                  ),
                  child: DefaultCachedNetworkImage(
                    imageUrl:
                    "https://pics.clipartpng.com/midle/Cheese_PNG_Clipart-3141.png",
                    imageHeight:
                    MediaQuery.of(context).size.width * .12,
                    imageWidth:
                    MediaQuery.of(context).size.width * .12,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instance
                          .name!,
                      style: Styles.inter14500black(context),
                    ),
                    SizedBox(
                      height: AppConstants.height5(context),
                    ),
                    Text(
                      "منتجات الالبان",
                      style: Styles.inter10400grey(context),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "المبيعات",
                    style: Styles.inter14500black(context),
                  ),
                  Text(
                    "مباع ${instance.totalSold} مرة",
                    style: Styles.inter10400grey(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
