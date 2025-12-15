class ReviewsSummaryModel {
  bool? success;
  String? message;
  Data? data;

  ReviewsSummaryModel({this.success, this.message, this.data});

  ReviewsSummaryModel.fromJson(Map<String, dynamic> json) {
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
  dynamic averageRating;
  int? totalReviews;
  RatingDistribution? ratingDistribution;

  Data({this.averageRating, this.totalReviews, this.ratingDistribution});

  Data.fromJson(Map<String, dynamic> json) {
    averageRating = json['averageRating'];
    totalReviews = json['totalReviews'];
    ratingDistribution = json['ratingDistribution'] != null
        ? new RatingDistribution.fromJson(json['ratingDistribution'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['averageRating'] = this.averageRating;
    data['totalReviews'] = this.totalReviews;
    if (this.ratingDistribution != null) {
      data['ratingDistribution'] = this.ratingDistribution!.toJson();
    }
    return data;
  }
}

class RatingDistribution {
  int? i1;
  int? i2;
  int? i3;
  int? i4;
  int? i5;

  RatingDistribution({this.i1, this.i2, this.i3, this.i4, this.i5});

  RatingDistribution.fromJson(Map<String, dynamic> json) {
    i1 = json['1'];
    i2 = json['2'];
    i3 = json['3'];
    i4 = json['4'];
    i5 = json['5'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['1'] = this.i1;
    data['2'] = this.i2;
    data['3'] = this.i3;
    data['4'] = this.i4;
    data['5'] = this.i5;
    return data;
  }
}