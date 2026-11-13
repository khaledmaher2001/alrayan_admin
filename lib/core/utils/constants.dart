import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'dart:io';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static File? file;
  static bool hasInternet = true;
  static String? versionNow;
  static double? lat;
  static double? long;

  static int? mainCategoryId;
  static int? subCategoryId;
  static TextEditingController searchController = TextEditingController();

  static String getStatusText(String? status) {
    switch (status) {
      case "pending":
        return "s_pending".tr();
      case "shipped":
        return "s_shipped".tr();
        case "confirmed":
        return "s_confirmed".tr();
      case "delivered":
        return "s_delivered".tr();
      case "cancelled":
        return "s_cancelled".tr();
      case "refunded":
        return "s_refunded".tr();
      default:
        return "s_expired".tr();
    }
  }

  static String getStatusIcon(String? status) {
    switch (status) {
      case "pending":
        return AssetData.navCart;
      case "confirmed":
        return AssetData.confirmed;
      case "processing":
        return AssetData.processing;
      case "shipped":
        return AssetData.delivery;
      case "delivered":
        return AssetData.location;
      case "cancelled":
        return AssetData.cancelled;
      case "refunded":
        return AssetData.refunded;
      default:
        return AssetData.navCart;
    }
  }

  static Color getStatusColor(String? status) {
    switch (status) {
      case "pending": // لسه في الانتظار
        return const Color(0xffFEF3C7);
      case "confirmed": // تم التأكيد
        return DsColor.info.withValues(alpha: 0.2);
      case "processing": // الطلب بيتجهز
        return DsColor.warning.withValues(alpha: 0.2);
      case "shipped": // تم الشحن
        return DsColor.info.withValues(alpha: 0.2);
      case "delivered": // تم التوصيل
        return DsColor.success.withValues(alpha: 0.2);
      case "cancelled": // تم الإلغاء
        return DsColor.danger.withValues(alpha: 0.2);
      case "refunded": // تم الاسترجاع
        return DsColor.textMuted.withValues(alpha: 0.2);
      default:
        return DsColor.textMuted.withValues(alpha: 0.2);
    }
  }

  static Color getTextColor(String? status) {
    switch (status) {
      case "pending":
        // Darker amber: yellow text on a yellow tint was hard to read.
        return const Color(0xff92400E);
      case "confirmed":
        return DsColor.info;
      case "processing":
        return DsColor.warning;
      case "shipped":
        return DsColor.info;
      case "delivered":
        return DsColor.success;
      case "cancelled":
        return DsColor.danger;
      case "refunded":
        return DsColor.text2;
      default:
        return DsColor.text2;
    }
  }

  static List<Color> spinColor = [
    Color(0xFFFF4A26),
    Color(0xFFFF623F),
    Color(0xFFFF7B59),
    Color(0xFFFF946F),
    Color(0xFFFFB087),
    Color(0xFFFFC39A),
  ];

  static String spinIcon(String? status) {
    switch (status) {
      case "discount_coupon":
        return AssetData.couponDiscount;
      case "no_reward":
        return AssetData.lose;
      case "free_shipping":
        return AssetData.freeShipping;
      case "discount_product":
        return AssetData.freeProduct;
      default:
        return AssetData.couponDiscount;
    }
  }

  static double sp5(context) => 4; // fixed grid (was a fraction of the screen height)

  static double sp10(context) => 12; // fixed grid (was a fraction of the screen height)

  static double sp15(context) => 16; // fixed grid (was a fraction of the screen height)

  static double sp20(context) => 20; // fixed grid (was a fraction of the screen height)

  static double sp30(context) => 32; // fixed grid (was a fraction of the screen height)

  static double height5(context) => 4; // fixed grid (was a fraction of the screen height)

  static double height10(context) => 8; // fixed grid (was a fraction of the screen height)

  static double height15(context) => 16; // fixed grid (was a fraction of the screen height)

  static double height20(context) => 20; // fixed grid (was a fraction of the screen height)

  static double height30(context) => 24; // fixed grid (was a fraction of the screen height)

  static double height55(context) => 56; // fixed grid (was a fraction of the screen height)

  static double width5(context) => 8; // fixed grid (was a fraction of the screen height)

  static double width10(context) => 12; // fixed grid (was a fraction of the screen height)

  static double width15(context) => 16; // fixed grid (was a fraction of the screen height)

  static double width20(context) => 20; // fixed grid (was a fraction of the screen height)

  static double width30(context) => 32; // fixed grid (was a fraction of the screen height)

  static double width50(context) => 48; // fixed grid (was a fraction of the screen height)

  static double height200(context) {
    var height = MediaQuery.of(context).size.height * .4;
    return height;
  }
}
