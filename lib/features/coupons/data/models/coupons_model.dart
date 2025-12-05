class CouponsModel {
  bool? success;
  String? message;
  Data? data;

  CouponsModel({this.success, this.message, this.data});

  CouponsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Items>? items;
  Metadata? metadata;
  Links? links;

  Data({this.items, this.metadata, this.links});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
    links = json['links'] != null ? new Links.fromJson(json['links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    if (this.links != null) {
      data['links'] = this.links!.toJson();
    }
    return data;
  }
}

class Items {
  int? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? code;
  Name? name;
  Name? description;
  String? discountType;
  int? discountValue;
  int? splitValue;
  int? maxDiscountAmount;
  int? minOrderAmount;
  String? status;
  String? validFrom;
  String? validTo;
  int? usageLimit;
  int? usedCount;
  int? usageLimitPerUser;
  List<int>? applicableCategories;
  List<int>? applicableVendors;
  List<int>? applicableProducts;
  List<int>? excludedCategories;
  List<int>? excludedProducts;
  List<int>? applicableUserGroups;
  bool? isStackable;
  int? createdBy;

  Items(
      {this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.code,
        this.name,
        this.description,
        this.discountType,
        this.discountValue,
        this.splitValue,
        this.maxDiscountAmount,
        this.minOrderAmount,
        this.status,
        this.validFrom,
        this.validTo,
        this.usageLimit,
        this.usedCount,
        this.usageLimitPerUser,
        this.applicableCategories,
        this.applicableVendors,
        this.applicableProducts,
        this.excludedCategories,
        this.excludedProducts,
        this.applicableUserGroups,
        this.isStackable,
        this.createdBy});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    code = json['code'];

    // name/description may be null or an object
    name = json['name'] != null && json['name'] is Map
        ? Name.fromJson(Map<String, dynamic>.from(json['name']))
        : null;
    description = json['description'] != null && json['description'] is Map
        ? Name.fromJson(Map<String, dynamic>.from(json['description']))
        : null;

    discountType = json['discountType'];
    discountValue = json['discountValue'] is int
        ? json['discountValue']
        : (json['discountValue'] != null ? int.tryParse(json['discountValue'].toString()) : null);
    splitValue = json['splitValue'] is int
        ? json['splitValue']
        : (json['splitValue'] != null ? int.tryParse(json['splitValue'].toString()) : null);
    maxDiscountAmount = json['maxDiscountAmount'] is int
        ? json['maxDiscountAmount']
        : (json['maxDiscountAmount'] != null ? int.tryParse(json['maxDiscountAmount'].toString()) : null);
    minOrderAmount = json['minOrderAmount'] is int
        ? json['minOrderAmount']
        : (json['minOrderAmount'] != null ? int.tryParse(json['minOrderAmount'].toString()) : null);

    status = json['status'];
    validFrom = json['validFrom'];
    validTo = json['validTo'];
    usageLimit = json['usageLimit'] is int ? json['usageLimit'] : (json['usageLimit'] != null ? int.tryParse(json['usageLimit'].toString()) : null);
    usedCount = json['usedCount'] is int ? json['usedCount'] : (json['usedCount'] != null ? int.tryParse(json['usedCount'].toString()) : null);
    usageLimitPerUser = json['usageLimitPerUser'] is int ? json['usageLimitPerUser'] : (json['usageLimitPerUser'] != null ? int.tryParse(json['usageLimitPerUser'].toString()) : null);

    // Safe parsing for lists that might be null or empty
    applicableCategories = (json['applicableCategories'] as List<dynamic>?)?.map((e) => e == null ? 0 : (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? <int>[];
    applicableVendors = (json['applicableVendors'] as List<dynamic>?)?.map((e) => e == null ? 0 : (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? <int>[];
    applicableProducts = (json['applicableProducts'] as List<dynamic>?)?.map((e) => e == null ? 0 : (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? <int>[];

    excludedCategories = (json['excludedCategories'] as List<dynamic>?)?.map((e) => e == null ? 0 : (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? <int>[];
    excludedProducts = (json['excludedProducts'] as List<dynamic>?)?.map((e) => e == null ? 0 : (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? <int>[];

    applicableUserGroups = (json['applicableUserGroups'] as List<dynamic>?)?.map((e) => e == null ? 0 : (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? <int>[];

    isStackable = json['isStackable'];
    createdBy = json['createdBy'] is int ? json['createdBy'] : (json['createdBy'] != null ? int.tryParse(json['createdBy'].toString()) : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    data['code'] = this.code;
    if (this.name != null) {
      data['name'] = this.name!.toJson();
    }
    if (this.description != null) {
      data['description'] = this.description!.toJson();
    }
    data['discountType'] = this.discountType;
    data['discountValue'] = this.discountValue;
    data['splitValue'] = this.splitValue;
    data['maxDiscountAmount'] = this.maxDiscountAmount;
    data['minOrderAmount'] = this.minOrderAmount;
    data['status'] = this.status;
    data['validFrom'] = this.validFrom;
    data['validTo'] = this.validTo;
    data['usageLimit'] = this.usageLimit;
    data['usedCount'] = this.usedCount;
    data['usageLimitPerUser'] = this.usageLimitPerUser;
    data['applicableCategories'] = this.applicableCategories;
    data['applicableVendors'] = this.applicableVendors;
    data['applicableProducts'] = this.applicableProducts;
    data['excludedCategories'] = this.excludedCategories;
    data['excludedProducts'] = this.excludedProducts;
    data['applicableUserGroups'] = this.applicableUserGroups;
    data['isStackable'] = this.isStackable;
    data['createdBy'] = this.createdBy;
    return data;
  }
}


class Name {
  String? ar;
  String? en;

  Name({this.ar, this.en});

  Name.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ar'] = this.ar;
    data['en'] = this.en;
    return data;
  }
}

class Metadata {
  int? totalItems;
  int? itemsPerPage;
  int? totalPages;
  int? currentPage;

  Metadata(
      {this.totalItems, this.itemsPerPage, this.totalPages, this.currentPage});

  Metadata.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    itemsPerPage = json['itemsPerPage'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalItems'] = this.totalItems;
    data['itemsPerPage'] = this.itemsPerPage;
    data['totalPages'] = this.totalPages;
    data['currentPage'] = this.currentPage;
    return data;
  }
}

class Links {
  bool? hasNext;

  Links({this.hasNext});

  Links.fromJson(Map<String, dynamic> json) {
    hasNext = json['hasNext'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasNext'] = this.hasNext;
    return data;
  }
}