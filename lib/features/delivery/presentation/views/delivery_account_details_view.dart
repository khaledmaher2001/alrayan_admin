import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/data/models/delivery_account_model.dart';
import 'package:alrayan_admin/features/delivery/data/models/delivery_transaction_model.dart';
import 'package:alrayan_admin/features/delivery/data/repo/delivery_repo_impl.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_orders/get_delivery_orders_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_orders/get_delivery_orders_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_transactions/get_delivery_transactions_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_transactions/get_delivery_transactions_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_wallet/get_delivery_wallet_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_delivery_wallet/get_delivery_wallet_state.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_order_details_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/delivery_orders_view.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/delivery_account_form_sheet.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/extra_fields_section.dart';
import 'package:alrayan_admin/features/orders/data/models/orders_model.dart';
import 'package:alrayan_admin/features/orders/data/repo/orders_repo_impl.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// تفاصيل مندوب التوصيل — بطاقة الملف الشخصي أعلى الصفحة، وأسفلها أربعة
/// تبويبات: نظرة عامة، الطلبات، المحفظة، والمعاملات المالية (المعروضة
/// افتراضيًا).
class DeliveryAccountDetailsView extends StatefulWidget {
  const DeliveryAccountDetailsView({super.key, required this.account});

  final DeliveryAccount account;

  @override
  State<DeliveryAccountDetailsView> createState() =>
      _DeliveryAccountDetailsViewState();
}

