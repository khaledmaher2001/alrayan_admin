class LoginModel {
  bool? success;
  String? message;
  Data? data;

  LoginModel({this.success, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  bool? isEmailVerified;
  String? email;
  String? accessToken;
  String? tokenType;
  String? expiresIn;

  Data(
      {this.isEmailVerified,
        this.email,
        this.accessToken,
        this.tokenType,
        this.expiresIn});

  Data.fromJson(Map<String, dynamic> json) {
    isEmailVerified = json['isEmailVerified'];
    email = json['email'];
    accessToken = json['accessToken'];
    tokenType = json['token_type'];
    expiresIn = json['expires_in'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isEmailVerified'] = this.isEmailVerified;
    data['email'] = this.email;
    data['accessToken'] = this.accessToken;
    data['token_type'] = this.tokenType;
    data['expires_in'] = this.expiresIn;
    return data;
  }
}