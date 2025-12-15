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
  Description? name; // <- changed from String? to Description?
  String? currency;
  Description? description;
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
  bool? isStackable;
  int? createdBy;
  bool? isSplitCoupon;
  int? totalSplits;
  List<Products>? products;
  List<Categories>? categories;

  Items(
      {this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.code,
        this.name,
        this.currency,
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
        this.isStackable,
        this.createdBy,
        this.totalSplits,
        this.isSplitCoupon,
        this.products,
        this.categories});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    code = json['code'];
    currency = json['currency'];

    // robust parsing for `name` which may be String, Map, empty map or null
    if (json['name'] == null) {
      name = null;
    } else if (json['name'] is String) {
      // if the API sometimes returns simple string, store it in `en`
      name = Description(en: json['name'] as String);
    } else if (json['name'] is Map) {
      // normal object with ar/en
      name = Description.fromJson(Map<String, dynamic>.from(json['name']));
    } else {
      name = null;
    }

    // robust parsing for `description` as well
    if (json['description'] == null) {
      description = null;
    } else if (json['description'] is String) {
      description = Description(en: json['description'] as String);
    } else if (json['description'] is Map) {
      description =
          Description.fromJson(Map<String, dynamic>.from(json['description']));
    } else {
      description = null;
    }

    discountType = json['discountType'];
    discountValue = json['discountValue'];
    splitValue = json['splitValue'];
    maxDiscountAmount = json['maxDiscountAmount'];
    minOrderAmount = json['minOrderAmount'];
    status = json['status'];
    validFrom = json['validFrom'];
    validTo = json['validTo'];
    usageLimit = json['usageLimit'];
    usedCount = json['usedCount'];
    usageLimitPerUser = json['usageLimitPerUser'];
    isStackable = json['isStackable'];
    createdBy = json['createdBy'];
    totalSplits = json['totalSplits'];
    isSplitCoupon = json['isSplitCoupon'];
    if (json['products'] != null && json['products'] is List) {
      products = <Products>[];
      (json['products'] as List).forEach((v) {
        if (v is Map) products!.add(Products.fromJson(Map<String, dynamic>.from(v)));
      });
    }

    if (json['categories'] != null && json['categories'] is List) {
      categories = <Categories>[];
      (json['categories'] as List).forEach((v) {
        if (v is Map) categories!.add(Categories.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    data['code'] = this.code;
    data['currency'] = this.currency;
    if (this.name != null) {
      data['name'] = this.name!.toJson();
    } else {
      data['name'] = null;
    }
    if (this.description != null) {
      data['description'] = this.description!.toJson();
    } else {
      data['description'] = null;
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
    data['isStackable'] = this.isStackable;
    data['createdBy'] = this.createdBy;
    data['totalSplits'] = this.totalSplits;
    data['isSplitCoupon'] = this.isSplitCoupon;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Description {
  String? ar;
  String? en;

  Description({this.ar, this.en});

  Description.fromJson(Map<String, dynamic> json) {
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

class Products {
  int? id;
  String? name;
  int? price;
  List<Images>? images;

  Products({this.id, this.name, this.price, this.images});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  int? id;
  String? attach;

  Images({this.id, this.attach});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    attach = json['attach'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['attach'] = this.attach;
    return data;
  }
}

class Categories {
  int? id;
  String? name;

  Categories({this.id, this.name});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
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