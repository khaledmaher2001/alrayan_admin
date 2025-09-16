class CategoriesModel {
  bool? success;
  String? message;
  List<Data>? data;

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }
}

class Data {
  int? id;
  String? icon;
  Name? name;
  List<SubCategories>? subCategories;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    name = json['name'] != null ? Name.fromJson(json["name"]) : null;
    if (json['subCategories'] != null) {
      subCategories = <SubCategories>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(SubCategories.fromJson(v));
      });
    }
  }
}

class Name {
  String? en;
  String? ar;

  Name.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
    en = json['en'];
  }
}

class SubCategories {
  int? id;
  Name? name;
  String? icon;

  SubCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] != null ? Name.fromJson(json["name"]) : null;
    icon = json['icon'];
  }
}