class _DeliveryAccountDetailsViewState
    extends State<DeliveryAccountDetailsView> {
  /// Tabs in on-screen (visual) order, right to left: overview, orders,
  /// wallet, transactions. Transactions is the default landing tab.
  int selectedTab = 3;

  DeliveryAccount get account => widget.account;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GetDeliveryWalletCubit(getIt<DeliveryRepoImpl>())
                ..getWallet(account.userId!),
        ),
        BlocProvider(
          create: (_) =>
              GetDeliveryTransactionsCubit(getIt<DeliveryRepoImpl>())
                ..getTransactions(userId: account.userId!, withLoading: true),
        ),
        BlocProvider(
          create: (_) => GetDeliveryOrdersCubit(getIt<OrdersRepoImpl>())
            ..setFilters({
              'deliveryUserId': account.userId,
              'finished': 'false',
            })
            ..getDeliveryOrders(withLoading: true),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7F8),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: AppConstants.height10(context)),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
                child: _DetailsHeader(account: account),
              ),
              SizedBox(height: AppConstants.height15(context)),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
                child: _ProfileCard(account: account),
              ),
              SizedBox(height: AppConstants.height20(context)),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
                child: _CourierTabBar(
                  selectedIndex: selectedTab,
                  onChanged: (index) => setState(() => selectedTab = index),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: AppConstants.width15(context),
                    vertical: AppConstants.height15(context),
                  ),
                  // Each tab gets its own SingleChildScrollView (and so its
                  // own scroll position) instead of sharing one scroll view
                  // around the whole IndexedStack — otherwise switching
                  // away from a tall tab (e.g. transactions) while scrolled
                  // down left the shorter tabs' content scrolled out of
                  // view above the viewport.
                  child: IndexedStack(
                    index: selectedTab,
                    children: [
                      SingleChildScrollView(child: _OverviewTab(account: account)),
                      SingleChildScrollView(child: _OrdersTab(account: account)),
                      SingleChildScrollView(child: _WalletTab(account: account)),
                      SingleChildScrollView(child: _TransactionsTab(account: account)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.account});

  final DeliveryAccount account;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("courier_details".tr(),textAlign: TextAlign.center, style: Styles.inter18500Black(context))),
              ],
            ),
            SizedBox(height: AppConstants.height5(context) / 2),
            Text(
              "s_all_delivery_details".tr(),
              style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
            ),
          ],
        ),
        PositionedDirectional(
          start: 0,
          child: _HeaderCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => NavigationUtils.navigateBack(context: context),
          ),
        ),
        PositionedDirectional(
          end: 0,
          child: _HeaderCircleButton(
            icon: Icons.edit_rounded,
            onTap: () => showDeliveryAccountFormSheet(
              context: context,
              account: account,
              onSuccess: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: AppConstants.width20(context) * 2.2,
        height: AppConstants.width20(context) * 2.2,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.gray.withValues(alpha: .15)),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.account});

  final DeliveryAccount account;

  @override
  Widget build(BuildContext context) {
    final isAvailable = account.isAvailableForDelivery;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.secondaryColor),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.sp15(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.fullName.isNotEmpty ? account.fullName : "-",
                                style: Styles.inter18500Black(context),
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              if (isAvailable != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstants.width10(context),
                                    vertical: AppConstants.height5(context) / 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isAvailable ? DsColor.success : DsColor.textMuted)
                                        .withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.sp30(context),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: isAvailable
                                            ? DsColor.success
                                            : DsColor.textMuted,
                                      ),
                                      SizedBox(width: AppConstants.width5(context) / 2),
                                      Text(
                                        isAvailable
                                            ? "courier_available".tr()
                                            : "courier_unavailable".tr(),
                                        style: Styles.inter12500Black(context).copyWith(
                                          color: isAvailable
                                              ? DsColor.success
                                              : DsColor.text2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppConstants.width10(context)),
                        _Avatar(name: account.fullName),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),
                    if (account.phoneNumber.isNotEmpty)
                      _ContactRow(icon: Icons.phone_rounded, text: account.phoneNumber),
                    if (account.email.isNotEmpty) ...[
                      SizedBox(height: AppConstants.height10(context) / 1.5),
                      _ContactRow(icon: Icons.email_rounded, text: account.email),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * .15;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.shade50,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: Styles.inter18500Black(
            context,
          ).copyWith(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        SizedBox(width: AppConstants.width10(context)),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: Styles.inter14500black(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _CourierTabBar extends StatelessWidget {
  const _CourierTabBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static final List<String> _titles = [
    "tab_overview",
    "tab_orders",
    "tab_wallet",
    "tab_transactions",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DsColor.border, width: 1.5),
        ),
      ),
      child: Row(
        children: List.generate(_titles.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: AppConstants.width20(context),
            ),
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: EdgeInsets.only(
                  bottom: AppConstants.height10(context) / 1.2,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  _titles[index].tr(),
                  style: isSelected
                      ? Styles.inter14600black(
                          context,
                        ).copyWith(color: AppColors.primaryColor)
                      : Styles.inter14500black(
                          context,
                        ).copyWith(color: DsColor.textMuted),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// White bordered card with an icon+title header, matching the rest of the
/// app's redesigned screens — used by every tab on this page.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppConstants.sp20(context), color: AppColors.secondaryColor),
                  SizedBox(width: AppConstants.width10(context)),
                  Text(title, style: Styles.inter16500black(context)),
                ],
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: AppConstants.height15(context)),
          child,
        ],
      ),
    );
  }
}

/// One "label + value + icon" row inside a light-grey rounded box — the
/// look every field in "نظرة عامة" shares.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.ltr = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    final valueText = Text(
      value!,
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
      style: Styles.inter14600black(context).copyWith(color: valueColor),
    );

    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.height10(context)),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width15(context),
        vertical: AppConstants.height10(context),
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF5F6FA),
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.secondaryColor),
              SizedBox(width: AppConstants.width10(context)),
              Text(
                label,
                style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
              ),
            ],
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: ltr
                ? Directionality(textDirection: TextDirection.ltr, child: valueText)
                : valueText,
          ),

        ],
      ),
    );
  }
}

