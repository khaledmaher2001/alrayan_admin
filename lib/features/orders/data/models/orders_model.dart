class OrdersModel {
  bool? success;
  String? message;
  Data? data;

  OrdersModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  List<Items>? items;
  Metadata? metadata;

  Data.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    metadata = json['metadata'] != null
        ? Metadata.fromJson(json['metadata'])
        : null;
  }
}

class Items {
  int? id;
  String? orderNumber;
  String? status;
  String? paymentStatus;
  String? paymentMethod;
  dynamic subtotal;
  dynamic discountAmount;
  dynamic shippingAmount;
  dynamic totalAmount;
  // Money actually received / given back (server records, 2026-10-09).
  dynamic amountCollected;
  dynamic amountRefunded;
  ShippingAddress? shippingAddress;
  List<OrderItems>? orderItems;
  String? notes;
  String? cancellationReason;
  String? shippedAt;
  String? deliveredAt;
  String? createdAt;
  String? updatedAt;
  List<String>? availableTransitions;
  bool? canCancel;
  String? statusDescription;
  dynamic review;
  OrderDeliveryUser? deliveryUser;
  String? deliveryStage;
  String? deliveryProofImage;
  bool? isClaimable;
  dynamic pointsRedeemed;
  dynamic pointsDiscountAmount;
  dynamic pointsEarned;

  /// Release / "awaiting customer" context. `GET /orders?status=awaiting_customer`
  /// has no documented schema for these, so every field below is parsed
  /// defensively from whatever the server actually sends (top-level keys or a
  /// nested `releaseLog`/`lastReleaseLog`/`release` object) and stays null
  /// when absent — the UI shows "غير متاح" rather than guessing, and the
  /// exact field names are listed as a backend-confirmation item.
  String? releaseType;
  String? releaseReason;
  String? releasedAt;
  String? releasedByName;
  String? previousCourierName;
  String? previousCourierPhone;

