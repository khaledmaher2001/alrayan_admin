/// `GET /delivery/accounts/{userId}/transactions` shape, confirmed from a
/// live response:
///
/// ```json
/// {
///   "id": 2, "createdAt": "...", "updatedAt": "...", "deletedAt": null,
///   "courierId": 601, "orderId": null, "type": "remittance",
///   "paymentMethod": null, "shippingAmount": null, "earningPercentage": null,
///   "earningAmount": null, "amountCollected": null,
///   "remittedAmount": "81.00", "balanceDelta": "-81.00", "balanceAfter": "0.00"
/// }
/// ```
///
/// All money/percentage fields come back as numeric **strings** (e.g.
/// `"81.00"`), not JSON numbers — parsed defensively via [_num]. Two `type`
/// values have been observed: `order_earning` (courier collected a COD
/// order — `earningAmount` is their cut, `balanceDelta` is the full amount
/// now owed to the store) and `remittance` (courier handed owed cash back
/// to the store — `balanceDelta` is negative).
class DeliveryTransactionsModel {
  bool? success;
  String? message;
  DeliveryTransactionsData? data;

  DeliveryTransactionsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? DeliveryTransactionsData.fromJson(json['data'])
        : null;
  }
}

class DeliveryTransactionsData {
  List<DeliveryTransaction>? items;
  DeliveryTransactionsMetadata? metadata;

  DeliveryTransactionsData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <DeliveryTransaction>[];
      json['items'].forEach((v) {
        items!.add(DeliveryTransaction.fromJson(v));
      });
    }
    metadata = json['metadata'] != null
        ? DeliveryTransactionsMetadata.fromJson(json['metadata'])
        : null;
  }
}

class DeliveryTransactionsMetadata {
  int? totalItems;
  int? itemsPerPage;
  int? totalPages;
  int? currentPage;

  DeliveryTransactionsMetadata.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    itemsPerPage = json['itemsPerPage'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }
}

class DeliveryTransaction {
  int? id;
  String? type;
  String? createdAt;
  String? updatedAt;
  String? description;
  String? paymentMethod;
  int? orderId;

  /// Only set if the server ever nests an order object or sends a separate
  /// human-readable order number — the confirmed live response only sends
  /// the numeric `orderId`, so the UI should be ready to fall back to
  /// `#$orderId` when this is null.
  String? orderNumber;

  /// قيمة التوصيل الخاصة بالطلب المرتبط بهذه العملية.
  num? shippingAmount;

  /// نسبة أرباح المندوب من هذا الطلب.
  num? earningPercentage;

  /// صافي ربح المندوب من هذا الطلب (جزء من `amountCollected`).
  num? earningAmount;

  /// المبلغ الذي حصّله المندوب من العميل (كاش عند الاستلام مثلًا).
  num? amountCollected;

  /// المبلغ الذي سلّمه المندوب للمحل في عملية تسليم.
  num? remittedAmount;

  /// التغيّر الموقّع (بالإشارة) في رصيد محفظة المندوب نتيجة هذه العملية.
  num? balanceDelta;

  /// رصيد المحفظة بعد تنفيذ العملية.
  num? balanceAfter;

  /// Full raw JSON for this transaction, used to render any extra field the
  /// server actually returns beyond what's recognized above.
  final Map<String, dynamic> raw;

  DeliveryTransaction.fromJson(Map<String, dynamic> json) : raw = json {
    id = json['id'];
    type = json['type'] is String ? json['type'] : null;
    createdAt = json['createdAt'] ?? json['date'];
    updatedAt = json['updatedAt'] is String ? json['updatedAt'] : null;
    description = json['description'] ?? json['notes'] ?? json['note'];
    paymentMethod = json['paymentMethod'] is String
        ? json['paymentMethod']
        : null;

    orderId = json['orderId'] is int ? json['orderId'] : null;
    final order = json['order'];
    if (order is Map<String, dynamic>) {
      orderId ??= order['id'];
      orderNumber = order['orderNumber'];
    }
    orderNumber ??= json['orderNumber'];

    shippingAmount = _num(json, [
      'shippingAmount',
      'deliveryValue',
      'deliveryFee',
      'shippingFee',
    ]);
    earningPercentage = _num(json, [
      'earningPercentage',
      'profitPercentage',
      'commissionPercentage',
    ]);
    earningAmount = _num(json, ['earningAmount']);
    amountCollected = _num(json, [
      'amountCollected',
      'collectedAmount',
      'totalCollected',
    ]);
    remittedAmount = _num(json, ['remittedAmount']);
    balanceDelta = _num(json, ['balanceDelta', 'amount', 'value']);
    balanceAfter = _num(json, ['balanceAfter', 'runningBalance', 'balance']);
  }

  /// Signed headline figure shown on the transaction card. For
  /// `order_earning`, the wallet-affecting [balanceDelta] is the *full* COD
  /// amount now owed to the store (e.g. 81.00) — not what the courier
  /// actually keeps, so the headline shows their own cut, [earningAmount]
  /// (e.g. 12.00), instead. Every other type shows its wallet delta as-is.
  num get amount {
    if (type == 'order_earning' && earningAmount != null) {
      return earningAmount!;
    }
    return balanceDelta ?? 0;
  }
}

num? _num(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}
