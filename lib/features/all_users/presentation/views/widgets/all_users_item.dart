import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/features/all_users/data/models/all_users_model.dart';
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo_impl.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/delete_user/delete_user_cubit.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/delete_user/delete_user_state.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/get_all_users/get_all_users_cubit.dart';
import 'package:alrayan_admin/features/all_users/presentation/views/widgets/customer_analysis_bottom_sheet.dart';
import 'package:alrayan_admin/features/all_users/presentation/views/widgets/user_details_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
import '../../../../../core/utils/services/remote_services/service_locator.dart';

class AllUsersItem extends StatelessWidget {
  const AllUsersItem({super.key, required this.userData});

  final Items userData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: Container(
        padding: EdgeInsets.all(AppConstants.sp10(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: DsColor.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width * .13,
                  width: MediaQuery.of(context).size.width * .13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(.1),
                  ),
                  child: Center(
                    child: Text(
                      (userData.fullName?.isNotEmpty == true
                              ? userData.fullName!.trim().substring(0, 1)
                              : '?')
                          .toUpperCase(),
                      style: Styles.inter18500Black(
                        context,
                      ).copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.width10(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData.fullName ?? '',
                        style: Styles.inter14500black(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppConstants.height5(context)),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: AppConstants.sp10(context),
                            color: AppColors.gray,
                          ),
                          SizedBox(width: AppConstants.width5(context) / 2),
                          Expanded(
                            child: Text(
                              userData.email ?? '',
                              style: Styles.inter10400grey(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppConstants.height5(context)),
                      Row(
                        children: [
                          Icon(
                            Icons.call_outlined,
                            size: AppConstants.sp10(context),
                            color: AppColors.gray,
                          ),
                          SizedBox(width: AppConstants.width5(context) / 2),
                          Text(
                            userData.phoneNumber ?? '',
                            style: Styles.inter10400grey(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.height10(context)),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "s_view".tr(),
                      icon: Icons.visibility_outlined,
                      color: AppColors.secondaryColor,
                      onTap: () => _showUserDetails(context),
                    ),
                  ),
                  SizedBox(width: AppConstants.width5(context)),
                  VerticalDivider(
                    color: DsColor.border,
                    thickness: 1,
                    width: 1,
                  ),
                  SizedBox(width: AppConstants.width5(context)),
                  Expanded(
                    child: _ActionButton(
                      label: "s_analysis".tr(),
                      icon: Icons.bar_chart_rounded,
                      color: AppColors.secondaryColor,
                      onTap: () => _showAnalysis(context),
                    ),
                  ),
                  SizedBox(width: AppConstants.width5(context)),
                  VerticalDivider(
                    color: DsColor.border,
                    thickness: 1,
                    width: 1,
                  ),
                  SizedBox(width: AppConstants.width5(context)),
                  Expanded(
                    child: _ActionButton(
                      label: "s_delete".tr(),
                      icon: CupertinoIcons.delete,
                      color: DsColor.danger,
                      onTap: () => _confirmDelete(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => UserDetailsBottomSheet(
        userId: userData.id!,
        userData: userData,
        onDeleteRequested: () {
          Navigator.of(sheetContext).pop();
          _confirmDelete(context);
        },
      ),
    );
  }

  void _showAnalysis(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerAnalysisBottomSheet(
        userId: userData.id!,
        userName: userData.fullName ?? '',
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final listCubit = context.read<GetAllUsersCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => DeleteUserCubit(getIt.get<AllUsersRepoImpl>()),
        child: BlocConsumer<DeleteUserCubit, DeleteUserState>(
          listener: (ctx, state) {
            if (state is DeleteUserSuccess) {
              Navigator.of(dialogContext).pop();
              listCubit.removeUser(userData.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("i_x_deleted_3".tr(namedArgs: {"a": "${userData.fullName}"})),
                  backgroundColor: DsColor.success,
                ),
              );
            } else if (state is DeleteUserError) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: DsColor.danger,
                ),
              );
            }
          },
          builder: (ctx, state) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DsColor.dangerBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:SvgPicture.asset(AssetData.delete,width: MediaQuery.of(context).size.width*.08,),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "s_delete_user".tr(),
                        textAlign: TextAlign.center,
                        style: Styles.inter16500black(context)
                      ),
                    ),
                  ],
                ),
                Text(
                  "s_are_you_sure_you_want_to_delete_this_2".tr(),
                  style: Styles.inter14500black(context).copyWith(
                    color: DsColor.text2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DsColor.page,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: DsColor.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: DsColor.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userData.fullName ?? '',
                          style: Styles.inter14500black(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "s_this_action_can_t_be_undone".tr(),
                  style:Styles.inter14500black(context).copyWith(
                    color: DsColor.danger,
                  ),
                ),
                SizedBox(height: AppConstants.height20(context)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DsColor.danger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: state is DeleteUserLoading
                            ? null
                            : () => ctx.read<DeleteUserCubit>().deleteUser(
                                userData.id!,
                              ),
                        child: state is DeleteUserLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "s_delete".tr(),
                                style: Styles.inter16500black(
                                  context,
                                ).copyWith(color: Colors.white),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: state is DeleteUserLoading
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        "s_cancel".tr(),
                        style: Styles.inter16500black(
                          context,
                        ).copyWith(color: DsColor.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppConstants.height10(context) / 1.5,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.sp10(context) / 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(.2),
                  borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                ),
                child: Icon(icon, size: AppConstants.sp20(context), color: color)),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.sp10(context),
                color: color,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
