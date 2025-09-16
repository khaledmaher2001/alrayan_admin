import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../core/utils/constants.dart';


class SettingsModel {
  String? androidVersion;
  String? androidLink;
  String? androidEndDate;
  String? iosVersion;
  String? iosLink;
  String? iosEndDate;

  SettingsModel(
      {this.androidVersion,
        this.androidLink,
        this.androidEndDate,
        this.iosVersion,
        this.iosLink,
        this.iosEndDate});

  SettingsModel.fromJson(Map<String, dynamic> json) {
    androidVersion = json['androidVersion'];
    androidLink = json['androidUrl'];
    androidEndDate = json['androidEndDate'];
    iosVersion = json['iosVersion'];
    iosLink = json['iosUrl'];
    iosEndDate = json['iosEndDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['androidVersion'] = this.androidVersion;
    data['androidUrl'] = this.androidLink;
    data['androidEndDate'] = this.androidEndDate;
    data['iosVersion'] = this.iosVersion;
    data['iosUrl'] = this.iosLink;
    data['iosEndDate'] = this.iosEndDate;
    return data;
  }
  Future<({bool needsUpdate, bool showSkip, String url})?>
  checkAppVersion() async {
    try {
      bool needsUpdate = false;
      bool showSkip = false;
      String url = '';
      final now = DateTime.now();

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      print("FFFFFFFFFFFFFFFFF: $currentVersion");
      if (Platform.isAndroid) {
        AppConstants.versionNow=this.androidVersion;
        final androidVersion = this.androidVersion;
        final endDate = androidEndDate;
        needsUpdate = currentVersion != androidVersion;
        showSkip = !now.isAfter(DateTime.parse(endDate!));
        url = androidLink ?? '';
      } else if (Platform.isIOS) {
        AppConstants.versionNow=iosVersion;
        needsUpdate = currentVersion != iosVersion;
        final endDate =iosEndDate;
        showSkip = !now.isAfter(DateTime.parse(endDate!));
        url = iosLink ?? '';
      }
      return (needsUpdate: needsUpdate, showSkip: showSkip, url: url);
    } catch (e) {
      print("Error checking version: $e");
      return null;
    }
  }

}