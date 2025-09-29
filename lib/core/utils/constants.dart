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
        return "قيد الانتظار";
      case "confirmed":
        return "تم التأكيد";
      case "processing":
        return "جاري التجهيز";
      case "shipped":
        return "تم الشحن";
      case "delivered":
        return "تم التوصيل";
      case "cancelled":
        return "تم الإلغاء";
      case "refunded":
        return "تم استرجاع المبلغ";
      default:
        return "منتهي الصلاحية";
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
        return Colors.yellow.withValues(alpha: 0.2);
      case "confirmed": // تم التأكيد
        return Colors.blue.withValues(alpha: 0.2);
      case "processing": // الطلب بيتجهز
        return Colors.orange.withValues(alpha: 0.2);
      case "shipped": // تم الشحن
        return Colors.purple.withValues(alpha: 0.2);
      case "delivered": // تم التوصيل
        return Colors.green.withValues(alpha: 0.2);
      case "cancelled": // تم الإلغاء
        return Colors.red.withValues(alpha: 0.2);
      case "refunded": // تم الاسترجاع
        return Colors.grey.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  static Color getTextColor(String? status) {
    switch (status) {
      case "pending":
        return Colors.yellow.shade800;
      case "confirmed":
        return Colors.blue.shade800;
      case "processing":
        return Colors.orange.shade800;
      case "shipped":
        return Colors.purple.shade800;
      case "delivered":
        return Colors.green.shade800;
      case "cancelled":
        return Colors.red.shade800;
      case "refunded":
        return Colors.grey.shade800;
      default:
        return Colors.grey.shade800;
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

  static double sp5(context) {
    var height = MediaQuery.of(context).size.height * .006;
    return height;
  }

  static double sp10(context) {
    var height = MediaQuery.of(context).size.height * .012;
    return height;
  }

  static double sp15(context) {
    var height = MediaQuery.of(context).size.height * .016;
    return height;
  }

  static double sp20(context) {
    var height = MediaQuery.of(context).size.height * .022;
    return height;
  }

  static double sp30(context) {
    var height = MediaQuery.of(context).size.height * .032;
    return height;
  }

  static double height5(context) {
    var height = MediaQuery.of(context).size.height * .006;
    return height;
  }

  static double height10(context) {
    var height = MediaQuery.of(context).size.height * .012;
    return height;
  }

  static double height15(context) {
    var height = MediaQuery.of(context).size.height * .018;
    return height;
  }

  static double height20(context) {
    var height = MediaQuery.of(context).size.height * .024;
    return height;
  }

  static double height30(context) {
    var height = MediaQuery.of(context).size.height * .030;
    return height;
  }

  static double height55(context) {
    var height = MediaQuery.of(context).size.height * .075;
    return height;
  }

  static double width5(context) {
    var height = MediaQuery.of(context).size.height * .0075;
    return height;
  }

  static double width10(context) {
    var height = MediaQuery.of(context).size.height * .015;
    return height;
  }

  static double width15(context) {
    var height = MediaQuery.of(context).size.height * .02;
    return height;
  }

  static double width20(context) {
    var height = MediaQuery.of(context).size.height * .024;
    return height;
  }

  static double width30(context) {
    var height = MediaQuery.of(context).size.height * .036;
    return height;
  }

  static double width50(context) {
    var height = MediaQuery.of(context).size.height * .056;
    return height;
  }

  static double height200(context) {
    var height = MediaQuery.of(context).size.height * .4;
    return height;
  }
}
