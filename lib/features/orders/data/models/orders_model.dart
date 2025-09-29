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
    metadata = json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
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
  ShippingAddress? shippingAddress;
  List<OrderItems>? orderItems;
  String? notes;
  String? shippedAt;
  String? deliveredAt;
  String? createdAt;
  String? updatedAt;
  List<String>? availableTransitions;
  bool? canCancel;
  String? statusDescription;

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['orderNumber'];
    status = json['status'];
    paymentStatus = json['paymentStatus'];
    paymentMethod = json['paymentMethod'];
    subtotal = json['subtotal'];
    discountAmount = json['discountAmount'];
    shippingAmount = json['shippingAmount'];
    totalAmount = json['totalAmount'];
    shippingAddress = json['shippingAddress'] != null ? ShippingAddress.fromJson(json['shippingAddress']) : null;
    if (json['orderItems'] != null) {
      orderItems = <OrderItems>[];
      json['orderItems'].forEach((v) {
        orderItems!.add(OrderItems.fromJson(v));
      });
    }
    notes = json['notes'];
    shippedAt = json['shippedAt'];
    deliveredAt = json['deliveredAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    availableTransitions = json['availableTransitions'].cast<String>();
    canCancel = json['canCancel'];
    statusDescription = json['statusDescription'];
  }
}

class ShippingAddress {
  String? phone1;
  String? phone2;
  String? title;
  String? description;
  String? latitude;
  String? longitude;

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    phone1 = json['phone1'];
    phone2 = json['phone2'];
    title = json['title'];
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
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

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    productName = json['productName'];
    productImages = json['productImages'].cast<String>();
    quantity = json['quantity'];
    unitPrice = json['unitPrice'];
    discount = json['discount'];
    totalPrice = json['totalPrice'];
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
