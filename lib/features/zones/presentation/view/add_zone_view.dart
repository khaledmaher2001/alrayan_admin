import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/zones/data/models/zones_model.dart';
import 'package:alrayan_admin/features/zones/data/repo/zones_repo_impl.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/add_zone/add_zone_cubit.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/add_zone/add_zone_state.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/edit_zone/edit_zone_cubit.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/edit_zone/edit_zone_state.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/get_zones/get_zones_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddZoneView extends StatefulWidget {
  const AddZoneView({super.key, this.zoneData});

  final Zone? zoneData;

  @override
  State<AddZoneView> createState() => _AddZoneViewState();
}

class _AddZoneViewState extends State<AddZoneView> {
  GoogleMapController? _mapController;
  List<LatLng> polygonPoints = [];
  Set<Polygon> polygons = {};
  var formKey = GlobalKey<FormState>();
  TextEditingController zoneName = TextEditingController();
  TextEditingController zoneCost = TextEditingController();

  @override
  void dispose() {
    zoneName.dispose();
    zoneCost.dispose();
    super.dispose();
  }

  void addPoint(LatLng point) {
    setState(() {
      polygonPoints.add(point);
      updatePolygon();
    });
  }

  void removeLastPoint() {
    if (polygonPoints.isNotEmpty) {
      setState(() {
        polygonPoints.removeLast();
        updatePolygon();
      });
    }
  }

  void clearAllPoints() {
    setState(() {
      polygonPoints.clear();
      updatePolygon();
    });
  }

  void updatePolygon() {
    polygons = {
      Polygon(
        polygonId: PolygonId("zone"),
        points: polygonPoints,
        strokeColor: AppColors.primaryColor,
        fillColor: AppColors.primaryColor.withValues(alpha: 0.3),
        strokeWidth: 2,
      ),
    };
  }

  Map<String, dynamic> buildPolygonObject(List<LatLng> points) {
    final polygonPoints = List<LatLng>.from(points);

    if (polygonPoints.isNotEmpty && polygonPoints.first != polygonPoints.last) {
      polygonPoints.add(polygonPoints.first);
    }

    return {
      "type": "Polygon",
      "coordinates": [
        polygonPoints.map((p) => [p.longitude, p.latitude]).toList(),
      ],
    };
  }

  Future<Map<String, dynamic>?> _saveZone() async {
    if (polygonPoints.length < 3) {
      cherryToast(text: "s_an_area_needs_at_least_3_points".tr(), context: context, isSuccess: false);
      return null;
    }

    final body = buildPolygonObject(polygonPoints);

    print("Zone Polygon Object: $body");
    return body;
  }

