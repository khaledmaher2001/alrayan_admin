import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/home/data/models/inventory_analytics_model.dart';
import 'package:alrayan_admin/features/home/data/models/low_stock_product_model.dart';
import 'package:alrayan_admin/features/home/data/models/sales_report_model.dart';
import 'package:alrayan_admin/features/home/presentation/views/inventory_analytics_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/low_stock_products_view.dart';
import 'package:alrayan_admin/features/home/presentation/views/sales_report_details_view.dart';
import 'package:flutter/material.dart';

class SalesReportSection extends StatelessWidget {
  const SalesReportSection({
    super.key,
    required this.report,
    this.error,
  });

  final SalesReportModel? report;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return const HomeFeatureErrorCard(
        title: "تقارير المبيعات",
        message: "تعذر تحميل تقرير المبيعات حاليا",
      );
    }

    if (report == null) {
      return const HomeFeatureEmptyCard(
        title: "تقارير المبيعات",
        message: "لا يوجد تقرير مبيعات متاح حاليا",
      );
    }

    final summary = report!.summary;
    final breakdown = report!.breakdown;
    final totalOrders = summary?.totalOrders ?? 0;

    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: "تقارير المبيعات",
            subtitle: "ملخص أداء الطلبات والمبيعات خلال آخر 30 يوم",
            trailing: HomeViewAllButton(
              onTap: () {
                NavigationUtils.navigateTo(
                  context: context,
                  destinationScreen: const SalesReportDetailsView(),
                );
              },
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            children: [
              Expanded(
                child: _ReportHeroItem(
                  title: "إجمالي المبيعات",
                  value: "${_formatNumber(summary?.totalRevenue)} ج",
                  color: AppColors.primarySwatchColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Expanded(
                child: _ReportHeroItem(
                  title: "عدد الطلبات",
                  value: _formatNumber(summary?.totalOrders),
                  color: AppColors.secondaryColor,
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: _ReportHeroItem(
                  title: "صافي الربح",
                  value: "${_formatNumber(summary?.totalNetProfit)} ج",
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          _ProgressMetric(
            title: "نسبة اكتمال الطلبات",
            value: breakdown?.completionRate,
            color: Colors.green,
          ),
          SizedBox(height: AppConstants.height10(context)),
          _ProgressMetric(
            title: "نسبة إلغاء الطلبات",
            value: breakdown?.cancellationRate,
            color: Colors.red,
          ),
          SizedBox(height: AppConstants.height10(context)),
          _ProgressMetric(
            title: "نسبة الطلبات المسترجعة",
            value: _percentage(breakdown?.refundedOrders, totalOrders),
            color: Colors.grey,
          ),
          SizedBox(height: AppConstants.height10(context)),
          _ProgressMetric(
            title: "نسبة الطلبات المعلقة",
            value: _percentage(breakdown?.pendingOrders, totalOrders),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class SalesReportDetailsContent extends StatelessWidget {
  const SalesReportDetailsContent({super.key, required this.report});

  final SalesReportModel report;

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    final breakdown = report.breakdown;
    final insights = report.customerInsights;
    final products = report.topProducts ?? [];
    final totalOrders = summary?.totalOrders ?? 0;

    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSectionHeader(
            title: "تفاصيل تقارير المبيعات",
            subtitle: "كل مؤشرات الطلبات والمبيعات والعملاء",
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            children: [
              Expanded(
                child: _ReportHeroItem(
                  title: "إجمالي المبيعات",
                  value: "${_formatNumber(summary?.totalRevenue)} ج",
                  color: AppColors.primarySwatchColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Row(
            children: [
              Expanded(
                child: _ReportHeroItem(
                  title: "عدد الطلبات",
                  value: _formatNumber(summary?.totalOrders),
                  color: AppColors.secondaryColor,
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: _ReportHeroItem(
                  title: "صافي الربح",
                  value: "${_formatNumber(summary?.totalNetProfit)} ج",
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Wrap(
            spacing: AppConstants.width10(context),
            runSpacing: AppConstants.height10(context),
            children: [
              _SmallMetricChip(
                title: "متوسط الطلب",
                value: "${_formatNumber(summary?.averageOrderValue)} ج",
              ),
              _SmallMetricChip(
                title: "القطع المباعة",
                value: _formatNumber(summary?.totalItemsSold),
              ),
              _SmallMetricChip(
                title: "إجمالي الخصم",
                value: "${_formatNumber(summary?.totalDiscountGiven)} ج",
              ),
              _SmallMetricChip(
                title: "إيراد الشحن",
                value: "${_formatNumber(summary?.totalShippingRevenue)} ج",
              ),
              _SmallMetricChip(
                title: "طلبات مكتملة",
                value: _formatNumber(breakdown?.completedOrders),
              ),
              _SmallMetricChip(
                title: "طلبات معلقة",
                value: _formatNumber(breakdown?.pendingOrders),
              ),
              _SmallMetricChip(
                title: "طلبات ملغية",
                value: _formatNumber(breakdown?.cancelledOrders),
              ),
              _SmallMetricChip(
                title: "طلبات مسترجعة",
                value: _formatNumber(breakdown?.refundedOrders),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          _ProgressMetric(
            title: "نسبة اكتمال الطلبات",
            value: breakdown?.completionRate,
            color: Colors.green,
          ),
          SizedBox(height: AppConstants.height10(context)),
          _ProgressMetric(
            title: "نسبة إلغاء الطلبات",
            value: breakdown?.cancellationRate,
            color: Colors.red,
          ),
          SizedBox(height: AppConstants.height10(context)),
          _ProgressMetric(
            title: "نسبة الطلبات المسترجعة",
            value: _percentage(breakdown?.refundedOrders, totalOrders),
            color: Colors.grey,
          ),
          SizedBox(height: AppConstants.height10(context)),
          _ProgressMetric(
            title: "نسبة الطلبات المعلقة",
            value: _percentage(breakdown?.pendingOrders, totalOrders),
            color: Colors.orange,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Row(
            children: [
              Expanded(
                child: _InsightBox(
                  title: "عملاء مختلفين",
                  value: _formatNumber(insights?.uniqueCustomers),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: _InsightBox(
                  title: "عملاء متكررين",
                  value: _formatNumber(insights?.returningCustomers),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: _InsightBox(
                  title: "طلب/عميل",
                  value: _formatNumber(insights?.averageOrdersPerCustomer),
                ),
              ),
            ],
          ),
          if (products.isNotEmpty) ...[
            SizedBox(height: AppConstants.height20(context)),
            Text(
              "أفضل المنتجات في التقرير",
              style: Styles.inter14500black(context),
            ),
            SizedBox(height: AppConstants.height10(context)),
            ...products.map(
              (product) => _TopReportProductItem(product: product),
            ),
          ],
        ],
      ),
    );
  }
}

class LowStockProductsSection extends StatelessWidget {
  const LowStockProductsSection({
    super.key,
    required this.products,
    this.error,
  });

  final List<LowStockProductModel> products;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return const HomeFeatureErrorCard(
        title: "المخزون المنخفض",
        message: "تعذر تحميل المنتجات منخفضة المخزون حاليا",
      );
    }

    if (products.isEmpty) {
      return const HomeFeatureEmptyCard(
        title: "المخزون المنخفض",
        message: "كل المنتجات مخزونها جيد حاليا",
      );
    }

    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: "المخزون المنخفض",
            subtitle: "منتجات وصلت لحد منخفض وتحتاج متابعة",
            trailing: Row(
              children: [
                // Matches the limit GetHomeStatisticsCubit fetches for this preview.
                _CountBadge(
                  count: products.length,
                  isAtLeast: products.length >= 100,
                ),
                SizedBox(width: AppConstants.width10(context)),
                HomeViewAllButton(
                  onTap: () {
                    NavigationUtils.navigateTo(
                      context: context,
                      destinationScreen: const LowStockProductsView(),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
          ...products.take(2).map(
                (product) => LowStockProductListItem(product: product),
              ),
        ],
      ),
    );
  }
}

class InventoryAnalyticsSection extends StatelessWidget {
  const InventoryAnalyticsSection({
    super.key,
    required this.items,
    this.error,
  });

  final List<InventoryAnalyticsModel> items;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return const HomeFeatureErrorCard(
        title: "تحليل المخزون",
        message: "تعذر تحميل تحليل المخزون حاليا",
      );
    }

    final uniqueItems = <int, InventoryAnalyticsModel>{};
    for (final item in items) {
      if (item.id != null) uniqueItems[item.id!] = item;
    }
    final displayedItems = uniqueItems.values.toList()
      ..sort(
        (a, b) => (b.sellThroughRate ?? 0).compareTo(a.sellThroughRate ?? 0),
      );

    if (displayedItems.isEmpty) {
      return const HomeFeatureEmptyCard(
        title: "تحليل المخزون",
        message: "لا يوجد بيانات تحليل مخزون حاليا",
      );
    }

    return HomeAnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: "تحليل المخزون",
            subtitle: "تابع المتاح والمباع ونسبة دوران المنتج",
            trailing: HomeViewAllButton(
              onTap: () {
                NavigationUtils.navigateTo(
                  context: context,
                  destinationScreen: const InventoryAnalyticsView(),
                );
              },
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
          ...displayedItems.take(2).map(
                (item) => InventoryAnalyticsListItem(item: item),
              ),
        ],
      ),
    );
  }
}

class HomeAnalyticsCard extends StatelessWidget {
  const HomeAnalyticsCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp20(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Styles.inter16500black(context)),
              SizedBox(height: AppConstants.height5(context)),
              Text(subtitle, style: Styles.inter10400grey(context)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class HomeViewAllButton extends StatelessWidget {
  const HomeViewAllButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height10(context) / 1.5,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.shade50,
          borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
        ),
        child: Text(
          "عرض الكل",
          style: Styles.inter10400grey(context).copyWith(
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

class HomeFeatureErrorCard extends StatelessWidget {
  const HomeFeatureErrorCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return HomeAnalyticsCard(
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Styles.inter14500black(context)),
                SizedBox(height: AppConstants.height5(context)),
                Text(message, style: Styles.inter10400grey(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFeatureEmptyCard extends StatelessWidget {
  const HomeFeatureEmptyCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return HomeAnalyticsCard(
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: AppColors.primaryColor),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Styles.inter14500black(context)),
                SizedBox(height: AppConstants.height5(context)),
                Text(message, style: Styles.inter10400grey(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportHeroItem extends StatelessWidget {
  const _ReportHeroItem({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.inter10400grey(context)),
          SizedBox(height: AppConstants.height5(context)),
          Text(
            value,
            style: Styles.inter18500Black(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SmallMetricChip extends StatelessWidget {
  const _SmallMetricChip({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width15(context),
        vertical: AppConstants.height10(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.greyColor[50],
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.inter10400grey(context)),
          SizedBox(height: AppConstants.height5(context)),
          Text(value, style: Styles.inter14500black(context)),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final num? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = ((value ?? 0) / 100).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Styles.inter14500black(context)),
            ),
            Text(
              "${_formatNumber(value)}%",
              style: Styles.inter14500black(context).copyWith(color: color),
            ),
          ],
        ),
        SizedBox(height: AppConstants.height10(context)),
        LinearProgressIndicator(
          value: progress,
          minHeight: AppConstants.height10(context) - 2,
          color: color,
          backgroundColor: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
        ),
      ],
    );
  }
}

class _InsightBox extends StatelessWidget {
  const _InsightBox({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.shade50,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Styles.inter16500black(context)
                .copyWith(color: AppColors.primaryColor),
          ),
          SizedBox(height: AppConstants.height5(context)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Styles.inter10400grey(context),
          ),
        ],
      ),
    );
  }
}

class _TopReportProductItem extends StatelessWidget {
  const _TopReportProductItem({required this.product});

  final SalesReportTopProduct product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.height10(context)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor.shade50,
            child: Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primaryColor,
              size: AppConstants.sp20(context),
            ),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _safeName(product.name),
                  style: Styles.inter14500black(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "مباع ${_formatNumber(product.quantitySold)} مرة",
                  style: Styles.inter10400grey(context),
                ),
              ],
            ),
          ),
          Text(
            "${_formatNumber(product.revenue)} ج",
            style: Styles.inter14500black(context),
          ),
        ],
      ),
    );
  }
}

class LowStockProductListItem extends StatelessWidget {
  const LowStockProductListItem({super.key, required this.product});

  final LowStockProductModel product;

  @override
  Widget build(BuildContext context) {
    final stock = product.currentStock ?? 0;
    final isCritical = stock <= 1;
    final color = isCritical ? Colors.red : Colors.orange;

    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.height10(context)),
      child: Container(
        padding: EdgeInsets.all(AppConstants.sp10(context)),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: color.withOpacity(.20)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: Icon(Icons.warning_amber_rounded, color: color),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _safeName(product.name),
                    style: Styles.inter14500black(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppConstants.height5(context)),
                  Text(
                    "المباع: ${_formatNumber(product.sold)}",
                    style: Styles.inter10400grey(context),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width10(context),
                vertical: AppConstants.height5(context),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
              ),
              child: Text(
                "المتاح ${_formatNumber(stock)}",
                style: Styles.inter12500Black(context).copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryAnalyticsListItem extends StatelessWidget {
  const InventoryAnalyticsListItem({super.key, required this.item});

  final InventoryAnalyticsModel item;

  /// Sell-through rate is already computed by the API — this just maps
  /// that existing number onto a color scale so it reads at a glance.
  Color _rateColor(double rate) {
    if (rate >= 70) return const Color(0xFF1C9A6C); // fast-moving
    if (rate >= 30) return AppColors.primaryColor; // normal
    return Colors.orange.shade700; // slow-moving
  }

  @override
  Widget build(BuildContext context) {
    final rate = (item.sellThroughRate ?? 0).clamp(0, 100).toDouble();
    final rateColor = _rateColor(rate);

    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.height5(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppConstants.sp10(context)),
                decoration: BoxDecoration(
                  color: rateColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                ),
                child: Icon(Icons.inventory_2_outlined, color: rateColor, size: 20),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Text(
                  _safeName(item.name),
                  style: Styles.inter14500black(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Text(
                "${_formatNumber(item.currentPrice)} ج",
                style: Styles.inter12500Black(context).copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height15(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: AppConstants.height10(context) - 2,
              color: rateColor,
              backgroundColor: rateColor.withOpacity(.1),
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Wrap(
            spacing: AppConstants.width10(context),
            runSpacing: AppConstants.height5(context),
            children: [
              _InventoryStatChip(
                icon: Icons.widgets_outlined,
                label: "المتاح ${_formatNumber(item.currentStock)}",
              ),
              _InventoryStatChip(
                icon: Icons.shopping_bag_outlined,
                label: "مباع ${_formatNumber(item.totalSold)}",
              ),
              _InventoryStatChip(
                icon: Icons.trending_up_rounded,
                label: "دوران ${_formatNumber(item.sellThroughRate)}%",
                color: rateColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryStatChip extends StatelessWidget {
  const _InventoryStatChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.gray;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width10(context),
        vertical: AppConstants.height5(context),
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          SizedBox(width: AppConstants.width5(context) / 1.5),
          Text(
            label,
            style: Styles.inter10400grey(context).copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, this.isAtLeast = false});

  final int count;
  final bool isAtLeast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width10(context),
        vertical: AppConstants.height5(context),
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
      ),
      child: Text(
        isAtLeast ? "$count+ منتج" : "$count منتج",
        style: Styles.inter12500Black(context).copyWith(
          color: Colors.orange.shade800,
        ),
      ),
    );
  }
}

String _safeName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty || name == '.' || name == '٠') return "منتج بدون اسم";
  return name;
}

String _formatNumber(num? value) {
  if (value == null) return '0';
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

num _percentage(num? part, num? total) {
  if (part == null || total == null || total == 0) return 0;
  return (part / total) * 100;
}
