class ProfileModel {
  bool? success;
  String? message;
  Data? data;


  ProfileModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }
}

class Data {
  int? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? email;
  String? fullName;
  String? gender;
  String? phoneNumber;
  bool? isEmailVerified;
  List<String>? playerIds;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    email = json['email'];
    fullName = json['fullName'];
    gender = json['gender'];
    phoneNumber = json['phoneNumber'];
    isEmailVerified = json['isEmailVerified'];
    playerIds = json['playerIds'].cast<String>();

  }
}

