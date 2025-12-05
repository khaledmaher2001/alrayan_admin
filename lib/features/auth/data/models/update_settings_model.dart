class UpdateSettingsModel {
  int? id;
  String? updatedAt;
  String? androidVersion;
  String? androidEndDate;
  String? androidUrl;
  String? iosVersion;
  String? iosEndDate;
  String? iosUrl;

  UpdateSettingsModel(
      {this.id,
        this.updatedAt,
        this.androidVersion,
        this.androidEndDate,
        this.androidUrl,
        this.iosVersion,
        this.iosEndDate,
        this.iosUrl});

  UpdateSettingsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    updatedAt = json['updatedAt'];
    androidVersion = json['androidVersion'];
    androidEndDate = json['androidEndDate'];
    androidUrl = json['androidUrl'];
    iosVersion = json['iosVersion'];
    iosEndDate = json['iosEndDate'];
    iosUrl = json['iosUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['updatedAt'] = this.updatedAt;
    data['androidVersion'] = this.androidVersion;
    data['androidEndDate'] = this.androidEndDate;
    data['androidUrl'] = this.androidUrl;
    data['iosVersion'] = this.iosVersion;
    data['iosEndDate'] = this.iosEndDate;
    data['iosUrl'] = this.iosUrl;
    return data;
  }
}