  @override
  void initState() {
    if (widget.zoneData != null) {
      zoneName.text = widget.zoneData!.name ?? "";
      zoneCost.text = widget.zoneData!.shippingCost ?? "";

      final coords = widget.zoneData!.polygon?.coordinates;
      if (coords != null && coords.isNotEmpty) {
        polygonPoints = coords.first.map((point) => LatLng(point[1], point[0])).toList();
        updatePolygon();
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AddZoneCubit(getIt<ZonesRepoImpl>())),
        BlocProvider(create: (context) => EditZoneCubit(getIt<ZonesRepoImpl>())),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: AppConstants.height10(context)),
              Text(
                widget.zoneData != null ? "s_edit_zone".tr() : "s_add_a_new_zone".tr(),
                textAlign: TextAlign.center,
                style: Styles.inter18500Black(context),
              ),
              SizedBox(height: AppConstants.height10(context)),
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(28.8219772, 30.9099758), // Cairo
                        zoom: 13,
                      ),
                      polygons: polygons,
                      onTap: addPoint,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppConstants.sp30(context)),
                            topRight: Radius.circular(AppConstants.sp30(context)),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.width15(context),
                          vertical: AppConstants.height15(context),
                        ),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DefaultTextFormField(
                                  textInputType: TextInputType.text,
                                  controller: zoneName,
                                  hintText: "s_enter_the_zone_name".tr(),
                                  borderRadius: AppConstants.sp15(context),
                                  validationMsg: "s_zone_name_is_required".tr(),
                                  fillColor: DsColor.fill,
                                  isFilled: true,
                                  hasBorder: false,
                                ),
                                SizedBox(height: AppConstants.height10(context)),

                                DefaultTextFormField(
                                  textInputType: TextInputType.number,
                                  controller: zoneCost,
                                  hintText: "s_enter_the_delivery_fee_for_the_zone".tr(),
                                  validationMsg: "s_delivery_fee_for_the_zone_is_require".tr(),
                                  borderRadius: AppConstants.sp15(context),
                                  fillColor: DsColor.fill,
                                  isFilled: true,
                                  hasBorder: false,
                                ),
                                SizedBox(height: AppConstants.height5(context)),
                                Divider(color: DsColor.border),
                                SizedBox(height: AppConstants.height5(context)),
                                BlocConsumer<AddZoneCubit, AddZoneStates>(
                                  listener: (context, addState) async {
                                    if (addState is AddZoneSuccessState) {
                                      cherryToast(text: addState.message, context: context);

                                      context.read<GetZonesCubit>().getZones();
                                      NavigationUtils.navigateBack(context: context);
                                    } else if (addState is AddZoneErrorState) {
                                      cherryToast(text: addState.error, context: context, isSuccess: false);
                                    }
                                  },
                                  builder: (context, addState) {
                                    return BlocConsumer<EditZoneCubit, EditZoneStates>(
                                      listener: (context, editState) async {
                                        if (editState is EditZoneSuccessState) {
                                          cherryToast(text: editState.message, context: context);
                                          context.read<GetZonesCubit>().getZones();
                                          NavigationUtils.navigateBack(context: context);
                                        } else if (editState is EditZoneErrorState) {
                                          cherryToast(text: editState.error, context: context, isSuccess: false);
                                        }
                                      },
                                      builder: (context, editState) {
                                        final isLoading =
                                            addState is AddZoneLoadingState || editState is EditZoneLoadingState;
                                        if (isLoading) {
                                          return const CustomLoadingItem();
                                        }
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: DefaultButton(
                                                onPress: () async {
                                                  if (formKey.currentState!.validate()) {
                                                    if (widget.zoneData != null) {
                                                      _saveZone().then((polygon) async {
                                                        if (polygon != null) {
                                                          await context.read<EditZoneCubit>().editZone(
                                                            zoneId: widget.zoneData!.id!,
                                                            data: {
                                                              "name": zoneName.text,
                                                              // "ShippingCost": zoneCost.text,
                                                              "polygon": polygon,
                                                              "isActive": true,
                                                            },
                                                          );
                                                        }
                                                      });
                                                    } else {
                                                      _saveZone().then((polygon) async {
                                                        if (polygon != null) {
                                                          await context.read<AddZoneCubit>().addZone(
                                                            data: {
                                                              "name": zoneName.text.trim(),
                                                              "shippingCost": zoneCost.text.trim(),
                                                              "polygon": polygon,
                                                              "isActive": true,
                                                            },
                                                          );
                                                        }
                                                      });
                                                    }
                                                  }
                                                },
                                                borderRadius: AppConstants.sp10(context),
                                                text: widget.zoneData != null ? "s_edit_zone".tr() : "s_save_zone".tr(),
                                              ),
                                            ),
                                            SizedBox(width: AppConstants.width10(context)),
                                            FloatingActionButton(
                                              heroTag: "delete_last",
                                              tooltip: "s_remove_last_point".tr(),
                                              onPressed: removeLastPoint,
                                              backgroundColor: AppColors.secondaryColor,
                                              child: Icon(Icons.undo, color: Colors.white),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
