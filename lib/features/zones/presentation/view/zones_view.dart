import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/zones/data/repo/zones_repo_impl.dart';
import 'package:alrayan_admin/features/zones/presentation/view/add_zone_view.dart';
import 'package:alrayan_admin/features/zones/presentation/view/widgets/zone_item.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_cubit.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/delete_zone/delete_zone_state.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/get_zones/get_zones_cubit.dart';
import 'package:alrayan_admin/features/zones/presentation/view_model/get_zones/get_zones_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ZonesView extends StatelessWidget {
  const ZonesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>DeleteZoneCubit(getIt<ZonesRepoImpl>()),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            NavigationUtils.navigateTo(context: context, destinationScreen: AddZoneView());
          },
          backgroundColor: AppColors.primaryColor,
          child: Icon(Icons.add, color: Colors.white),
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
                    Text("المناطق", textAlign: TextAlign.center, style: Styles.inter18500Black(context)),
                    SizedBox(width: AppConstants.width30(context)),
                  ],
                ),
              ),
              SizedBox(height: AppConstants.height10(context)),
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
                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context.read<GetZonesCubit>().getZones(withLoading: true);
                          },
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) => Column(
                              children: [
                                ZoneItem(zoneData: state.model.data![index]),
                                if (index == state.model.data!.length - 1)
                                  SizedBox(height: AppConstants.height30(context) * 2),
                              ],
                            ),
                            separatorBuilder: (context, index) => SizedBox(height: AppConstants.height15(context)),
                            itemCount: state.model.data!.length,
                          ),
                        ),
                      );
                    } else {
                      return const CustomLoadingItem();
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
