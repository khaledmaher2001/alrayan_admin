import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/search_widget.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/orders/presentation/view/widgets/awaiting_customer_order_item.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_awaiting_customer_orders/get_awaiting_customer_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_awaiting_customer_orders/get_awaiting_customer_orders_states.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AwaitingCustomerOrdersViewBody extends StatefulWidget {
  const AwaitingCustomerOrdersViewBody({super.key});

  @override
  State<AwaitingCustomerOrdersViewBody> createState() =>
      _AwaitingCustomerOrdersViewBodyState();
}

class _AwaitingCustomerOrdersViewBodyState
    extends State<AwaitingCustomerOrdersViewBody> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<GetAwaitingCustomerOrdersCubit>().loadMore();
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width20(context),
          ),
          child: SearchWidget(
            hint: "s_search_by_order_number_customer_name".tr(),
            searchController: searchController,
            onSearch: (value) => setState(
              () =>
                  context
                          .read<GetAwaitingCustomerOrdersCubit>()
                          .clientSearchQuery =
                      value,
            ),
          ),
        ),
        SizedBox(height: AppConstants.height15(context)),
        Expanded(
          child:
              BlocBuilder<
                GetAwaitingCustomerOrdersCubit,
                GetAwaitingCustomerOrdersStates
              >(
                builder: (context, state) {
                  if (state is GetAwaitingCustomerOrdersErrorState) {
                    return _ErrorView(message: state.message);
                  }

                  if (state is GetAwaitingCustomerOrdersSuccessState) {
                    final cubit = context
                        .read<GetAwaitingCustomerOrdersCubit>();
                    final list = cubit.visibleOrders;
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: AppConstants.width15(context),
                          ),
                          child: _SummaryCard(count: cubit.totalCount),
                        ),
                        SizedBox(height: AppConstants.height15(context)),
                        Expanded(
                          child: list.isEmpty
                              ? _EmptyView(
                                  isSearching: (cubit.clientSearchQuery ?? '')
                                      .trim()
                                      .isNotEmpty,
                                )
                              : RefreshIndicator(
                                  onRefresh: () =>
                                      cubit.getOrders(withLoading: true),
                                  child: ListView.separated(
                                    controller: scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: list.length,
                                    separatorBuilder: (_, _) => SizedBox(
                                      height: AppConstants.height15(context),
                                    ),
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          AwaitingCustomerOrderItem(
                                            order: list[index],
                                          ),
                                          if (context
                                                  .read<
                                                      GetAwaitingCustomerOrdersCubit>()
                                                  .isLoadingMore &&
                                              index == list.length - 1)
                                            Padding(
                                              padding: EdgeInsets.all(
                                                AppConstants.sp10(context),
                                              ),
                                              child: CustomLoadingItem(
                                                size:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.08,
                                              ),
                                            ),
                                          if (index == list.length - 1)
                                            SizedBox(
                                              height: AppConstants.height30(
                                                context,
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.sp10(context)),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: const Icon(
              Icons.person_pin_circle_rounded,
              color: Colors.white,
            ),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "s_orders_waiting_for_the_customer".tr(),
                  style: Styles.inter16500black(context),
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$count ",
                        style: Styles.inter14500black(context).copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: "s_order_needs_admin_action".tr(),
                        style: Styles.inter14500black(
                          context,
                        ).copyWith(color: const Color(0xff9CA4AB)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

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
            Icon(Icons.error_outline, color: DsColor.danger, size: 48),
            SizedBox(height: AppConstants.height10(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Styles.inter14500black(context),
            ),
            SizedBox(height: AppConstants.height15(context)),
            ElevatedButton(
              onPressed: () => context
                  .read<GetAwaitingCustomerOrdersCubit>()
                  .getOrders(withLoading: true),
              child: Text("retry".tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 64, color: DsColor.textSubtle),
              SizedBox(height: AppConstants.height15(context)),
              Text(
                isSearching
                    ? "s_no_matching_orders".tr()
                    : "s_no_orders_waiting_for_the_customer_r".tr(),
                textAlign: TextAlign.center,
                style: Styles.inter14500black(
                  context,
                ).copyWith(color: const Color(0xff9CA4AB)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
