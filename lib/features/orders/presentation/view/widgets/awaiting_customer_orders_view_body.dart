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
  bool isLoadingMore = false;

  Future<void> _pagination() async {
    final cubit = context.read<GetAwaitingCustomerOrdersCubit>();
    final totalPages = cubit.ordersModel?.data?.metadata?.totalPages;
    if (totalPages == null) return;

    if (cubit.page < totalPages &&
        scrollController.position.maxScrollExtent ==
            scrollController.position.pixels &&
        !isLoadingMore) {
      isLoadingMore = true;
      cubit.page++;
      await cubit
          .getOrders(withLoading: false)
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
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.width20(context),
          ),
          child: SearchWidget(
            hint: "ابحث برقم الطلب أو اسم العميل أو الهاتف",
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
                                          if (isLoadingMore &&
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
                  "طلبات بانتظار العميل",
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
                        text: "طلب يحتاج تدخل الإدارة",
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
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
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
              Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
              SizedBox(height: AppConstants.height15(context)),
              Text(
                isSearching
                    ? "لا توجد طلبات مطابقة"
                    : "لا توجد طلبات بانتظار العميل حاليًا",
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
