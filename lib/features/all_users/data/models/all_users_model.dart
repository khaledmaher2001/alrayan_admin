class AllUsersModel {
  bool? success;
  String? message;
  Data? data;

  AllUsersModel({this.success, this.message, this.data});

  AllUsersModel.fromJson(Map<String, dynamic> json) {
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
  String? email;
  String? fullName;
  String? gender;
  String? phoneNumber;
  bool? isEmailVerified;
  String? role;

  Items(
      {this.id,
        this.createdAt,
        this.email,
        this.fullName,
        this.gender,
        this.phoneNumber,
        this.isEmailVerified,
        this.role});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    email = json['email'];
    fullName = json['fullName'];
    gender = json['gender'];
    phoneNumber = json['phoneNumber'];
    isEmailVerified = json['isEmailVerified'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['email'] = this.email;
    data['fullName'] = this.fullName;
    data['gender'] = this.gender;
    data['phoneNumber'] = this.phoneNumber;
    data['isEmailVerified'] = this.isEmailVerified;
    data['role'] = this.role;
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
  String? next;
  String? last;

  Links({this.hasNext, this.next, this.last});

  Links.fromJson(Map<String, dynamic> json) {
    hasNext = json['hasNext'];
    next = json['next'];
    last = json['last'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasNext'] = this.hasNext;
    data['next'] = this.next;
    data['last'] = this.last;
    return data;
  }
}