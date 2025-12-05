
import 'package:alrayan_admin/features/products/data/models/products_model.dart';

class OfferBannerModel {
  bool? success;
  String? message;
  List<Data>? data;

  OfferBannerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add( Data.fromJson(v));
      });
    }
  }
}

class Data {
  int? id;
  String? imagePath;
  Items? product;


  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imagePath = json['imagePath'];
    product =
    json['product'] != null ?  Items.fromJson(json['product']) : null;
  }
}

class Product {
  int? id;
  String? name;

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}