/// تبويب "نظرة عامة" — البيانات الشخصية وبيانات المركبة والأرباح.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.account});

  final DeliveryAccount account;

  @override
  Widget build(BuildContext context) {
    final isAvailable = account.isAvailableForDelivery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: "personal_data".tr(),
          icon: Icons.person_rounded,
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.person_rounded,
                label: "fullName".tr(),
                value: account.fullName.isNotEmpty ? account.fullName : null,
              ),
              _InfoTile(
                icon: Icons.email_rounded,
                label: "email".tr(),
                value: account.email.isNotEmpty ? account.email : null,
                ltr: true,
              ),
              _InfoTile(
                icon: Icons.phone_rounded,
                label: "phoneNumber".tr(),
                value: account.phoneNumber.isNotEmpty ? account.phoneNumber : null,
                ltr: true,
              ),
              if (account.createdAt != null)
                _InfoTile(
                  icon: Icons.calendar_today_rounded,
                  label: "created_at".tr(),
                  value: _formatDate(account.createdAt),
                  ltr: true,
                ),
            ],
          ),
        ),
        SizedBox(height: AppConstants.height20(context)),
        _SectionCard(
          title: "vehicle_and_earnings".tr(),
          icon: Icons.two_wheeler_rounded,
          child: Column(
            children: [
              _InfoTile(
                icon: Icons.two_wheeler_rounded,
                label: "vehicle_name".tr(),
                value: account.vehicleName,
              ),
              _InfoTile(
                icon: Icons.dialpad_rounded,
                label: "vehicle_plate_number".tr(),
                value: account.vehiclePlateNumber,
                ltr: true,
              ),
              _InfoTile(
                icon: Icons.percent_rounded,
                label: "earning_percentage".tr(),
                value: account.earningPercentage != null
                    ? "${account.earningPercentage}%"
                    : null,
                valueColor: AppColors.primaryColor,
              ),
              _InfoTile(
                icon: Icons.layers_rounded,
                label: "max_active_orders".tr(),
                value: account.maxActiveOrdersOverride?.toString(),
              ),
              if (isAvailable != null)
                _InfoTile(
                  icon: Icons.circle,
                  label: "availability_status".tr(),
                  value: isAvailable ? "courier_available".tr() : "courier_unavailable".tr(),
                  valueColor: isAvailable ? DsColor.success : DsColor.textMuted,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// تبويب "الطلبات" — الطلبات الحالية والمكتملة الخاصة بالمندوب.
class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.account});

  final DeliveryAccount account;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompletedOrdersSection(account: account),
      ],
    );
  }
}

class _OrdersSection extends StatelessWidget {
  const _OrdersSection({
    required this.title,
    required this.account,
    required this.finished,
  });

