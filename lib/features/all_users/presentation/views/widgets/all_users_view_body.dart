import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/search_widget.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/shared_widgets/custom_loading_item.dart';
import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/constants.dart';
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
          CustomAppBar(
            title: 'جميع عملاء ماركت الريان',
            textColor: Colors.black,
            hasBack: true,
            withNotifications: false,
          ),
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
          SizedBox(height: AppConstants.height20(context)),
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
