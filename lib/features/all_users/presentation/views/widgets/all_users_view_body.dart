import 'package:alrayan_admin/core/shared_widgets/search_widget.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/shared_widgets/custom_loading_item.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/navigation_utility.dart';
import '../../view_models/get_all_users/get_all_users_cubit.dart';
import '../../view_models/get_all_users/get_all_users_states.dart';
import 'all_users_item.dart';

class AllUsersViewBody extends StatefulWidget {
  const AllUsersViewBody({super.key});

  @override
  State<AllUsersViewBody> createState() => _AllUsersViewBodyState();
}

class _AllUsersViewBodyState extends State<AllUsersViewBody> {
  ScrollController scrollController = ScrollController();
  var searchController = TextEditingController();
  bool isLoading = false;

  Future<void> pagination() async {
    final cubit = context.read<GetAllUsersCubit>();
    if (cubit.page < cubit.allUsersModel!.data!.metadata!.totalPages! &&
        scrollController.position.maxScrollExtent ==
            scrollController.position.pixels &&
        !isLoading) {
      isLoading = true;
      setState(() {
        cubit.page++;
      });
      await cubit
          .getAllUsers(
            withLoading: false,
            data: {
              "page":cubit.page,
              "limit": 12,
            },
          )
          .then((value) {
            setState(() {
              isLoading = false;
            });
          });
    }
  }

  @override
  void initState() {
    scrollController.addListener(pagination);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height20(context)),
          const _UsersHeader(),
          SizedBox(height: AppConstants.height20(context)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width20(context),
            ),
            child: SearchWidget(
              hint: "ابحث عن عميل محدد",
              searchController: searchController,
              onSearch: (value) {
                context.read<GetAllUsersCubit>().getAllUsers(
                  data: {
                    "keyword": searchController.text.trim(),
                    "page": 1,
                    "limit": 12,
                  },
                );
              },
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          BlocBuilder<GetAllUsersCubit, GetAllUsersStates>(
            builder: (context, state) {
              final totalItems = context
                  .read<GetAllUsersCubit>()
                  .allUsersModel
                  ?.data
                  ?.metadata
                  ?.totalItems;
              if (totalItems == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width20(context),
                ),
                child: _UsersSummaryCard(totalItems: totalItems),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<GetAllUsersCubit, GetAllUsersStates>(
              builder: (context, state) {
                if (state is GetAllUsersSuccessState) {
                  return context
                          .read<GetAllUsersCubit>()
                          .allUsersList
                          .isNotEmpty
                      ? Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  searchController.clear();
                                  await context
                                      .read<GetAllUsersCubit>()
                                      .getAllUsers(
                                        data: {
                                          "page": 1,
                                          "limit": 12,},
                                      );
                                },
                                child: ListView.separated(
                                  controller: scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (context
                                        .read<GetAllUsersCubit>()
                                        .allUsersList
                                        .isNotEmpty) {
                                      return Column(
                                        children: [
                                          if(index==0)
                                            SizedBox(height: AppConstants.height10(context),),
                                          AllUsersItem(
                                            userData: context
                                                .read<GetAllUsersCubit>()
                                                .allUsersList[index],
                                          ),
                                          if (index ==
                                              context
                                                      .read<GetAllUsersCubit>()
                                                      .allUsersList
                                                      .length -
                                                  1)
                                            SizedBox(
                                              height: AppConstants.height20(
                                                context,
                                              ),
                                            ),
                                        ],
                                      );
                                    } else {
                                      return const Center(
                                        child: Text(
                                          'No items found for this order.',
                                        ),
                                      );
                                    }
                                  },
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                        height: AppConstants.height15(context),
                                      ),
                                  itemCount: context
                                      .read<GetAllUsersCubit>()
                                      .allUsersList
                                      .length,
                                ),
                              ),
                            ),

                            if (isLoading)
                              Padding(
                                padding: EdgeInsets.all(
                                  AppConstants.sp10(context),
                                ),
                                child: CustomLoadingItem(
                                  size:
                                      MediaQuery.of(context).size.width * 0.08,
                                ),
                              ),
                          ],
                        )
                      : Center(
                          child: SvgPicture.asset(AssetData.emptyCategory),
                        );
                }
                return const CustomLoadingItem();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersHeader extends StatelessWidget {
  const _UsersHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Text('العملاء', style: Styles.inter18500Black(context)),
              SizedBox(height: AppConstants.height5(context) / 2),
              Text(
                'جميع عملاء ماركت الريان',
                style: Styles.inter10400grey(context),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: InkWell(
              onTap: () => NavigationUtils.navigateBack(context: context),
              child: Container(
                height: AppConstants.width20(context) * 2.2,
                width: AppConstants.width20(context) * 2.2,
                padding: EdgeInsets.all(AppConstants.sp5(context)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gray.withOpacity(.2),
                ),
                child: SvgPicture.asset(
                  AssetData.back,
                  color: Colors.black,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersSummaryCard extends StatelessWidget {
  const _UsersSummaryCard({required this.totalItems});

  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ملخص العملاء", style: Styles.inter14600black(context)),
          SizedBox(height: AppConstants.height5(context) / 2),
          Text("نظرة سريعة", style: Styles.inter10400grey(context)),
          SizedBox(height: AppConstants.height10(context)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.sp10(context)),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppConstants.sp10(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.sp10(context),
                    ),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: AppColors.secondaryColor,
                    size: AppConstants.sp20(context),
                  ),
                ),
                SizedBox(width: AppConstants.width10(context)),
                Text(
                  "إجمالي العملاء",
                  style: Styles.inter14500black(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const Spacer(),
                Text(
                  "$totalItems",
                  style: Styles.inter18500Black(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