  final String title;
  final DeliveryAccount account;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetDeliveryOrdersCubit, GetDeliveryOrdersStates>(
      builder: (context, state) {
        final list = state is! GetDeliveryOrdersLoadingState
            ? context.read<GetDeliveryOrdersCubit>().ordersList
            : <Items>[];

        return _SectionCard(
          title: title,
          icon: Icons.local_shipping_rounded,
          trailing: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width10(context),
              vertical: AppConstants.height5(context) / 2,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF5F6FA),
              borderRadius: BorderRadius.circular(AppConstants.sp30(context) * 3),
            ),
            child: Text("i_x_orders_16".tr(namedArgs: {"a": "${list.length}"}), style: Styles.inter14500black(context)),
          ),
          child: Builder(
            builder: (context) {
              if (state is GetDeliveryOrdersLoadingState) {
                return const CustomLoadingItem(size: 30);
              }
              if (state is GetDeliveryOrdersErrorState) {
                return Text(
                  state.message,
                  style: Styles.inter12500Black(context).copyWith(color: DsColor.danger),
                );
              }
              if (list.isEmpty) {
                return Text(
                  "no_orders_found".tr(),
                  style: Styles.inter12500Black(context).copyWith(color: DsColor.textMuted),
                );
              }
              return Column(
                children: [
                  ...list.take(5).map((order) => _OrderSummaryTile(order: order)),
                  if (list.length > 5)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () => NavigationUtils.navigateTo(
                          context: context,
                          destinationScreen: DeliveryOrdersView(
                            initialFilters: {
                              'deliveryUserId': account.userId,
                              'finished': finished ? 'true' : 'false',
                            },
                          ),
                        ),
                        child: Text("viewAll".tr()),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _CompletedOrdersSection extends StatelessWidget {
  const _CompletedOrdersSection({required this.account});

  final DeliveryAccount account;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetDeliveryOrdersCubit(getIt<OrdersRepoImpl>())
        ..setFilters({'deliveryUserId': account.userId, 'finished': 'true'})
        ..getDeliveryOrders(withLoading: true),
      child: _OrdersSection(
        title: "orders".tr(),
        account: account,
        finished: true,
      ),
    );
  }
}

class _OrderSummaryTile extends StatelessWidget {
  const _OrderSummaryTile({required this.order});

  final Items order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => NavigationUtils.navigateTo(
        context: context,
        destinationScreen: DeliveryOrderDetailsView(orderId: order.id!),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.height10(context) / 1.5),
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined, size: AppConstants.sp20(context), color: AppColors.secondaryColor),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(
              child: Text(
                order.orderNumber ?? '-',
                overflow: TextOverflow.ellipsis,
                style: Styles.inter14500black(context),
              ),
            ),
            SizedBox(width: AppConstants.width5(context)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width10(context) / 1.5,
                vertical: AppConstants.height5(context) / 2,
              ),
              decoration: BoxDecoration(
                color: AppConstants.getStatusColor(order.status),
                borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
              ),
              child: Text(
                AppConstants.getStatusText(order.status),
                style: Styles.inter10400grey(
                  context,
                ).copyWith(color: AppConstants.getTextColor(order.status)),
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Text(
              "${order.totalAmount ?? '-'} ${"s_egp".tr()}",
              style: Styles.inter14600black(
                context,
              ).copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// تبويب "المحفظة" — الرصيد الحالي للمندوب وإحصائياته.
class _WalletTab extends StatelessWidget {
  const _WalletTab({required this.account});

  final DeliveryAccount account;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetDeliveryWalletCubit, GetDeliveryWalletState>(
      builder: (context, state) {
        num? balance = account.walletBalance;
        Map<String, dynamic> raw = const {};

        if (state is GetDeliveryWalletSuccess) {
          balance = state.model.data?.balance ?? balance;
          raw = state.model.data?.raw ?? const {};
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceCard(balance: balance, isLoading: state is GetDeliveryWalletLoading),
            if (state is GetDeliveryWalletError)
              Padding(
                padding: EdgeInsets.only(top: AppConstants.height10(context)),
                child: Text(
                  state.message,
                  style: Styles.inter12500Black(context).copyWith(color: DsColor.danger),
                ),
              ),
            if (raw.isNotEmpty) ...[
              SizedBox(height: AppConstants.height15(context)),
              _WalletStatsGrid(
                raw: raw,
                excludeKeys: const {'walletBalance', 'balance', 'currentBalance'},
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.isLoading});

  final num? balance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // White surface, the balance as the dominant figure (no coloured hero).
    return DsCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("wallet_balance".tr(), style: DsText.label.copyWith(color: DsColor.textMuted)),
                const SizedBox(height: DsSpace.xs),
                if (isLoading)
                  const DsSkeleton(width: 140, height: 28)
                else
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(balance != null ? DsFormat.money(balance) : "-", maxLines: 1, style: DsText.display),
                  ),
              ],
            ),
          ),
          const SizedBox(width: DsSpace.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: DsColor.primarySoft, borderRadius: BorderRadius.circular(DsRadius.md)),
            child: const Icon(Icons.account_balance_wallet_outlined, color: DsColor.onPrimarySoft),
          ),
        ],
      ),
    );
  }
}

/// أيقونة كل حقل ماليّ راجع من `raw` بحسب اسمه المعروف.
IconData _walletFieldIcon(String key) {
  switch (key) {
    case 'thisMonthEarnings':
    case 'allTimeEarnings':
      return Icons.trending_up_rounded;
    case 'thisMonthGrossCollected':
    case 'allTimeGrossCollected':
      return Icons.payments_rounded;
    case 'thisMonthRemitted':
    case 'allTimeRemitted':
      return Icons.storefront_rounded;
    default:
      return Icons.account_balance_wallet_rounded;
  }
}

/// شبكة إحصائيات المحفظة — كل حقل ترجعه الخادم (غير الرصيد نفسه، المعروض
/// كرقم رئيسي أعلى البطاقة) يظهر كبطاقة إحصائية صغيرة بعنوان عربي مترجم،
/// بدل عرضه كسطر نصي خام.
class _WalletStatsGrid extends StatelessWidget {
  const _WalletStatsGrid({required this.raw, required this.excludeKeys});

