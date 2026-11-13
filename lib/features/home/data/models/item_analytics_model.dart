class ItemAnalyticsModel {
  ItemAnalyticsProduct? product;
  ItemAnalyticsPeriod? period;
  ItemAnalyticsSummary? summary;
  ItemAnalyticsComparison? comparison;
  List<ItemAnalyticsBucket> buckets;

  ItemAnalyticsModel({
    this.product,
    this.period,
    this.summary,
    this.comparison,
    List<ItemAnalyticsBucket>? buckets,
  }) : buckets = buckets ?? [];

  factory ItemAnalyticsModel.fromJson(Map<String, dynamic> json) {
    // The API returns the time series under `buckets`; older/alternate shapes
    // used `breakdown`/`data`/`series`, so keep those as fallbacks.
    final rawBuckets =
        json['buckets'] ?? json['breakdown'] ?? json['data'] ?? json['series'];
    return ItemAnalyticsModel(
      product: _asMap(json['product']) == null
          ? null
          : ItemAnalyticsProduct.fromJson(_asMap(json['product'])!),
      period: _asMap(json['period']) == null
          ? null
          : ItemAnalyticsPeriod.fromJson(_asMap(json['period'])!),
      summary: _asMap(json['summary']) == null
          ? null
          : ItemAnalyticsSummary.fromJson(_asMap(json['summary'])!),
      comparison: _asMap(json['comparison']) == null
          ? null
          : ItemAnalyticsComparison.fromJson(_asMap(json['comparison'])!),
      buckets: rawBuckets is List
          ? rawBuckets
              .whereType<Map>()
              .map((entry) => ItemAnalyticsBucket.fromJson(
                    Map<String, dynamic>.from(entry),
                  ))
              .toList()
          : [],
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }
}

class ItemAnalyticsProduct {
  int? id;
  String? name;
  num? currentPrice;
  num? supplierPrice;
  num? currentStock;
  num? totalSold;
  num? sellThroughRate;

  ItemAnalyticsProduct({
    this.id,
    this.name,
    this.currentPrice,
    this.supplierPrice,
    this.currentStock,
    this.totalSold,
    this.sellThroughRate,
  });

  factory ItemAnalyticsProduct.fromJson(Map<String, dynamic> json) {
    return ItemAnalyticsProduct(
      id: json['id'],
      name: json['name'],
      currentPrice: json['currentPrice'] ?? json['price'],
      supplierPrice: json['supplierPrice'],
      currentStock: json['currentStock'] ?? json['stock'],
      totalSold: json['totalSold'],
      sellThroughRate: json['sellThroughRate'],
    );
  }
}

class ItemAnalyticsPeriod {
  String? groupBy;
  String? startDate;
  String? endDate;

  ItemAnalyticsPeriod({this.groupBy, this.startDate, this.endDate});

  factory ItemAnalyticsPeriod.fromJson(Map<String, dynamic> json) {
    return ItemAnalyticsPeriod(
      groupBy: json['groupBy']?.toString(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
    );
  }
}

class ItemAnalyticsSummary {
  num? totalQuantitySold;
  num? totalRevenue;
  num? totalProfit;
  num? profitMargin;
  num? totalOrders;
  num? uniqueCustomers;
  num? averageSellingPrice;

  ItemAnalyticsSummary({
    this.totalQuantitySold,
    this.totalRevenue,
    this.totalProfit,
    this.profitMargin,
    this.totalOrders,
    this.uniqueCustomers,
    this.averageSellingPrice,
  });

  factory ItemAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return ItemAnalyticsSummary(
      totalQuantitySold: json['totalQuantitySold'] ??
          json['quantitySold'] ??
          json['totalSold'],
      totalRevenue: json['totalRevenue'] ?? json['revenue'],
      totalProfit: json['totalProfit'] ?? json['profit'] ?? json['netProfit'],
      profitMargin: json['profitMargin'],
      totalOrders: json['totalOrders'],
      uniqueCustomers: json['uniqueCustomers'],
      averageSellingPrice:
          json['averageSellingPrice'] ?? json['averagePrice'],
    );
  }
}

class ItemAnalyticsComparison {
  String? previousStartDate;
  String? previousEndDate;
  num? quantityChangePercent;
  num? revenueChangePercent;

  ItemAnalyticsComparison({
    this.previousStartDate,
    this.previousEndDate,
    this.quantityChangePercent,
    this.revenueChangePercent,
  });

  factory ItemAnalyticsComparison.fromJson(Map<String, dynamic> json) {
    final previous = json['previousPeriod'] is Map
        ? Map<String, dynamic>.from(json['previousPeriod'])
        : const <String, dynamic>{};
    return ItemAnalyticsComparison(
      previousStartDate: previous['startDate']?.toString(),
      previousEndDate: previous['endDate']?.toString(),
      quantityChangePercent:
          json['quantityChangePercent'] ?? json['quantityChange'],
      revenueChangePercent:
          json['revenueChangePercent'] ?? json['revenueChange'],
    );
  }
}

class ItemAnalyticsBucket {
  String? bucket;
  num? quantity;
  num? revenue;
  num? profit;
  num? orders;
  num? uniqueCustomers;

  ItemAnalyticsBucket({
    this.bucket,
    this.quantity,
    this.revenue,
    this.profit,
    this.orders,
    this.uniqueCustomers,
  });

  factory ItemAnalyticsBucket.fromJson(Map<String, dynamic> json) {
    return ItemAnalyticsBucket(
      bucket: (json['bucket'] ?? json['period'] ?? json['date'] ?? json['label'])
          ?.toString(),
      quantity: json['quantity'] ?? json['quantitySold'] ?? json['sold'],
      revenue: json['revenue'],
      profit: json['profit'],
      orders: json['orders'],
      uniqueCustomers: json['uniqueCustomers'],
    );
  }
}
