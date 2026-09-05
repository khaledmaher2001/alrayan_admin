/// `GET /delivery/statistics` — admin-facing overview of the whole delivery
/// operation. The endpoint also returns a `couriers` list (same shape as
/// `GET /delivery/accounts`), but this model only parses `overview`: that's
/// the part shown on the delivery management home screen, and the couriers
/// list is already covered by the dedicated couriers screen/model
/// ([DeliveryAccountsModel]).
class DeliveryStatisticsModel {
  bool? success;
  String? message;
  DeliveryStatisticsOverview? overview;

  DeliveryStatisticsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    final data = json['data'];
    if (data is Map<String, dynamic> && data['overview'] is Map<String, dynamic>) {
      overview = DeliveryStatisticsOverview.fromJson(data['overview']);
    }
  }
}

class DeliveryStatisticsOverview {
  int? totalCouriers;
  int? activeCouriers;
  int? totalDeliveredOrders;
  num? totalOwedToStore;
  num? totalEarnings;
  num? totalGrossCollected;
  num? totalRemitted;
  PendingRemittances? pendingRemittances;
  ThisMonthStats? thisMonth;

  DeliveryStatisticsOverview.fromJson(Map<String, dynamic> json) {
    totalCouriers = json['totalCouriers'];
    activeCouriers = json['activeCouriers'];
    totalDeliveredOrders = json['totalDeliveredOrders'];
    totalOwedToStore = _parseNum(json['totalOwedToStore']);
    totalEarnings = _parseNum(json['totalEarnings']);
    totalGrossCollected = _parseNum(json['totalGrossCollected']);
    totalRemitted = _parseNum(json['totalRemitted']);
    pendingRemittances = json['pendingRemittances'] is Map<String, dynamic>
        ? PendingRemittances.fromJson(json['pendingRemittances'])
        : null;
    thisMonth = json['thisMonth'] is Map<String, dynamic>
        ? ThisMonthStats.fromJson(json['thisMonth'])
        : null;
  }
}

class PendingRemittances {
  int? count;
  num? amount;

  PendingRemittances.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    amount = _parseNum(json['amount']);
  }
}

class ThisMonthStats {
  num? earnings;
  num? grossCollected;
  num? remitted;

  ThisMonthStats.fromJson(Map<String, dynamic> json) {
    earnings = _parseNum(json['earnings']);
    grossCollected = _parseNum(json['grossCollected']);
    remitted = _parseNum(json['remitted']);
  }
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
