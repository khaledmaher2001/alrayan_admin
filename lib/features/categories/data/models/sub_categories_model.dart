class SubCategoriesModel {
  bool? success;
  String? message;
  List<Data>? data;

  SubCategoriesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }
}

class Data {
  int? id;
  String? icon;
  Name? name;
  int? mainCategoryId;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    mainCategoryId = json['main_category_id'];
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
