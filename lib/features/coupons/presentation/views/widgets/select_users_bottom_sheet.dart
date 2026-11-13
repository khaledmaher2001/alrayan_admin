import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/features/all_users/presentation/view_models/get_all_users/get_all_users_cubit.dart';
import 'package:alrayan_admin/features/all_users/presentation/view_models/get_all_users/get_all_users_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/shared_widgets/empty_widget.dart';
import '../../../../../../core/utils/assets/assets.dart';
import '../../../../../../core/utils/colors/colors.dart';
import '../../../../../../core/utils/constants.dart';
import '../../../../../../core/utils/text_styles/styles.dart';
import '../../../../../core/shared_widgets/default_text_form_field.dart';
import '../view_model/create_coupon_assets/create_coupon_assets_cubit.dart';

class SelectUsersBottomSheet extends StatefulWidget {
  const SelectUsersBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      useSafeArea: true,
      builder: (context) {
        return SelectUsersBottomSheet();
      },
    );
  }

  @override
  State<SelectUsersBottomSheet> createState() =>
      _SelectUsersBottomSheetState();
}

class _SelectUsersBottomSheetState extends State<SelectUsersBottomSheet> {
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool show = false;

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<GetAllUsersCubit>().loadMore();
    }
  }

  @override
  void initState() {
    scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: Column(
                children: [
                  SizedBox(height: AppConstants.height10(context)),
                  Container(
                    height: AppConstants.height5(context),
                    width: MediaQuery.sizeOf(context).width * .45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.width20(context),
                      ),
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  Text(
                    "s_choose_users_2".tr(),
                    style: Styles.inter16400white(
                      context,
                    ).copyWith(color: Colors.black),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  DefaultTextFormField(
                    textInputType: TextInputType.text,
                    controller: searchController,
                    hintText: "s_search_for_a_user".tr(),
                    onFilledSubmit: (value) {
                      context.read<GetAllUsersCubit>().getAllUsers(
                        keyword: value.trim(),
                      );
                    },
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CreateCouponAssetsCubit, CreateCouponAssetsState>(
                builder: (context, assetState) {
                  return BlocBuilder<GetAllUsersCubit, GetAllUsersStates>(
                    builder: (context, state) {
                      if (state is GetAllUsersSuccessState) {
                        return Column(
                          children: [
                            Expanded(
                              child:
                              context
                                  .read<GetAllUsersCubit>()
                                  .allUsersList
                                  .isNotEmpty
                                  ? ListView.separated(
                                controller: scrollController,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      if (index == 0)
                                        SizedBox(
                                          height: AppConstants.height10(
                                            context,
                                          ),
                                        ),

                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                          AppConstants.width20(
                                            context,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            if (context
                                                .read<
                                                CreateCouponAssetsCubit
                                            >()
                                                .selectedUsers
                                                .contains(
                                              context
                                                  .read<
                                                  GetAllUsersCubit
                                              >()
                                                  .allUsersList[index],
                                            )) {
                                              context
                                                  .read<
                                                  CreateCouponAssetsCubit
                                              >()
                                                  .removeUser(
                                                instance: context
                                                    .read<
                                                    GetAllUsersCubit
                                                >()
                                                    .allUsersList[index],
                                              );
                                            } else {
                                              context
                                                  .read<
                                                  CreateCouponAssetsCubit
                                              >()
                                                  .selectUser(
                                                instance: context
                                                    .read<
                                                    GetAllUsersCubit
                                                >()
                                                    .allUsersList[index],
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              AppConstants.sp10(context),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: DsColor.border),
                                              borderRadius:
                                              BorderRadius.circular(
                                                AppConstants.sp10(
                                                  context,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: MediaQuery.of(context).size.width * 0.065, // نصف عرض الصورة القديمة
                                                  backgroundColor: DsColor.primarySoft, // initials avatar: one neutral brand tint, not a random colour
                                                  child: Text(
                                                    (context.read<GetAllUsersCubit>().allUsersList[index].fullName ?? '')
                                                        .split(' ')
                                                        .take(2)
                                                        .map((e) => e.isNotEmpty ? e[0] : '')
                                                        .join()
                                                        .toUpperCase(), // أول حرفين من الاسم
                                                    style: TextStyle(
                                                      color: DsColor.onPrimarySoft,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: AppConstants.width10(context),),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        context
                                                            .read<
                                                            GetAllUsersCubit
                                                        >()
                                                            .allUsersList[index]
                                                            .fullName ??
                                                            '',
                                                        style:
                                                        Styles.inter16500black(
                                                          context,
                                                        ),
                                                      ),
                                                      Text(
                                                        context
                                                            .read<
                                                            GetAllUsersCubit
                                                        >()
                                                            .allUsersList[index]
                                                            .phoneNumber ??
                                                            context
                                                            .read<GetAllUsersCubit>()
                                                            .allUsersList[index]
                                                            .email ??
                                                            '',
                                                        style:
                                                        Styles.inter14600gray(
                                                          context,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                context
                                                    .read<
                                                    CreateCouponAssetsCubit
                                                >()
                                                    .selectedUsers
                                                    .contains(
                                                  context
                                                      .read<
                                                      GetAllUsersCubit
                                                  >()
                                                      .allUsersList[index],
                                                )
                                                    ? SvgPicture.asset(
                                                  AssetData.checked,
                                                  color: AppColors
                                                      .primaryColor,
                                                )
                                                    : SvgPicture.asset(
                                                  AssetData.uncheck,
                                                  color: AppColors
                                                      .gray,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                    height: AppConstants.height10(
                                      context,
                                    ),
                                  );
                                },
                                itemCount: context
                                    .read<GetAllUsersCubit>()
                                    .allUsersList
                                    .length,
                              )
                                  : EmptyWidget(
                                icon: AssetData.search,
                                title: "s_no_items".tr(),
                                description:
                                "s_you_ll_be_notified_when_items_are_ad".tr(),
                              ),
                            ),
                            if (context
                                .read<GetAllUsersCubit>()
                                .isLoadingMore)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppConstants.height10(context),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        );
                      } else {
                        return ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.width20(context),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.sp10(context),
                                ),
                                child: Shimmer.fromColors(
                                  baseColor: DsColor.border!,
                                  highlightColor: DsColor.border!,
                                  child: Container(
                                    height:
                                    MediaQuery.of(context).size.height *
                                        .11,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: DsColor.textMuted,
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.sp5(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: AppConstants.height10(context),
                            );
                          },
                          itemCount: 5,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
