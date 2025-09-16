class NotificationsModel {
  bool? success;
  String? message;
  Data? data;

  NotificationsModel({this.success, this.message, this.data});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
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
  int? unreadCount;

  Data({this.items, this.metadata, this.links, this.unreadCount});

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
    unreadCount = json['unreadCount'];
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
    data['unreadCount'] = this.unreadCount;
    return data;
  }
}

class Items {
  String? createdAt;
  int? id;
  String? title;
  String? message;
  NavigationData? navigationData;
  String? type;
  String? scheduledAt;
  List<Recipients>? recipients;

  Items(
      {this.createdAt,
        this.id,
        this.title,
        this.message,
        this.navigationData,
        this.type,
        this.scheduledAt,
        this.recipients});

  Items.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    id = json['id'];
    title = json['title'];
    message = json['message'];
    navigationData = json['navigationData'] != null
        ? new NavigationData.fromJson(json['navigationData'])
        : null;
    type = json['type'];
    scheduledAt = json['scheduledAt'];
    if (json['recipients'] != null) {
      recipients = <Recipients>[];
      json['recipients'].forEach((v) {
        recipients!.add(new Recipients.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['id'] = this.id;
    data['title'] = this.title;
    data['message'] = this.message;
    if (this.navigationData != null) {
      data['navigationData'] = this.navigationData!.toJson();
    }
    data['type'] = this.type;
    data['scheduledAt'] = this.scheduledAt;
    if (this.recipients != null) {
      data['recipients'] = this.recipients!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NavigationData {
  Params? params;
  String? screen;

  NavigationData({this.params, this.screen});

  NavigationData.fromJson(Map<String, dynamic> json) {
    params =
    json['params'] != null ? new Params.fromJson(json['params']) : null;
    screen = json['screen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.params != null) {
      data['params'] = this.params!.toJson();
    }
    data['screen'] = this.screen;
    return data;
  }
}

class Params {
  int? applicationId;
  int? riwaqId;

  Params({this.applicationId, this.riwaqId});

  Params.fromJson(Map<String, dynamic> json) {
    applicationId = json['applicationId'];
    riwaqId = json['riwaqId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['applicationId'] = this.applicationId;
    data['riwaqId'] = this.riwaqId;
    return data;
  }
}

class Recipients {
  User? user;
  bool? isRead;
  String? readAt;

  Recipients({this.user, this.isRead, this.readAt});

  Recipients.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    isRead = json['isRead'];
    readAt = json['readAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['isRead'] = this.isRead;
    data['readAt'] = this.readAt;
    return data;
  }
}

class User {
  int? id;

  User({this.id});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
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

  Links({this.hasNext});

  Links.fromJson(Map<String, dynamic> json) {
    hasNext = json['hasNext'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasNext'] = this.hasNext;
    return data;
  }
}