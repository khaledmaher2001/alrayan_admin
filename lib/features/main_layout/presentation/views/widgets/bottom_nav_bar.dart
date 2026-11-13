import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/features/main_layout/view_model/change_nav_bar_status/change_nav_bar_status_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_cubit.dart';
import 'package:alrayan_admin/features/orders/presentation/view_model/get_orders/get_orders_states.dart';

/// Bottom navigation: four labelled destinations in one icon family
/// (Material Rounded); the current one gets the brand indicator.
/// The Orders tab shows an accent dot while new realtime orders are unseen.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  static const _items = [
    (Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, "home"),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, "orders"),
    (Icons.inventory_2_outlined, Icons.inventory_2_rounded, "products"),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, "more_title"),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangeNavBarStatusCubit, ChangeNavBarStatusState>(
      builder: (context, state) {
        final current = ChangeNavBarStatusCubit.get(context).currentIndex;
        return DecoratedBox(
          decoration: const BoxDecoration(color: DsColor.surface, border: Border(top: BorderSide(color: DsColor.border))),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith(
                (s) => DsText.caption.copyWith(
                  color: s.contains(WidgetState.selected) ? DsColor.primary : DsColor.textMuted,
                  fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            child: NavigationBar(
              height: 66,
              backgroundColor: DsColor.surface,
              surfaceTintColor: DsColor.surface,
              indicatorColor: DsColor.primarySoft,
              selectedIndex: current,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) => context.read<ChangeNavBarStatusCubit>().changeNavBarIndex(i),
              destinations: [
                for (var i = 0; i < _items.length; i++)
                  NavigationDestination(
                    icon: _Icon(icon: _items[i].$1, color: DsColor.textMuted, dot: i == 1),
                    selectedIcon: _Icon(icon: _items[i].$2, color: DsColor.primary, dot: i == 1),
                    label: _items[i].$3.tr(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.icon, required this.color, required this.dot});
  final IconData icon;
  final Color color;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final i = Icon(icon, color: color);
    if (!dot) return i;
    return BlocBuilder<GetOrdersCubit, GetOrdersStates>(
      builder: (context, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          i,
          if (context.read<GetOrdersCubit>().hasUnseenNewOrders)
            PositionedDirectional(
              top: -2,
              end: -3,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: DsColor.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
              ),
            ),
        ],
      ),
    );
  }
}
