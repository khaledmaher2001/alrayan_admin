class LuckyWheelModel {
  bool? success;
  String? message;
  Data? data;

  LuckyWheelModel({this.success, this.message, this.data});

  LuckyWheelModel.fromJson(Map<String, dynamic> json) {
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
  bool? isActive;
  List<Rewards>? rewards;

  Data({this.isActive, this.rewards});

  Data.fromJson(Map<String, dynamic> json) {
    isActive = json['isActive'];
    if (json['rewards'] != null) {
      rewards = <Rewards>[];
      json['rewards'].forEach((v) {
        rewards!.add(new Rewards.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isActive'] = this.isActive;
    if (this.rewards != null) {
      data['rewards'] = this.rewards!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rewards {
  int? id;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? type;
  String? discountType;
  String? discountValue;
  int? productId;
  String? displayText;
  String? couponCode;
  dynamic probability;
  bool? isActive;
  String? description;
  String? expiresAt;
  String? minOrderAmount;

  Rewards(
      {this.id,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.type,
        this.discountType,
        this.discountValue,
        this.productId,
        this.displayText,
        this.couponCode,
        this.probability,
        this.isActive,
        this.description,
        this.expiresAt,
        this.minOrderAmount});

  Rewards.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
    type = json['type'];
    discountType = json['discountType'];
    discountValue = json['discountValue'];
    productId = json['productId'];
    displayText = json['displayText'];
    couponCode = json['couponCode'];
    probability = json['probability'];
    isActive = json['isActive'];
    description = json['description'];
    expiresAt = json['expiresAt'];
    minOrderAmount = json['minOrderAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['deletedAt'] = this.deletedAt;
    data['type'] = this.type;
    data['discountType'] = this.discountType;
    data['discountValue'] = this.discountValue;
    data['productId'] = this.productId;
    data['displayText'] = this.displayText;
    data['couponCode'] = this.couponCode;
    data['probability'] = this.probability;
    data['isActive'] = this.isActive;
    data['description'] = this.description;
    data['expiresAt'] = this.expiresAt;
    data['minOrderAmount'] = this.minOrderAmount;
    return data;
  }
}