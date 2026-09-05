class UserDetailModel {
  int? id;
  String? createdAt;
  String? updatedAt;
  String? email;
  String? fullName;
  String? gender;
  String? phoneNumber;
  bool? isEmailVerified;
  String? role;
  String? lastLoginAt;
  int? loginCount;
  List<UserAddress>? addresses;

  UserDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    email = json['email'];
    fullName = json['fullName'];
    gender = json['gender'];
    phoneNumber = json['phoneNumber'];
    isEmailVerified = json['isEmailVerified'];
    role = json['role'];
    lastLoginAt = json['lastLoginAt'];
    loginCount = json['loginCount'];
    if (json['addresses'] != null) {
      addresses = (json['addresses'] as List)
          .map((e) => UserAddress.fromJson(e))
          .toList();
    }
  }
}

class UserAddress {
  int? id;
  String? type;
  String? title;
  String? description;
  bool? isDefault;
  String? phoneNumber;
  String? latitude;
  String? longitude;

  UserAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    description = json['description'];
    isDefault = json['isDefault'];
    phoneNumber = json['phoneNumber'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }
}
