class ProductsModel {
  bool? success;
  String? message;
  Data? data;

  ProductsModel.fromJson(Map<String, dynamic> json) {
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
  Name? name;
  Name? description;
  dynamic price;
  dynamic supplierPrice;
  dynamic discount;
  String? discountType;
  String? unit;
  dynamic priceAfterDiscount;
  int? mainCategoryId;
  int? subCategoryId;
  int? stock;
  List<Images>? images;
  bool? isRecommended;
  MainCategory? mainCategory;
  MainCategory? subCategory;

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    description = json['description'] != null ? Name.fromJson(json['description']) : null;
    price = json['price'];
    supplierPrice = json['supplier_price'];
    discount = json['discount'];
    unit = json['unit'];
    discountType = json['discount_type'];
    priceAfterDiscount = json['price_after_discount'];
    mainCategoryId = json['main_category_id'];
    subCategoryId = json['sub_category_id'];
    stock = json['stock'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    isRecommended = json['isRecommended'];
    mainCategory = json['mainCategory'] != null ? MainCategory.fromJson(json['mainCategory']) : null;
    subCategory = json['subCategory'] != null ? MainCategory.fromJson(json['subCategory']) : null;
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
}

class MainCategory {
  int? id;
  String? name;

  MainCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
class Name {
  String? en;
  String? ar;

  Name.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
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