  Items.fromJson(Map<String, dynamic> json) {
    amountCollected = json['amountCollected'];
    amountRefunded = json['amountRefunded'];
    id = json['id'];
    orderNumber = json['orderNumber'];
    status = json['status'];
    paymentStatus = json['paymentStatus'];
    paymentMethod = json['paymentMethod'];
    subtotal = json['subtotal'];
    discountAmount = json['discountAmount'];
    shippingAmount = json['shippingAmount'];
    totalAmount = json['totalAmount'];

    shippingAddress = json['shippingAddress'] != null
        ? ShippingAddress.fromJson(json['shippingAddress'])
        : null;

    if (json['orderItems'] != null) {
      orderItems = <OrderItems>[];
      json['orderItems'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }

    notes = json['notes'];
    cancellationReason = json['cancellationReason'];
    shippedAt = json['shippedAt'];
    deliveredAt = json['deliveredAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];

    availableTransitions = json['availableTransitions'] != null
        ? List<String>.from(json['availableTransitions'])
        : [];

    canCancel = json['canCancel'];
    statusDescription = json['statusDescription'];
    review = json['review'];

    deliveryUser = json['deliveryUser'] != null
        ? OrderDeliveryUser.fromJson(json['deliveryUser'])
        : null;
    deliveryStage = json['deliveryStage'];
    deliveryProofImage = json['deliveryProofImage'];
    isClaimable = json['isClaimable'];
    pointsRedeemed = json['pointsRedeemed'];
    pointsDiscountAmount = json['pointsDiscountAmount'];
    pointsEarned = json['pointsEarned'];

    _parseReleaseInfo(json);
  }

  void _parseReleaseInfo(Map<String, dynamic> json) {
    // Prefer a nested release-log object if the server embeds one; otherwise
    // read the same fields off the order root.
    Map<String, dynamic>? release;
    for (final key in const [
      'releaseLog',
      'lastReleaseLog',
      'latestReleaseLog',
      'release',
    ]) {
      final value = json[key];
      if (value is Map<String, dynamic>) {
        release = value;
        break;
      }
    }
    final source = release ?? json;

    releaseType = _firstString(source, const [
      'releaseType',
      'release_type',
      'type',
    ]);
    releaseReason = _firstString(source, const [
      'releaseReason',
      'release_reason',
      'reason',
      'deliveryFailureReason',
      'failureReason',
    ]);
    releasedAt = _firstString(source, const [
      'releasedAt',
      'released_at',
      'releaseAt',
      'createdAt',
    ], skip: release == null ? const {'createdAt'} : const <String>{});

    final courier =
        source['courier'] ??
        source['previousCourier'] ??
        source['previousDeliveryUser'] ??
        json['previousDeliveryUser'];
    if (courier is Map<String, dynamic>) {
      previousCourierName = courier['fullName'] ?? courier['name'];
      previousCourierPhone = courier['phoneNumber'] ?? courier['phone'];
    }
    previousCourierName ??= _firstString(source, const [
      'courierName',
      'previousCourierName',
      'releasedByCourierName',
    ]);
    previousCourierPhone ??= _firstString(source, const [
      'courierPhone',
      'previousCourierPhone',
    ]);

    final actor = source['performedBy'] ?? source['actor'] ?? source['admin'];
    if (actor is Map<String, dynamic>) {
      releasedByName = actor['fullName'] ?? actor['name'];
    }
    releasedByName ??= _firstString(source, const [
      'performedByName',
      'releasedByName',
      'actorName',
    ]);
  }

  static String? _firstString(
    Map<String, dynamic> json,
    List<String> keys, {
    Set<String> skip = const {},
  }) {
    for (final key in keys) {
      if (skip.contains(key)) continue;
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}

class OrderDeliveryUser {
  int? id;
  String? fullName;
  String? phoneNumber;

  OrderDeliveryUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
  }
}

class ShippingAddress {
  String? phone1;
  String? phone2;
  String? title;
  String? description;
  String? latitude;
  String? longitude;
  User? user;

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    phone1 = json['phone1'];
    phone2 = json['phone2'];
    title = json['title'];
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}

class User {
  int? id;
  String? fullName;
  String? email;
  String? phoneNumber;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
  }
}

class OrderItems {
  int? id;
  int? productId;
  String? productName;
  List<String>? productImages;
  int? quantity;
  dynamic unitPrice;
  dynamic discount;
  dynamic totalPrice;
  String? unit;
  int? returnedQuantity;
  // Shelf grouping sent by the server (items already arrive sorted by it).
  ShelfCategory? mainCategory;
  ShelfCategory? subCategory;

  OrderItems.fromJson(Map<String, dynamic> json) {
    returnedQuantity = json['returnedQuantity'];
    mainCategory = json['mainCategory'] is Map ? ShelfCategory.fromJson(Map<String, dynamic>.from(json['mainCategory'])) : null;
    subCategory = json['subCategory'] is Map ? ShelfCategory.fromJson(Map<String, dynamic>.from(json['subCategory'])) : null;
    id = json['id'];
    productId = json['productId'];
    productName = json['productName'];

    productImages = json['productImages'] != null
        ? List<String>.from(json['productImages'])
        : [];

    quantity = json['quantity'];
    unitPrice = json['unitPrice'];
    discount = json['discount'];
    totalPrice = json['totalPrice'];
    unit = json['unit'];
  }
}

class ShelfCategory {
  int? id;
  String? name;
  String? nameEn;

  ShelfCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameEn = json['nameEn'];
  }

  String label(String languageCode) {
    final en = (nameEn ?? '').isNotEmpty ? nameEn! : (name ?? '');
    final ar = (name ?? '').isNotEmpty ? name! : (nameEn ?? '');
    return languageCode == 'en' ? en : ar;
  }
}

class Metadata {
  int? totalItems;
  int? itemsPerPage;
  int? totalPages;
  int? currentPage;

  Metadata.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    itemsPerPage = json['itemsPerPage'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }
}
