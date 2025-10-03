import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/zones/data/models/zones_model.dart';
import 'package:alrayan_admin/features/zones/presentation/view/add_zone_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_cubit.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ZoneItem extends StatelessWidget {
  const ZoneItem({super.key, required this.zoneData});

  final Zone zoneData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationUtils.navigateTo(
          context: context,
          destinationScreen: AddZoneView(zoneData: zoneData),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height15(context),
        ),
        margin: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, spreadRadius: 3, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.location_solid),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(child: Text(zoneData.name??"", style: Styles.inter16500black(context))),
            SizedBox(width: AppConstants.width5(context)),
            BlocBuilder<DeleteZoneCubit, DeleteZoneStates>(
              builder: (context, deleteState) {
                return GestureDetector(
                  onTap: () {
                    context.read<DeleteZoneCubit>().selectZone(zoneData.id!);
                    context.read<DeleteZoneCubit>().deleteZone(zoneId: zoneData.id!);
                  },
                  child: Container(
                    padding: EdgeInsets.all(AppConstants.sp5(context)),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                    ),
                    child:
                        deleteState is DeleteZoneLoadingState &&
                            context.read<DeleteZoneCubit>().selectedZoneId == zoneData.id
                        ? CustomLoadingItem(size: MediaQuery.of(context).size.width * 0.05, color: Colors.white)
                        : SvgPicture.asset(AssetData.delete, color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
