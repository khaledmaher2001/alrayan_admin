import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
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
  var formKey=GlobalKey<FormState>();
  TextEditingController zoneName=TextEditingController();
  TextEditingController zoneCost=TextEditingController();

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
      cherryToast(
        text: "لازم على الأقل 3 نقاط علشان تعمل منطقة",
        context: context,
        isSuccess: false,
      );
      return null;
    }

    final body = buildPolygonObject(polygonPoints);

    print("Zone Polygon Object: $body");
    return body;
  }

  @override
  void initState() {
    if(widget.zoneData!=null){
      zoneName.text=widget.zoneData!.name??"";
      zoneCost.text=widget.zoneData!.shippingCost??"";

      final coords = widget.zoneData!.polygon?.coordinates;
      if (coords != null && coords.isNotEmpty) {
        // GeoJSON: coordinates[0] = list of points [lon, lat]
        polygonPoints = coords.first
            .map((point) => LatLng(point[1], point[0])) // LatLng(lat, lon)
            .toList();

        // تحديث الـ Polygon على الخريطة
        updatePolygon();
      }
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context)=>AddZoneCubit(getIt<ZonesRepoImpl>())),
        BlocProvider(create: (context)=>EditZoneCubit(getIt<ZonesRepoImpl>())),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: AppConstants.height10(context)),
              Text(widget.zoneData!=null?"تعديل المنطقة":"اضافة منطقة جديدة", textAlign: TextAlign.center, style: Styles.inter18500Black(context)),
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
                                  hintText: "ادخل اسم المنطقة",
                                  borderRadius: AppConstants.sp15(context),
                                validationMsg: "يجب ادخال اسم المنطقة",
                                  fillColor: Colors.grey[100],
                                  isFilled: true,
                                  hasBorder: false,
                                ),
                                SizedBox(height: AppConstants.height10(context)),

                                DefaultTextFormField(
                                  textInputType: TextInputType.number,
                                  controller: zoneCost,
                                  hintText: "ادخل تكلفة التوصيل للمنطقة",
                                  validationMsg: "يجب إدخال تكلفة التوصيل للمنطقة",
                                  borderRadius: AppConstants.sp15(context),
                                  fillColor: Colors.grey[100],
                                  isFilled: true,
                                  hasBorder: false,
                                ),
                                SizedBox(height: AppConstants.height5(context)),
                                Divider(color: Colors.grey[200]),
                                SizedBox(height: AppConstants.height5(context)),
                                BlocConsumer<AddZoneCubit, AddZoneStates>(
                                  listener: (context, addState) async {
                                    if (addState is AddZoneSuccessState) {
                                      cherryToast(text: addState.message, context: context);

                                      context.read<GetZonesCubit>().getZones();
                                      NavigationUtils.navigateBack(context: context);
                                    } else if (addState is AddZoneErrorState) {
                                      cherryToast(
                                        text: addState.error,
                                        context: context,
                                        isSuccess: false,
                                      );
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
                                          cherryToast(
                                            text: editState.error,
                                            context: context,
                                            isSuccess: false,
                                          );
                                        }
                                      },
                                      builder: (context, editState) {
                                        final isLoading =
                                            addState is AddZoneLoadingState ||
                                                editState is EditZoneLoadingState;
                                        if (isLoading) {
                                          return Center(child: const CircularProgressIndicator());
                                        }
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: DefaultButton(
                                                onPress:  () async {
                                                  if (formKey.currentState!.validate()) {
                                                    if (widget.zoneData != null) {
                                                      _saveZone().then((polygon) async {
                                                        if(polygon!=null){
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
                                                        if(polygon!=null){
                                                          await context.read<AddZoneCubit>().addZone(
                                                            data: {
                                                              "name": zoneName.text,
                                                              // "ShippingCost": zoneCost.text,
                                                              "polygon": polygon,
                                                              "isActive": true,
                                                            },
                                                          );
                                                        }

                                                      });
                                                    }
                                                  }
                                                }
                                                    ,
                                                borderRadius: AppConstants.sp10(context),
                                                text: widget.zoneData != null ? "تعديل المنطقة" : "حفظ المنطقة",
                                              ),
                                            ),
                                            SizedBox(width: AppConstants.width10(context)),
                                            FloatingActionButton(
                                              heroTag: "delete_last",
                                              tooltip: "مسح آخر نقطة",
                                              onPressed: removeLastPoint,
                                              backgroundColor:AppColors.secondaryColor,
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


