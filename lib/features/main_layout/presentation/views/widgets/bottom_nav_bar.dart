import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/features/main_layout/presentation/views/widgets/bottom_nav_bar_item.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> icons = [
      AssetData.home,
      AssetData.category,
      AssetData.category,
      AssetData.products,
      AssetData.profile,
    ];
    List<String> activeIcons = [
      AssetData.activeHome,
      AssetData.activeCategory,
      AssetData.activeCategory,
      AssetData.activeProducts,
      AssetData.activeProfile,
    ];
    List<String> titles = [
     "home".tr(),
     "category".tr(),
     "orders".tr(),
     "products".tr(),
     "account".tr(),
    ];
    return BlocBuilder<ChangeNavBarStatusCubit, ChangeNavBarStatusState>(builder: (context, state) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context)),
        decoration: BoxDecoration(
          color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 16.55,
                  spreadRadius: 0,
                  offset: Offset(0, -8.82)
              )
            ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            titles.length,
            (index) => BottomNavBarItem(
              icon: icons[index],
              activeIcon: activeIcons[index],
              title: titles[index],
              index: index,
            ),
          ),
        ),
      );
    });
  }
}
