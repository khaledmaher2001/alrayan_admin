import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/toggle_app_status/toggle_app_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Store open/closed as a settings row. Closing affects every customer,
/// so it is confirmed first; opening is immediate.
class MarketStatusToggle extends StatelessWidget {
  const MarketStatusToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ToggleAppStatusCubit, ToggleAppStatusState>(
      listener: (context, state) {
        if (state is ToggleAppStatusSuccessState) {
          context.read<GetSettingsCubit>().getSettings();
        } else if (state is ToggleAppStatusErrorState) {
          toast(text: state.error, color: DsColor.danger);
        }
      },
      builder: (context, toggleState) {
        return BlocBuilder<GetSettingsCubit, GetSettingsState>(
          builder: (context, settingsState) {
            final isOpen = context.read<GetSettingsCubit>().settingsModel?.isOpen ?? false;
            Future<void> toggle() async {
              if (isOpen &&
                  !await dsConfirm(context, title: "ds_close_store_q".tr(), message: "ds_close_store_msg".tr(), confirmLabel: "ds_close_store".tr(), destructive: true)) {
                return;
              }
              if (context.mounted) context.read<ToggleAppStatusCubit>().toggleAppStatus();
            }

            return DsSettingToggle(
              icon: Icons.storefront_outlined,
              title: "s_store_status".tr(),
              state: isOpen ? "s_open".tr() : "s_closed".tr(),
              stateColor: isOpen ? DsColor.success : DsColor.danger,
              value: isOpen,
              loading: toggleState is ToggleAppStatusLoadingState,
              onChanged: toggle,
            );
          },
        );
      },
    );
  }
}

/// Settings row with a live state line and a switch (store open, maintenance…).
class DsSettingToggle extends StatelessWidget {
  const DsSettingToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.state,
    required this.stateColor,
    required this.value,
    required this.loading,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String state;
  final Color stateColor;
  final bool value;
  final bool loading;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: '$title، $state',
      excludeSemantics: true,
      child: InkWell(
        onTap: loading ? null : onChanged,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, 10, DsSpace.md, 10),
            child: Row(
              children: [
                Icon(icon, size: DsSize.icon, color: DsColor.textMuted),
                const SizedBox(width: DsSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: DsText.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(width: 7, height: 7, decoration: BoxDecoration(color: stateColor, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(state, style: DsText.caption.copyWith(color: stateColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Center(
                    child: loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Switch(value: value, onChanged: (_) => onChanged()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
