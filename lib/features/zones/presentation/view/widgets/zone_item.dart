import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/zones/data/models/zones_model.dart';
import 'package:alrayan_admin/features/zones/presentation/view/add_zone_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_cubit.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ZoneItem extends StatelessWidget {
  const ZoneItem({super.key, required this.zoneData});

  final Zone zoneData;

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "تأكيد الحذف",
            style: Styles.inter24600black(context),
          ),
          content: Text(
            "هل أنت متأكد أنك تريد حذف المنطقة؟",
            style: Styles.font18500Grey900(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.sp10(dialogContext),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                "إلغاء",
                style: Styles.inter18500Black(context),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                "حذف",
                style: Styles.inter16400white(context),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      context.read<DeleteZoneCubit>().selectZone(zoneData.id!);
      context.read<DeleteZoneCubit>().deleteZone(zoneId: zoneData.id!);
    }
  }

  /// Zone polygons come in as [lng, lat] pairs (GeoJSON order) — this both
  /// converts them to [LatLng] and finds their rough center for the pin
  /// marker and the mini-map's camera target.
  List<LatLng> get _points {
    final ring = zoneData.polygon?.coordinates;
    if (ring == null || ring.isEmpty) return const [];
    return ring.first.map((p) => LatLng(p[1], p[0])).toList();
  }

  LatLng? get _center {
    final points = _points;
    if (points.isEmpty) return null;
    double latSum = 0, lngSum = 0;
    for (final p in points) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;
    final center = _center;

    return GestureDetector(
      onTap: () {
        NavigationUtils.navigateTo(
          context: context,
          destinationScreen: AddZoneView(zoneData: zoneData),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 3),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (center != null)
                    IgnorePointer(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: center, zoom: 13.5),
                        polygons: {
                          Polygon(
                            polygonId: PolygonId('zone_${zoneData.id}'),
                            points: points,
                            strokeColor: AppColors.primaryColor,
                            fillColor: AppColors.primaryColor.withOpacity(.25),
                            strokeWidth: 2,
                          ),
                        },
                        markers: {
                          Marker(markerId: MarkerId('zone_center_${zoneData.id}'), position: center),
                        },
                        liteModeEnabled: true,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                      ),
                    )
                  else
                    Container(
                      color: AppColors.gray.withOpacity(.1),
                      alignment: Alignment.center,
                      child: Icon(Icons.map_outlined, color: AppColors.gray, size: 32),
                    ),
                  PositionedDirectional(
                    top: AppConstants.height10(context),
                    start: AppConstants.width10(context),
                    child: BlocBuilder<DeleteZoneCubit, DeleteZoneStates>(
                      builder: (context, deleteState) {
                        final isDeletingThis = deleteState is DeleteZoneLoadingState &&
                            context.read<DeleteZoneCubit>().selectedZoneId == zoneData.id;
                        return GestureDetector(
                          onTap: () => _showDeleteConfirmationDialog(context),
                          child: Container(
                            padding: EdgeInsets.all(AppConstants.sp10(context)),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: isDeletingThis
                                ? CustomLoadingItem(
                                    size: AppConstants.sp15(context),
                                    color: AppColors.redColor,
                                  )
                                : SvgPicture.asset(
                                    AssetData.delete,
                                    width: AppConstants.width15(context),
                                    colorFilter: ColorFilter.mode(AppColors.redColor, BlendMode.srcIn),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  PositionedDirectional(
                    top: AppConstants.height10(context),
                    end: AppConstants.width10(context),
                    child: GestureDetector(
                      onTap: () {
                        NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: AddZoneView(zoneData: zoneData),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(AppConstants.sp10(context)),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.open_in_full, size: AppConstants.width15(context), color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zoneData.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: AppConstants.height5(context)),
                  Row(
                    children: [
                      if (zoneData.shippingCost != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.width10(context) - 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(.1),
                            borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                          ),
                          child: Text(
                            "${zoneData.shippingCost} ج.م",
                            style: Styles.inter12500Black(context).copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: AppConstants.width5(context)),
                      ],
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(AssetData.shipping, width: AppConstants.width15(context)),
                            SizedBox(width: AppConstants.width5(context) / 2),
                            Flexible(
                              child: Text(
                                "سعر التوصيل",
                                overflow: TextOverflow.ellipsis,
                                style: Styles.inter10400grey(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
