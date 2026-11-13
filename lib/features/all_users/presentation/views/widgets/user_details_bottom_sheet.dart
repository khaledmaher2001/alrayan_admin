import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/all_users/data/models/all_users_model.dart';
import 'package:alrayan_admin/features/all_users/data/models/user_detail_model.dart';
import 'package:alrayan_admin/features/all_users/data/repo/all_users_repo_impl.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/get_user_details/get_user_details_cubit.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/get_user_details/get_user_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../core/utils/services/remote_services/service_locator.dart';

class UserDetailsBottomSheet extends StatelessWidget {
  const UserDetailsBottomSheet({
    super.key,
    required this.userId,
    required this.userData,
    required this.onDeleteRequested,
  });

  final int userId;
  final Items userData;
  final VoidCallback onDeleteRequested;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetUserDetailsCubit(getIt.get<AllUsersRepoImpl>())
        ..getUserById(userId),
      child: _UserDetailsSheetBody(
        userData: userData,
        onDeleteRequested: onDeleteRequested,
      ),
    );
  }
}

class _UserDetailsSheetBody extends StatelessWidget {
  const _UserDetailsSheetBody({
    required this.userData,
    required this.onDeleteRequested,
  });

  final Items userData;
  final VoidCallback onDeleteRequested;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: AppConstants.height15(context)),
          Center(
            child: Container(
              height: AppConstants.height5(context),
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                color: DsColor.border,
              ),
            ),
          ),
          SizedBox(height: AppConstants.height15(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Row(
              children: [
                Text("s_user_details".tr(), style: Styles.inter16500black(context)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(color: DsColor.fill),
          Expanded(
            child: BlocBuilder<GetUserDetailsCubit, GetUserDetailsState>(
              builder: (context, state) {
                if (state is GetUserDetailsLoading || state is GetUserDetailsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GetUserDetailsError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: DsColor.danger, size: 40),
                        SizedBox(height: AppConstants.height10(context)),
                        Text(state.message, style: Styles.inter12500Black(context)),
                      ],
                    ),
                  );
                }
                if (state is GetUserDetailsSuccess) {
                  return _UserDetailsContent(
                    user: state.user,
                    basicData: userData,
                    onDeleteRequested: onDeleteRequested,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDetailsContent extends StatelessWidget {
  const _UserDetailsContent({
    required this.user,
    required this.basicData,
    required this.onDeleteRequested,
  });

  final UserDetailModel user;
  final Items basicData;
  final VoidCallback onDeleteRequested;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.height10(context)),
          // Avatar + Name
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .15,
                height: MediaQuery.of(context).size.width * .15,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                ),
                child: Center(
                  child: Text(
                    (user.fullName?.isNotEmpty == true
                            ? user.fullName!.trim().substring(0, 1)
                            : '?')
                        .toUpperCase(),
                    style: Styles.inter18500Black(context)
                        .copyWith(color: AppColors.primaryColor),
                  ),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName ?? '', style: Styles.inter16500black(context)),
                    SizedBox(height: AppConstants.height5(context)),
                    Text(user.email ?? '', style: Styles.inter10400grey(context)),
                    SizedBox(height: AppConstants.height5(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.width10(context),
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DsColor.successBg,
                        borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                      ),
                      child: Text(
                        user.isEmailVerified == true ? "s_verified_email".tr() : "s_not_verified".tr(),
                        style: TextStyle(
                          fontSize: AppConstants.sp10(context),
                          color: user.isEmailVerified == true
                              ? DsColor.success
                              : DsColor.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height20(context)),
          // Info grid
          _SectionTitle(title: "s_basic_details".tr()),
          SizedBox(height: AppConstants.height10(context)),
          _InfoGrid(items: [
            _InfoItem(
              label: "s_gender".tr(),
              value: _genderAr(user.gender),
              icon: Icons.person_outline_rounded,
            ),
            _InfoItem(
              label: "s_phone".tr(),
              value: user.phoneNumber ?? '—',
              icon: Icons.call_outlined,
            ),
            _InfoItem(
              label: "s_email_verified".tr(),
              value: user.isEmailVerified == true ? "s_yes".tr() : "s_no".tr(),
              icon: Icons.email_outlined,
            ),
            _InfoItem(
              label: "s_role".tr(),
              value: user.role ?? '—',
              icon: Icons.gpp_good_outlined,
            ),
            _InfoItem(
              label: "s_created_on".tr(),
              value: _formatDate(user.createdAt),
              icon: Icons.calendar_today_outlined,
            ),
            _InfoItem(
              label: "s_last_login".tr(),
              value: _formatDate(user.lastLoginAt),
              icon: Icons.login_rounded,
            ),
          ]),
          // Addresses
          if (user.addresses != null && user.addresses!.isNotEmpty) ...[
            SizedBox(height: AppConstants.height20(context)),
            _SectionTitle(title: "s_saved_addresses".tr()),
            SizedBox(height: AppConstants.height10(context)),
            ...user.addresses!.map((addr) => _AddressCard(address: addr)),
          ],
          SizedBox(height: AppConstants.height20(context)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDeleteRequested,
              style: OutlinedButton.styleFrom(
                foregroundColor: DsColor.danger,
                side: const BorderSide(color: DsColor.danger),
                padding: EdgeInsets.symmetric(
                  vertical: AppConstants.height10(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.sp10(context),
                  ),
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(
                "s_delete_customer".tr(),
                style: Styles.inter14600black(
                  context,
                ).copyWith(color: DsColor.danger),
              ),
            ),
          ),
          SizedBox(height: AppConstants.height20(context)),
        ],
      ),
    );
  }

  String _genderAr(String? g) {
    if (g == null) return '—';
    if (g == 'male') return "s_male".tr();
    if (g == 'female') return "s_female".tr();
    return g;
  }

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return "${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: AppConstants.width5(context)),
        Text(title, style: Styles.inter14500black(context)),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.width10(context),
      runSpacing: AppConstants.height10(context),
      children: items
          .map(
            (item) => SizedBox(
              width: (MediaQuery.of(context).size.width -
                      AppConstants.width20(context) * 2 -
                      AppConstants.width10(context)) /
                  2,
              child: Container(
                padding: EdgeInsets.all(AppConstants.sp10(context)),
                decoration: BoxDecoration(
                  color: DsColor.page,
                  borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                  border: Border.all(color: DsColor.fill),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          item.icon,
                          size: AppConstants.sp15(context),
                          color: AppColors.gray,
                        ),
                        SizedBox(width: AppConstants.width5(context) / 2),
                        Text(item.label, style: Styles.inter10400grey(context)),
                      ],
                    ),
                    SizedBox(height: AppConstants.height5(context)),
                    Text(
                      item.value,
                      style: Styles.inter12500Black(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
  final UserAddress address;

  @override
  Widget build(BuildContext context) {
    final hasLocation =
        (address.latitude?.isNotEmpty ?? false) &&
        (address.longitude?.isNotEmpty ?? false);
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.height10(context)),
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(
        color: DsColor.page,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (address.isDefault == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "s_default".tr(),
                    style: TextStyle(
                      fontSize: AppConstants.sp10(context),
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                address.title ?? '—',
                style: Styles.inter12500Black(context),
              ),
              SizedBox(width: AppConstants.width5(context) / 2),
              Icon(
                Icons.location_on,
                color: AppColors.primaryColor,
                size: AppConstants.sp15(context),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Text(
            address.description ?? '—',
            style: Styles.inter10400grey(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasLocation) ...[
            SizedBox(height: AppConstants.height10(context)),
            InkWell(
              onTap: () => launchUrlString(
                "https://www.google.com/maps/search/?api=1&query=${address.latitude},${address.longitude}",
              ),
              borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
              child: Container(
                padding: EdgeInsets.all(AppConstants.sp5(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.sp5(context)),
                  border: Border.all(color: DsColor.border),
                ),
                child: Icon(
                  Icons.map_outlined,
                  size: AppConstants.sp15(context),
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
