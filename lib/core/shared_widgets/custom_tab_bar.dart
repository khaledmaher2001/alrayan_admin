import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key, this.onTap, required this.titles});

  final Function(int index)? onTap;
  final List<String> titles;

  bool get shouldExpand => titles.length <= 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width5(context), vertical: AppConstants.height5(context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.width10(context)),
        color: Color(0xffF6F8FE),
      ),
      child: shouldExpand
          ? TabBar(
        onTap: onTap,
        isScrollable: !shouldExpand,
        padding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabAlignment: shouldExpand ? null : TabAlignment.start,
        unselectedLabelColor: Color(0xff9CA4AB),
        labelColor:Colors.white,
        labelStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.height * .017,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius:
          BorderRadius.circular(AppConstants.width10(context)),
          color: AppColors.primaryColor,
        ),
        labelPadding: EdgeInsets.symmetric(
            horizontal: AppConstants.width10(context)),
        tabs: titles.map((title) {
          final tab = Tab(
            iconMargin: EdgeInsets.zero,
            text: title,
          );
          return tab;
        }).toList(),
      )
          : TabBar(
        onTap: onTap,
        isScrollable: !shouldExpand,
        padding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabAlignment: shouldExpand ? null : TabAlignment.start,
        unselectedLabelColor: Color(0xff9CA4AB),
        labelColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: MediaQuery.of(context).size.height * .015,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius:
          BorderRadius.circular(AppConstants.width10(context)),
          color: AppColors.primaryColor,
        ),
        labelPadding: EdgeInsets.symmetric(
            horizontal: AppConstants.width10(context)),
        tabs: titles.map((title) {
          final tab = Tab(
            iconMargin: EdgeInsets.zero,
            text: title,
          );
          return tab;
        }).toList(),
      ),
    );
  }
}
