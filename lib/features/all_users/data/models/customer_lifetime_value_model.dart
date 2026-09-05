class CustomerLifetimeValueModel {
  num? totalOrders;
  num? totalSpent;
  num? averageOrderValue;
  num? totalUsedCoupons;
  num? totalCanceldOrders;
  String? firstOrderDate;
  String? lastOrderDate;

  CustomerLifetimeValueModel.fromJson(Map<String, dynamic> json) {
    totalOrders = json['totalOrders'];
    totalSpent = json['totalSpent'];
    averageOrderValue = json['averageOrderValue'];
    totalUsedCoupons = json['totalUsedCoupons'];
    totalCanceldOrders = json['totalCanceldOrders'];
    firstOrderDate = json['firstOrderDate'];
    lastOrderDate = json['lastOrderDate'];
  }
}
