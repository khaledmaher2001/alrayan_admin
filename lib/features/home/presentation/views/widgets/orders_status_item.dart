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
          Text(
            "متابعة حالة الطلبات",
            style: Styles.inter16500black(context),
          ),
          Text(
            "رسم توضيحي يوضح نسب الطلبات حتي الان",
            style: Styles.inter10400grey(context),
          ),
          SizedBox(height: AppConstants.height20(context)),
          PieChartItem(instance: instance),
        ],
      ),
    );
  }
}
