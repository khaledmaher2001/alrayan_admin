class OfferBannerModel {
  bool? success;
  String? message;
  List<Data>? data;

  OfferBannerModel({this.success, this.message, this.data});

  OfferBannerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? imagePath;
  Product? product;
  String? title;
  String? description;
  String? link;

  Data(
      {this.id,
        this.imagePath,
        this.product,
        this.title,
        this.description,
        this.link});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imagePath = json['imagePath'];
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
    title = json['title'];
    description = json['description'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['imagePath'] = this.imagePath;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    data['title'] = this.title;
    data['description'] = this.description;
    data['link'] = this.link;
    return data;
  }
}

class Product {
  int? id;
  String? name;
  String? description;
  dynamic price;
  dynamic supplierPrice;
  dynamic discount;
  String? discountType;
  dynamic priceAfterDiscount;
  int? mainCategoryId;
  int? subCategoryId;
  int? stock;
  bool? isFeatured;
  bool? isHidden;
  String? unit;
  List<Images>? images;
  bool? isRecommended;
  bool? isFavorite;
  bool? isInCart;
  int? productQuantity;
  int? cartItemId;
  MainCategory? mainCategory;
  MainCategory? subCategory;

  Product(
      {this.id,
        this.name,
        this.description,
        this.price,
        this.supplierPrice,
        this.discount,
        this.discountType,
        this.priceAfterDiscount,
        this.mainCategoryId,
        this.subCategoryId,
        this.stock,
        this.isFeatured,
        this.isHidden,
        this.unit,
        this.images,
        this.isRecommended,
        this.isFavorite,
        this.isInCart,
        this.productQuantity,
        this.cartItemId,
        this.mainCategory,
        this.subCategory});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    supplierPrice = json['supplier_price'];
    discount = json['discount'];
    discountType = json['discount_type'];
    priceAfterDiscount = json['price_after_discount'];
    mainCategoryId = json['main_category_id'];
    subCategoryId = json['sub_category_id'];
    stock = json['stock'];
    isFeatured = json['isFeatured'];
    isHidden = json['isHidden'];
    unit = json['unit'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    isRecommended = json['isRecommended'];
    isFavorite = json['isFavorite'];
    isInCart = json['isInCart'];
    productQuantity = json['productQuantity'];
    cartItemId = json['cartItemId'];
    mainCategory = json['mainCategory'] != null
        ? new MainCategory.fromJson(json['mainCategory'])
        : null;
    subCategory = json['subCategory'] != null
        ? new MainCategory.fromJson(json['subCategory'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['supplier_price'] = this.supplierPrice;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['price_after_discount'] = this.priceAfterDiscount;
    data['main_category_id'] = this.mainCategoryId;
    data['sub_category_id'] = this.subCategoryId;
    data['stock'] = this.stock;
    data['isFeatured'] = this.isFeatured;
    data['isHidden'] = this.isHidden;
    data['unit'] = this.unit;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    data['isRecommended'] = this.isRecommended;
    data['isFavorite'] = this.isFavorite;
    data['isInCart'] = this.isInCart;
    data['productQuantity'] = this.productQuantity;
    data['cartItemId'] = this.cartItemId;
    if (this.mainCategory != null) {
      data['mainCategory'] = this.mainCategory!.toJson();
    }
    if (this.subCategory != null) {
      data['subCategory'] = this.subCategory!.toJson();
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

class MainCategory {
  int? id;
  String? name;

  MainCategory({this.id, this.name});

  MainCategory.fromJson(Map<String, dynamic> json) {
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