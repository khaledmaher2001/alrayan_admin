import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/get_settings/get_settings_cubit.dart';
import 'package:alrayan_admin/features/auth/presentation/view_model/toggle_app_status/toggle_app_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarketStatusToggle extends StatelessWidget {
  const MarketStatusToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ToggleAppStatusCubit, ToggleAppStatusState>(
      listener: (context, state) {
        if (state is ToggleAppStatusSuccessState) {
          context.read<GetSettingsCubit>().getSettings();
        } else if (state is ToggleAppStatusErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, toggleState) {
        return BlocBuilder<GetSettingsCubit, GetSettingsState>(
          builder: (context, settingsState) {
            final isOpen =
                context.read<GetSettingsCubit>().settingsModel?.isOpen ?? false;
            final isLoading = toggleState is ToggleAppStatusLoadingState;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.sp20(context),
                vertical: AppConstants.sp10(context),
              ),
              decoration: BoxDecoration(
                color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                border: Border.all(
                  color: isOpen ? Colors.green : AppColors.primarySwatchColor,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppConstants.sp10(context)),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.white : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        AppConstants.sp10(context),
                      ),
                    ),
                    child: SvgPicture.asset(
                      isOpen ? AssetData.open : AssetData.closed,
                      width: MediaQuery.of(context).size.width * .08,
                    ),
                  ),
                  SizedBox(width: AppConstants.width10(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "حالة المتجر",
                          style: Styles.inter14500black(context),
                        ),
                        Text(
                          isOpen ? "مفتوح" : "مغلق",
                          style: Styles.inter12500Black(
                            context,
                          ).copyWith(color: isOpen ? Colors.green : Colors.red),
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
                      value: isOpen,
                      activeThumbColor: Colors.green,
                      onChanged: (_) => context
                          .read<ToggleAppStatusCubit>()
                          .toggleAppStatus(),
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