  final Map<String, dynamic> raw;
  final Set<String> excludeKeys;

  @override
  Widget build(BuildContext context) {
    final entries = raw.entries
        .where((e) => !excludeKeys.contains(e.key) && e.value != null)
        .toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppConstants.height10(context),
      crossAxisSpacing: AppConstants.width10(context),
      childAspectRatio: 1.5,
      children: entries
          .map(
            (e) => _StatTile(
              icon: _walletFieldIcon(e.key),
              label: arabicFieldLabel(e.key),
              value: formatFieldValue(e.key, e.value),
            ),
          )
          .toList(),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  bool get _isZero {
    final numeric = num.tryParse(value.replaceAll(RegExp(r'[^0-9.\-]'), ''));
    return numeric == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [

                Icon(icon, size: 18, color: AppColors.secondaryColor),
                SizedBox(width: AppConstants.width10(context)),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.height10(context),),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.inter18500Black(context).copyWith(
              color: _isZero ? DsColor.textSubtle : const Color(0xff0F0F0E),
            ),
          ),
        ],
      ),
    );
  }
}

/// تبويب "المعاملات" — سجل المعاملات المالية، وهو التبويب الافتراضي عند
/// فتح الصفحة: فلترة بالتاريخ، إجمالي الصفحة الحالية، بطاقات المعاملات،
/// وترقيم صفحات.
class _TransactionsTab extends StatefulWidget {
  const _TransactionsTab({required this.account});

  final DeliveryAccount account;

  @override
  State<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<_TransactionsTab> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        startDate = picked;
      } else {
        endDate = picked;
      }
    });
  }

  String _formatFilterDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  void _applyFilter() {
    final cubit = context.read<GetDeliveryTransactionsCubit>();
    cubit.setDateFilter(
      startDate: startDate != null ? _formatFilterDate(startDate!) : null,
      endDate: endDate != null ? _formatFilterDate(endDate!) : null,
    );
    cubit.getTransactions(userId: widget.account.userId!, withLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: "transactions_history".tr(),
      icon: Icons.receipt_long_rounded,
      trailing: _FilterPillButton(onTap: _applyFilter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _DateFieldBox(
                  label: startDate != null ? _formatFilterDate(startDate!) : "start_date".tr(),
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Expanded(
                child: _DateFieldBox(
                  label: endDate != null ? _formatFilterDate(endDate!) : "end_date".tr(),
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height15(context)),
          BlocBuilder<
            GetDeliveryTransactionsCubit,
            GetDeliveryTransactionsStates
          >(
            builder: (context, state) {
              final cubit = context.read<GetDeliveryTransactionsCubit>();

              if (state is GetDeliveryTransactionsLoadingState) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: CustomLoadingItem(size: 30),
                );
              }
              if (state is GetDeliveryTransactionsErrorState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.message,
                      style: Styles.inter12500Black(
                        context,
                      ).copyWith(color: DsColor.danger),
                    ),
                    TextButton(
                      onPressed: () => cubit.getTransactions(
                        userId: widget.account.userId!,
                        withLoading: true,
                      ),
                      child: Text("retry".tr()),
                    ),
                  ],
                );
              }

              final list = cubit.transactionsList;
              final metadata = cubit.transactionsModel?.data?.metadata;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (list.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppConstants.height20(context),
                      ),
                      child: Center(
                        child: Text(
                          "no_transactions_found".tr(),
                          style: Styles.inter12500Black(
                            context,
                          ).copyWith(color: DsColor.textMuted),
                        ),
                      ),
                    )
                  else ...[
                    ...list.map(
                      (t) => Padding(
                        padding: EdgeInsets.only(
                          bottom: AppConstants.height15(context),
                        ),
                        child: _TransactionCard(transaction: t),
                      ),
                    ),
                    if (metadata != null)
                      _TransactionsPager(
                        metadata: metadata,
                        onPageChanged: (page) => cubit.goToPage(
                          page,
                          userId: widget.account.userId!,
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterPillButton extends StatelessWidget {
  const _FilterPillButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width15(context),
          vertical: AppConstants.height10(context) / 1.5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
          border: Border.all(color: AppColors.secondaryColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "filter".tr(),
              style: Styles.inter12500Black(context).copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(width: AppConstants.width5(context)),
            Icon(Icons.tune_rounded, size: 16, color: AppColors.secondaryColor),
          ],
        ),
      ),
    );
  }
}

