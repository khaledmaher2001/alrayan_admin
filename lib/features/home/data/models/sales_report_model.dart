class SalesReportModel {
  SalesReportPeriod? period;
  SalesReportSummary? summary;
  SalesReportBreakdown? breakdown;
  List<SalesReportTopProduct>? topProducts;
  CustomerInsights? customerInsights;

  SalesReportModel({
    this.period,
    this.summary,
    this.breakdown,
    this.topProducts,
    this.customerInsights,
  });

  SalesReportModel.fromJson(Map<String, dynamic> json) {
    period = json['period'] != null
        ? SalesReportPeriod.fromJson(json['period'])
        : null;
    summary = json['summary'] != null
        ? SalesReportSummary.fromJson(json['summary'])
        : null;
    breakdown = json['breakdown'] != null
        ? SalesReportBreakdown.fromJson(json['breakdown'])
        : null;
    if (json['topProducts'] != null) {
      topProducts = <SalesReportTopProduct>[];
      json['topProducts'].forEach((v) {
        topProducts!.add(SalesReportTopProduct.fromJson(v));
      });
    }
    customerInsights = json['customerInsights'] != null
        ? CustomerInsights.fromJson(json['customerInsights'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (period != null) data['period'] = period!.toJson();
    if (summary != null) data['summary'] = summary!.toJson();
    if (breakdown != null) data['breakdown'] = breakdown!.toJson();
    if (topProducts != null) {
      data['topProducts'] = topProducts!.map((v) => v.toJson()).toList();
    }
    if (customerInsights != null) {
      data['customerInsights'] = customerInsights!.toJson();
    }
    return data;
  }
}

class SalesReportPeriod {
  String? startDate;
  String? endDate;
  String? type;

  SalesReportPeriod({this.startDate, this.endDate, this.type});

  SalesReportPeriod.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'];
    endDate = json['endDate'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'type': type,
    };
  }
}

class SalesReportSummary {
  num? totalRevenue;
  num? totalOrders;
  num? averageOrderValue;
  num? totalItemsSold;
  num? totalDiscountGiven;
  num? totalShippingRevenue;
  num? totalNetProfit;

  SalesReportSummary({
    this.totalRevenue,
    this.totalOrders,
    this.averageOrderValue,
    this.totalItemsSold,
    this.totalDiscountGiven,
    this.totalShippingRevenue,
    this.totalNetProfit,
  });

  SalesReportSummary.fromJson(Map<String, dynamic> json) {
    totalRevenue = json['totalRevenue'];
    totalOrders = json['totalOrders'];
    averageOrderValue = json['averageOrderValue'];
    totalItemsSold = json['totalItemsSold'];
    totalDiscountGiven = json['totalDiscountGiven'];
    totalShippingRevenue = json['totalShippingRevenue'];
    totalNetProfit = json['totalNetProfit'];
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'averageOrderValue': averageOrderValue,
      'totalItemsSold': totalItemsSold,
      'totalDiscountGiven': totalDiscountGiven,
      'totalShippingRevenue': totalShippingRevenue,
      'totalNetProfit': totalNetProfit,
    };
  }
}

class SalesReportBreakdown {
  num? completedOrders;
  num? pendingOrders;
  num? cancelledOrders;
  num? refundedOrders;
  num? completionRate;
  num? cancellationRate;

  SalesReportBreakdown({
    this.completedOrders,
    this.pendingOrders,
    this.cancelledOrders,
    this.refundedOrders,
    this.completionRate,
    this.cancellationRate,
  });

  SalesReportBreakdown.fromJson(Map<String, dynamic> json) {
    completedOrders = json['completedOrders'];
    pendingOrders = json['pendingOrders'];
    cancelledOrders = json['cancelledOrders'];
    refundedOrders = json['refundedOrders'];
    completionRate = json['completionRate'];
    cancellationRate = json['cancellationRate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'completedOrders': completedOrders,
      'pendingOrders': pendingOrders,
      'cancelledOrders': cancelledOrders,
      'refundedOrders': refundedOrders,
      'completionRate': completionRate,
      'cancellationRate': cancellationRate,
    };
  }
}

class SalesReportTopProduct {
  int? id;
  String? name;
  num? quantitySold;
  num? revenue;
  num? averagePrice;

  SalesReportTopProduct({
    this.id,
    this.name,
    this.quantitySold,
    this.revenue,
    this.averagePrice,
  });

  SalesReportTopProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    quantitySold = json['quantitySold'];
    revenue = json['revenue'];
    averagePrice = json['averagePrice'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantitySold': quantitySold,
      'revenue': revenue,
      'averagePrice': averagePrice,
    };
  }
}

class CustomerInsights {
  num? uniqueCustomers;
  num? returningCustomers;
  num? averageOrdersPerCustomer;

  CustomerInsights({
    this.uniqueCustomers,
    this.returningCustomers,
    this.averageOrdersPerCustomer,
  });

  CustomerInsights.fromJson(Map<String, dynamic> json) {
    uniqueCustomers = json['uniqueCustomers'];
    returningCustomers = json['returningCustomers'];
    averageOrdersPerCustomer = json['averageOrdersPerCustomer'];
  }

  Map<String, dynamic> toJson() {
    return {
      'uniqueCustomers': uniqueCustomers,
      'returningCustomers': returningCustomers,
      'averageOrdersPerCustomer': averageOrdersPerCustomer,
    };
  }
}
