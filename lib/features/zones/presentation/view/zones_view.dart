import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/shared_widgets/shimmer_helpers.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/zones/data/models/zones_model.dart';
import 'package:alrayan_admin/features/zones/data/repo/zones_repo_impl.dart';
import 'package:alrayan_admin/features/zones/presentation/view/add_zone_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view/widgets/zone_item.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_cubit.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_state.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/get_zones/get_zones_cubit.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/get_zones/get_zones_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ZonesView extends StatefulWidget {
  const ZonesView({super.key});

  @override
  State<ZonesView> createState() => _ZonesViewState();
}

class _ZonesViewState extends State<ZonesView> {
  final TextEditingController searchController = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() => query = searchController.text.trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetZonesCubit>().getZones(withLoading: true);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Zone> _applyFilter(List<Zone> source) {
    if (query.isEmpty) return source;
    final q = query.toLowerCase();
    return source.where((zone) => (zone.name ?? '').toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>DeleteZoneCubit(getIt<ZonesRepoImpl>()),
      child: Scaffold(
        // Same create action as every other list screen.
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "zone_add",
          onPressed: () => NavigationUtils.navigateTo(context: context, destinationScreen: AddZoneView()),
          icon: const Icon(Icons.add_rounded),
          label: Text("s_add_a_new_zone_2".tr()),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: AppConstants.height10(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomBackButton(),
                    Text("s_delivery_zones".tr(), textAlign: TextAlign.center, style: Styles.inter18500Black(context)),
                    BlocBuilder<GetZonesCubit, GetZonesStates>(
                      buildWhen: (previous, current) => current is GetZonesSuccessState,
                      builder: (context, state) {
                        final count = state is GetZonesSuccessState ? (state.model.data?.length ?? 0) : 0;
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppConstants.width10(context),
                            vertical: AppConstants.height5(context),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray.withOpacity(.12),
                            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                          ),
                          child: Text(
                            "i_x_zones_91".tr(namedArgs: {"a": "${count}"}),
                            style: Styles.inter12500Black(context).copyWith(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppConstants.height15(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
                child: TextField(
                  controller: searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "s_search_zones".tr(),
                    hintStyle: Styles.inter14600gray(context),
                    prefixIcon: Icon(Icons.search, color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.gray.withOpacity(.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppConstants.height15(context)),
              BlocListener<DeleteZoneCubit,DeleteZoneStates>(
                listener: (context, deleteState) {
                  if (deleteState is DeleteZoneSuccessState) {
                    cherryToast(text: deleteState.message, context: context);
                    context.read<GetZonesCubit>().getZones();
                  } else if (deleteState is DeleteZoneErrorState) {
                    cherryToast(text: deleteState.error, context: context, isSuccess: false);
                  }
                },
                child: BlocBuilder<GetZonesCubit, GetZonesStates>(
                  builder: (context, state) {
                    if (state is GetZonesSuccessState) {
                      final zones = state.model.data ?? [];
                      final filtered = _applyFilter(zones);
                      if (filtered.isEmpty) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              zones.isEmpty ? "s_no_zones_yet".tr() : "s_no_matching_zones".tr(),
                              style: Styles.inter14600gray(context),
                            ),
                          ),
                        );
                      }
                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context.read<GetZonesCubit>().getZones(withLoading: true);
                          },
                          child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            // Bottom room so the FAB never covers the last row.
                            padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.sm, DsSpace.page, 96),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppConstants.width10(context),
                              mainAxisSpacing: AppConstants.height15(context),
                              childAspectRatio: .78,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => ZoneItem(zoneData: filtered[index]),
                          ),
                        ),
                      );
                    } else {
                      return const Expanded(child: _ZonesShimmer());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZonesShimmer extends StatelessWidget {
  const _ZonesShimmer();

  @override
  Widget build(BuildContext context) {
    return appShimmer(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height10(context),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.width10(context),
          mainAxisSpacing: AppConstants.height15(context),
          childAspectRatio: .78,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: shimmerBox(context, width: double.infinity, height: double.infinity)),
              SizedBox(height: AppConstants.height10(context)),
              shimmerBox(context, width: MediaQuery.of(context).size.width * .25, height: AppConstants.height15(context)),
              SizedBox(height: AppConstants.height5(context)),
              shimmerBox(context, width: MediaQuery.of(context).size.width * .35, height: AppConstants.height10(context)),
            ],
          );
        },
      ),
    );
  }
}
