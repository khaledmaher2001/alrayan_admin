import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/search_widget.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_accounts/get_delivery_accounts_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_account_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeliveryAccountsViewBody extends StatefulWidget {
  const DeliveryAccountsViewBody({super.key});

  @override
  State<DeliveryAccountsViewBody> createState() =>
      _DeliveryAccountsViewBodyState();
}

class _DeliveryAccountsViewBodyState extends State<DeliveryAccountsViewBody> {
  final ScrollController scrollController = ScrollController();
  final searchController = TextEditingController();
  bool isLoadingMore = false;

  static const _sortOptions = [
    'createdAt',
    'earningPercentage',
    'walletBalance',
    'vehicleName',
  ];

  Future<void> _pagination() async {
    final cubit = context.read<GetDeliveryAccountsCubit>();
    final totalPages = cubit.accountsModel?.data?.metadata?.totalPages;
    if (totalPages == null) return;

    if (cubit.page < totalPages &&
        scrollController.position.maxScrollExtent ==
            scrollController.position.pixels &&
        !isLoadingMore) {
      isLoadingMore = true;
      cubit.page++;
      await cubit
          .getDeliveryAccounts(withLoading: false)
          .then((_) => setState(() => isLoadingMore = false));
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_pagination);
  }

  @override
  void dispose() {
    scrollController.removeListener(_pagination);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppConstants.width15(context),
          ),
          child: SearchWidget(
            hint: "search_courier_hint".tr(),
            searchController: searchController,
            onSearch: (value) => context
                .read<GetDeliveryAccountsCubit>()
                .getDeliveryAccounts(keyword: value.trim(), withLoading: true),
          ),
        ),
        SizedBox(height: AppConstants.height10(context)),
        // Padding(
        //   padding: EdgeInsets.symmetric(
        //     horizontal: AppConstants.width20(context),
        //   ),
        //   child: _SortRow(sortOptions: _sortOptions),
        // ),
        // SizedBox(height: AppConstants.height10(context)),
        Expanded(
          child:
              BlocBuilder<GetDeliveryAccountsCubit, GetDeliveryAccountsStates>(
                builder: (context, state) {
                  if (state is GetDeliveryAccountsErrorState) {
                    return _ErrorState(
                      message: state.message,
                      onRetry: () => context
                          .read<GetDeliveryAccountsCubit>()
                          .getDeliveryAccounts(withLoading: true),
                    );
                  }

                  if (state is GetDeliveryAccountsSuccessState) {
                    final list = context
                        .read<GetDeliveryAccountsCubit>()
                        .accountsList;
                    if (list.isEmpty) {
                      return Center(
                        child: SvgPicture.asset(AssetData.emptyCategory),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => context
                          .read<GetDeliveryAccountsCubit>()
                          .getDeliveryAccounts(withLoading: true),
                      child: ListView.separated(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
                        itemCount: list.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: AppConstants.height15(context)),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              if (index == 0)
                                SizedBox(height: AppConstants.height5(context)),
                              DeliveryAccountItem(account: list[index]),
                              if (isLoadingMore && index == list.length - 1)
                                Padding(
                                  padding: EdgeInsets.all(
                                    AppConstants.sp10(context),
                                  ),
                                  child: CustomLoadingItem(
                                    size:
                                        MediaQuery.of(context).size.width *
                                        0.08,
                                  ),
                                ),
                              if (index == list.length - 1)
                                SizedBox(
                                  height: AppConstants.height30(context),
                                ),
                            ],
                          );
                        },
                      ),
                    );
                  }

                  return const CustomLoadingItem();
                },
              ),
        ),
      ],
    );
  }
}

// class _SortRow extends StatelessWidget {
//   const _SortRow({required this.sortOptions});
//
//   final List<String> sortOptions;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<GetDeliveryAccountsCubit, GetDeliveryAccountsStates>(
//       builder: (context, state) {
//         final cubit = context.read<GetDeliveryAccountsCubit>();
//         return Row(
//           children: [
//             Text("sort_by".tr(), style: Styles.inter12500Black(context)),
//             SizedBox(width: AppConstants.width10(context)),
//             Expanded(
//               child: SizedBox(
//                 height: AppConstants.height30(context) * 1.4,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: sortOptions.length,
//                   separatorBuilder: (_, _) =>
//                       SizedBox(width: AppConstants.width10(context)),
//                   itemBuilder: (context, index) {
//                     final option = sortOptions[index];
//                     final selected = cubit.sortBy == option;
//                     return GestureDetector(
//                       onTap: () => cubit.getDeliveryAccounts(
//                         sortBy: option,
//                         withLoading: true,
//                       ),
//                       child: Container(
//                         alignment: Alignment.center,
//                         padding: EdgeInsets.symmetric(
//                           horizontal: AppConstants.width15(context),
//                         ),
//                         decoration: BoxDecoration(
//                           color: selected
//                               ? AppColors.primaryColor
//                               : Colors.transparent,
//                           border: Border.all(
//                             color: selected
//                                 ? AppColors.primaryColor
//                                 : Colors.grey.shade400,
//                           ),
//                           borderRadius: BorderRadius.circular(
//                             AppConstants.sp30(context),
//                           ),
//                         ),
//                         child: Text(
//                           "sort_$option".tr(),
//                           style: Styles.inter14500black(context).copyWith(
//                             color: selected
//                                 ? Colors.white
//                                 : Colors.grey.shade700,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () => cubit.getDeliveryAccounts(
//                 sortOrder: cubit.sortOrder == 'ASC' ? 'DESC' : 'ASC',
//                 withLoading: true,
//               ),
//               icon: Icon(
//                 cubit.sortOrder == 'ASC'
//                     ? Icons.arrow_upward
//                     : Icons.arrow_downward,
//                 size: AppConstants.sp20(context),
//                 color: AppColors.primaryColor,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width20(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Styles.inter14500black(context),
            ),
            SizedBox(height: AppConstants.height15(context)),
            ElevatedButton(onPressed: onRetry, child: Text("retry".tr())),
          ],
        ),
      ),
    );
  }
}
