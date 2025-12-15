import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartItem extends StatelessWidget {
  const PieChartItem({super.key, required this.instance});
  final OrderStats instance;

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      AppConstants.getStatusText(instance.ordersByStatus![4].status!): instance.ordersByStatus![4].percentage?.toDouble() ?? 0,
      AppConstants.getStatusText(instance.ordersByStatus![1].status!): instance.ordersByStatus![1].percentage?.toDouble() ?? 0,
      AppConstants.getStatusText(instance.ordersByStatus![3].status!): instance.ordersByStatus![3].percentage?.toDouble() ?? 0,
      AppConstants.getStatusText(instance.ordersByStatus![0].status!): instance.ordersByStatus![0].percentage?.toDouble() ?? 0,
      AppConstants.getStatusText(instance.ordersByStatus![5].status!): instance.ordersByStatus![5].percentage?.toDouble() ?? 0,
    };

    final colorList = <Color>[
      Colors.orange.withOpacity(0.8),
      Colors.purple.withOpacity(0.8),
      Colors.blue.withOpacity(0.8),
      Colors.green.withOpacity(0.8),
      Colors.red.withOpacity(0.8),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(dataMap.length, (index) {
              String key = dataMap.keys.elementAt(index);
              Color color = colorList[index];
              return Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: color,
                  ),
                  SizedBox(width:AppConstants.width5(context) ),
                  Text(
                    key,
                    style: Styles.inter14500black(context),
                  ),
                ],
              );
            }),
          ),
          PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartRadius: MediaQuery.of(context).size.width / 4,
            colorList: colorList,
            initialAngleInDegree: 0,
            centerWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "النسبة",
                  style: Styles.inter14500black(context),
                ),
                Text(
                  "100%",
                  style: Styles.inter10400grey(context),
                ),
              ],
            ),
            chartType: ChartType.ring,
            ringStrokeWidth: 30,
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: false,
              showChartValues: false,
              showChartValuesInPercentage: true,
              decimalPlaces: 0,
            ),
            legendOptions: const LegendOptions(
              showLegends: false, // نلغي الـ Legend الافتراضي
            ),
          ),
        ],
      ),
    );
  }
}