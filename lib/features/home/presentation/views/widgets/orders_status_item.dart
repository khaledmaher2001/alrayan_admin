import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/pie_chart_item.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
class OrdersStatusItem extends StatelessWidget {
  const OrdersStatusItem({super.key, required this.instance});
  final OrderStats instance;
  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppConstants.sp10(context),
        ),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "s_order_status_overview".tr(),
            style: Styles.inter16500black(context),
          ),
          Text(
            "s_chart_showing_the_share_of_orders_so".tr(),
            style: Styles.inter10400grey(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          PieChartItem(instance: instance),
        ],
      ),
    );
  }
}
