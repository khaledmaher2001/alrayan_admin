import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/toggle_maintenance/toggle_maintenance_cubit.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/market_status_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Maintenance mode as a settings row; enabling it blocks the customer app,
/// so it is confirmed first.
class MaintenanceModeToggle extends StatelessWidget {
  const MaintenanceModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ToggleMaintenanceCubit, ToggleMaintenanceState>(
      listener: (context, state) {
        if (state is ToggleMaintenanceSuccessState) {
          context.read<GetSettingsCubit>().getSettings();
        } else if (state is ToggleMaintenanceErrorState) {
          toast(text: state.error, color: DsColor.danger);
        }
      },
      builder: (context, toggleState) {
        return BlocBuilder<GetSettingsCubit, GetSettingsState>(
          builder: (context, settingsState) {
            final on = context.read<GetSettingsCubit>().settingsModel?.maintenance ?? false;
            Future<void> toggle() async {
              if (!on &&
                  !await dsConfirm(context, title: "ds_enable_maintenance_q".tr(), message: "ds_enable_maintenance_msg".tr(), confirmLabel: "ds_enable".tr(), destructive: true)) {
                return;
              }
              if (context.mounted) context.read<ToggleMaintenanceCubit>().toggleMaintenance();
            }

            return DsSettingToggle(
              icon: Icons.construction_rounded,
              title: "s_maintenance_mode".tr(),
              state: on ? "s_enabled".tr() : "s_disabled".tr(),
              stateColor: on ? DsColor.warning : DsColor.textMuted,
              value: on,
              loading: toggleState is ToggleMaintenanceLoadingState,
              onChanged: toggle,
            );
          },
        );
      },
    );
  }
}