class _DateFieldBox extends StatelessWidget {
  const _DateFieldBox({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width10(context),
          vertical: AppConstants.height10(context),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
          border: Border.all(color: DsColor.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Styles.inter12500Black(context),
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatefulWidget {
  _TransactionCard({required this.transaction});

  final DeliveryTransaction transaction;

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

/// Arabic titles for the transaction `type` values confirmed (or plausible)
/// from the server. Anything not listed falls back to the raw type string
/// rather than guessing.
Map<String, String> _typeTitles = {
  'order_earning': "s_order_earnings".tr(),
  'remittance': "s_cash_handed_to_the_store".tr(),
  'manual_adjustment': "s_manual_balance_adjustment".tr(),
  'bonus': "s_bonus".tr(),
  'penalty': "s_deduction".tr(),
  'refund': "s_refund".tr(),
};

class _TransactionCardState extends State<_TransactionCard> {
  bool expanded = true;

  bool get _isOrderProfit => widget.transaction.type == 'order_earning';

  String get _title {
    final type = widget.transaction.type;
    if (type != null && _typeTitles.containsKey(type)) {
      return _typeTitles[type]!;
    }
    if (type != null && type.isNotEmpty) return type;
    return _isOrderProfit ? "order_profit".tr() : "amount_to_store".tr();
  }

  String get _orderLabel {
    final t = widget.transaction;
    if (t.orderNumber != null) return t.orderNumber!;
    if (t.orderId != null) return "#${t.orderId}";
    return '';
  }

  bool get _hasProfitFields =>
      widget.transaction.earningPercentage != null ||
      widget.transaction.shippingAmount != null ||
      widget.transaction.amountCollected != null;

  @override
  Widget build(BuildContext context) {
    final t = widget.transaction;
    final isCredit = t.amount >= 0;
    final amountColor = isCredit ? DsColor.success : DsColor.danger;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppConstants.sp10(context)),
                decoration: BoxDecoration(
                  color: (isCredit ? AppColors.secondaryColor : DsColor.danger).withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.account_balance_wallet_rounded : Icons.remove_circle_outline_rounded,
                  color: isCredit ? AppColors.secondaryColor : DsColor.danger,
                  size: 18,
                ),
              ),
              SizedBox(width: AppConstants.width10(context)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_title, style: Styles.inter14600black(context)),
                  if (_orderLabel.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: AppConstants.height5(context) / 2),
                      child: Text(
                        _orderLabel,
                        style: Styles.inter12500Black(context).copyWith(color: DsColor.textMuted),
                      ),
                    ),
                  if (t.createdAt != null)
                    Padding(
                      padding: EdgeInsets.only(top: AppConstants.height5(context) / 2),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(_formatDateTime(t.createdAt), style: Styles.inter10400grey(context)),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                "${isCredit ? '+' : ''}${t.amount.toStringAsFixed(2)}",
                style: Styles.inter18500Black(context).copyWith(color: amountColor),
              ),
            ],
          ),
          if (t.description != null) ...[
            SizedBox(height: AppConstants.height5(context)),
            Text(t.description!, style: Styles.inter10400grey(context)),
          ],
          if (expanded) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppConstants.height10(context),
              ),
              child: Divider(color: DsColor.fill, height: 1),
            ),
            if (_isOrderProfit && _hasProfitFields)
              Row(
                children: [
                  if (t.earningPercentage != null)
                    Expanded(
                      child: _MiniStat(
                        label: "profit_percentage".tr(),
                        value: "${t.earningPercentage}%",
                      ),
                    ),
                  if (t.shippingAmount != null)
                    Expanded(
                      child: _MiniStat(
                        label: "delivery_value".tr(),
                        value: "${t.shippingAmount} ${"s_egp".tr()}",
                      ),
                    ),
                  if (t.amountCollected != null)
                    Expanded(
                      child: _MiniStat(
                        label: "collected_amount".tr(),
                        value: "${t.amountCollected} ${"s_egp".tr()}",
                      ),
                    ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.id != null)
                    Text(
                      "${"operation_number".tr()}: ${t.id}",
                      style: Styles.inter12500Black(
                        context,
                      ).copyWith(color: DsColor.textMuted),
                    ),
                  const Spacer(),
                  if (t.balanceAfter != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "balance_after_operation".tr(),
                          style: Styles.inter10400grey(context),
                        ),
                        Text(
                          "${t.balanceAfter!.toStringAsFixed(2)} ${"s_egp".tr()}",
                          style: Styles.inter14600black(context),
                        ),
                      ],
                    ),
                ],
              ),
            ExtraFieldsSection(
              raw: t.raw,
              knownKeys: const {
                'id',
                'type',
                'amount',
                'value',
                'description',
                'notes',
                'note',
                'createdAt',
                'updatedAt',
                'deletedAt',
                'date',
                'balanceAfter',
                'runningBalance',
                'balance',
                'balanceDelta',
                'order',
                'orderId',
                'orderNumber',
                'courierId',
                'paymentMethod',
                'shippingAmount',
                'earningPercentage',
                'earningAmount',
                'amountCollected',
                'remittedAmount',
              },
            ),
          ],
          Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onTap: () => setState(() => expanded = !expanded),
              child: Padding(
                padding: EdgeInsets.only(top: AppConstants.height5(context)),
                child: Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: DsColor.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.width5(context) / 2),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width5(context),
        vertical: AppConstants.height10(context) / 1.5,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        border: Border.all(color: DsColor.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Styles.inter10400grey(context),
          ),
          SizedBox(height: AppConstants.height5(context) / 2),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: Styles.inter12600Black(
                context,
              ).copyWith(color: DsColor.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsPager extends StatelessWidget {
  const _TransactionsPager({required this.metadata, required this.onPageChanged});

  final DeliveryTransactionsMetadata metadata;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final currentPage = metadata.currentPage ?? 1;
    final totalPages = metadata.totalPages ?? 1;
    final itemsPerPage = metadata.itemsPerPage ?? 15;
    final totalItems = metadata.totalItems ?? 0;

    final from = totalItems == 0 ? 0 : (currentPage - 1) * itemsPerPage + 1;
    final to = totalItems == 0
        ? 0
        : (currentPage * itemsPerPage > totalItems
              ? totalItems
              : currentPage * itemsPerPage);

    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PagerArrow(
                icon: Icons.chevron_left,
                enabled: currentPage > 1,
                onTap: () => onPageChanged(currentPage - 1),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.width15(context),
                ),
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$currentPage",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _PagerArrow(
                icon: Icons.chevron_right,
                enabled: currentPage < totalPages,
                onTap: () => onPageChanged(currentPage + 1),
              ),
            ],
          ),
        ),
        SizedBox(height: AppConstants.height5(context)),
        Text(
          "showing_range"
              .tr()
              .replaceAll('{from}', '$from')
              .replaceAll('{to}', '$to')
              .replaceAll('{total}', '$totalItems'),
          style: Styles.inter10400grey(context),
        ),
      ],
    );
  }
}

class _PagerArrow extends StatelessWidget {
  const _PagerArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        color: enabled ? DsColor.text2 : DsColor.border,
      ),
    );
  }
}

String _formatDate(String? isoDate) {
  if (isoDate == null) return '';
  try {
    final date = DateTime.parse(isoDate).toLocal();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  } catch (_) {
    return '';
  }
}

String _formatDateTime(String? isoDate) {
  if (isoDate == null) return '';
  try {
    return DateFormat(
      "yyyy-MM-dd  hh:mm a",
    ).format(DateTime.parse(isoDate).toLocal());
  } catch (_) {
    return '';
  }
}
