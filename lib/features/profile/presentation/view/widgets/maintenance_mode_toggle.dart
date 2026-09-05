import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/toggle_maintenance/toggle_maintenance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaintenanceModeToggle extends StatelessWidget {
  const MaintenanceModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ToggleMaintenanceCubit, ToggleMaintenanceState>(
      listener: (context, state) {
        if (state is ToggleMaintenanceSuccessState) {
          context.read<GetSettingsCubit>().getSettings();
        } else if (state is ToggleMaintenanceErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, toggleState) {
        return BlocBuilder<GetSettingsCubit, GetSettingsState>(
          builder: (context, settingsState) {
            final isMaintenance =
                context.read<GetSettingsCubit>().settingsModel?.maintenance ??
                false;
            final isLoading = toggleState is ToggleMaintenanceLoadingState;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.sp20(context),
                vertical: AppConstants.sp10(context),
              ),
              decoration: BoxDecoration(
                color: isMaintenance
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                border: Border.all(
                  color: isMaintenance ? Colors.orange : Colors.green,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppConstants.sp10(context)),
                    decoration: BoxDecoration(
                      color: isMaintenance
                          ? Colors.white
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        AppConstants.sp10(context),
                      ),
                    ),
                    child: Icon(
                      Icons.build_circle_outlined,
                      color: isMaintenance ? Colors.orange : Colors.green,
                      size: MediaQuery.of(context).size.width * .08,
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "وضع الصيانة",
                          style: Styles.inter14500black(context),
                        ),
                        Text(
                          isMaintenance ? "مفعل" : "غير مفعل",
                          style: Styles.inter12500Black(context).copyWith(
                            color: isMaintenance ? Colors.orange : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    SizedBox(
                      width: AppConstants.sp20(context),
                      height: AppConstants.sp20(context),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    )
                  else
                    Switch(
                      value: isMaintenance,
                      activeThumbColor: Colors.orange,
                      onChanged: (_) => context
                          .read<ToggleMaintenanceCubit>()
                          .toggleMaintenance(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
