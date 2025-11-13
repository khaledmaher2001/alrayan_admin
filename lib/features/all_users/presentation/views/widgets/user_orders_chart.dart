import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserOrdersChart extends StatelessWidget {
  const UserOrdersChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 2:
                      return  Text('فبراير', style:Styles.inter10400grey(context));
                    case 4:
                      return  Text('ابريل', style:Styles.inter10400grey(context));
                    case 6:
                      return  Text('يونيو', style:Styles.inter10400grey(context));
                      case 8:
                      return  Text('اغسطس', style: Styles.inter10400grey(context));
                      case 10:
                      return  Text('اكتوبر', style:Styles.inter10400grey(context));
                      case 12:
                      return  Text('ديسمبر', style:Styles.inter10400grey(context));
                    default:
                      return  SizedBox();
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value % 10 == 0) {
                    return Text(
                      '${value.toInt()}',
                      style: Styles.inter10400grey(context),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 25),
                FlSpot(3, 10),
                FlSpot(6, 35),
                FlSpot(9, 25),
                FlSpot(12, 40),
              ],
              isCurved: true,
              gradient:  LinearGradient(
                colors: [
                  AppColors.primaryColor.shade300,
                  AppColors.primaryColor,
                  ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.2),
                    AppColors.primaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y.toStringAsFixed(1),
                    TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
}
