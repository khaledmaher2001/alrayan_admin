import 'dart:async';

import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/search_pick_sheet.dart';
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/helpers/staff_permissions.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/models/spin_attempts_model.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/repo/lucky_wheel_repo_impl.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/customer_spins/customer_spins_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/set_spins/set_spins_cubit.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/give_spins_view.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "لفات العملاء": customers holding saved spins (or search any customer),
/// the wheel figures, set an exact count, and give spins to several customers.
class CustomerSpinsView extends StatelessWidget {
  const CustomerSpinsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CustomerSpinsCubit(getIt.get<LuckyWheelRepoImpl>())..load()),
        BlocProvider(create: (_) => SetSpinsCubit(getIt.get<LuckyWheelRepoImpl>())),
      ],
      child: const _CustomerSpinsBody(),
    );
  }
}

class _CustomerSpinsBody extends StatefulWidget {
  const _CustomerSpinsBody();

  @override
  State<_CustomerSpinsBody> createState() => _CustomerSpinsBodyState();
}

class _CustomerSpinsBodyState extends State<_CustomerSpinsBody> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<CustomerSpinsCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) context.read<CustomerSpinsCubit>().load(search: v.trim());
    });
  }

  Future<void> _give() async {
    final done = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const GiveSpinsView()));
    if (done == true && mounted) context.read<CustomerSpinsCubit>().load(withLoading: false);
  }

  Future<void> _edit(SpinCustomer c) async {
    final value = await showDialog<int>(context: context, builder: (_) => _EditSpinsDialog(customer: c));
    if (value != null && mounted) {
      context.read<SetSpinsCubit>().setSpins(userId: c.id, attemptCount: value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = staffCan(context, 'spin_wheel.edit');
    return BlocListener<SetSpinsCubit, SetSpinsState>(
      listener: (context, state) {
        if (state is SetSpinsSuccessState) {
          toast(text: "lw_updated".tr(), color: DsColor.success);
          context.read<CustomerSpinsCubit>()
            ..updateCount(state.userId, state.attemptCount)
            ..load(withLoading: false);
        } else if (state is SetSpinsErrorState) {
          toast(text: state.error, color: DsColor.danger);
        }
      },
      child: Scaffold(
        backgroundColor: DsColor.page,
        floatingActionButton: canEdit
            ? FloatingActionButton.extended(
                heroTag: "give_spins",
                onPressed: _give,
                icon: const Icon(Icons.add_rounded),
                label: Text("lw_give".tr()),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              DsTopBar(title: "lw_spins_title".tr(), subtitle: "lw_spins_desc".tr()),
              Expanded(
                child: BlocBuilder<CustomerSpinsCubit, CustomerSpinsState>(
                  builder: (context, state) {
                    final cubit = context.read<CustomerSpinsCubit>();
                    return RefreshIndicator(
                      onRefresh: () => cubit.load(withLoading: false),
                      child: ListView(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.sm, DsSpace.page, 96),
                        children: [
                          _Hint(text: "lw_lucky_hint".tr()),
                          const SizedBox(height: DsSpace.md),
                          _StatsBlock(stats: cubit.stats),
                          const SizedBox(height: DsSpace.md),
                          DsSearchField(hint: "lw_search".tr(), controller: _search, onChanged: _onSearch),
                          const SizedBox(height: DsSpace.md),
                          ..._buildList(context, state, cubit, canEdit),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildList(BuildContext context, CustomerSpinsState state, CustomerSpinsCubit cubit, bool canEdit) {
    if (state is CustomerSpinsLoadingState || state is CustomerSpinsInitial) {
      return [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(height: DsSpace.sm),
          const DsSkeleton(height: 84, radius: DsRadius.lg),
        ],
      ];
    }
    if (state is CustomerSpinsErrorState) {
      return [
        DsMessage(
          icon: Icons.cloud_off_rounded,
          title: "lw_spins_load_failed".tr(),
          subtitle: state.error,
          actionLabel: "s_retry".tr(),
          onAction: () => cubit.load(),
        ),
      ];
    }
    if (cubit.customers.isEmpty) {
      return [
        DsMessage(
          icon: Icons.casino_outlined,
          title: cubit.search.isEmpty ? "lw_spins_empty".tr() : "lw_spins_empty_search".tr(),
        ),
      ];
    }
    return [
      BlocBuilder<SetSpinsCubit, SetSpinsState>(
        builder: (context, setSpinsState) => Column(
          children: [
            for (var i = 0; i < cubit.customers.length; i++) ...[
              if (i > 0) const SizedBox(height: DsSpace.sm),
              _CustomerCard(
                customer: cubit.customers[i],
                canEdit: canEdit,
                saving: setSpinsState is SetSpinsLoadingState && setSpinsState.userId == cubit.customers[i].id,
                onEdit: () => _edit(cubit.customers[i]),
              ),
            ],
          ],
        ),
      ),
      if (cubit.isLoadingMore)
        const Padding(
          padding: EdgeInsets.all(DsSpace.lg),
          child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
    ];
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(DsSpace.md),
        decoration: BoxDecoration(color: DsColor.infoBg, borderRadius: BorderRadius.circular(DsRadius.md)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, size: DsSize.iconSm, color: DsColor.info),
            const SizedBox(width: DsSpace.sm),
            Expanded(child: Text(text, style: DsText.caption.copyWith(color: DsColor.info))),
          ],
        ),
      );
}

class _StatsBlock extends StatelessWidget {
  const _StatsBlock({required this.stats});
  final SpinStats? stats;

  @override
  Widget build(BuildContext context) {
    String v(int Function(SpinStats s) pick) => stats == null ? '—' : DsFormat.count(pick(stats!));
    return Column(
      children: [
        DsMetricStrip(items: [
          DsMetric(label: "lw_stat_holders".tr(), value: v((s) => s.holders)),
          DsMetric(label: "lw_stat_saved".tr(), value: v((s) => s.savedSpins), color: DsColor.primary),
        ]),
        const SizedBox(height: DsSpace.sm),
        DsMetricStrip(items: [
          DsMetric(label: "lw_stat_from_orders".tr(), value: v((s) => s.fromOrders30d)),
          DsMetric(label: "lw_stat_from_staff".tr(), value: v((s) => s.fromStaff30d)),
          DsMetric(label: "lw_stat_spun".tr(), value: v((s) => s.spun30d)),
        ]),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.canEdit, required this.saving, required this.onEdit});
  final SpinCustomer customer;
  final bool canEdit;
  final bool saving;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final c = customer;
    final granted = DsFormat.dateTime(context, c.lastGrantedAt);
    final spun = DsFormat.dateTime(context, c.lastSpunAt);
    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.bodyStrong),
                    Text(ltrIsolate(c.phoneNumber ?? '#${c.id}'), style: DsText.caption),
                  ],
                ),
              ),
              const SizedBox(width: DsSpace.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DsFormat.count(c.attemptCount), style: DsText.number.copyWith(color: c.attemptCount > 0 ? DsColor.primary : DsColor.textMuted)),
                  Text("lw_col_spins".tr(), style: DsText.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: DsSpace.sm),
          Text("${"lw_col_granted".tr()}: ${granted.isEmpty ? '—' : granted}", style: DsText.caption),
          Text("${"lw_col_spun".tr()}: ${spun.isEmpty ? '—' : spun}", style: DsText.caption),
          if (canEdit) ...[
            const SizedBox(height: DsSpace.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: DsButton(
                label: "lw_edit_count".tr(),
                icon: Icons.edit_outlined,
                kind: DsButtonKind.secondary,
                expand: false,
                loading: saving,
                onPressed: onEdit,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Exact number of saved spins (0..1000). Pops the new value.
class _EditSpinsDialog extends StatefulWidget {
  const _EditSpinsDialog({required this.customer});
  final SpinCustomer customer;

  @override
  State<_EditSpinsDialog> createState() => _EditSpinsDialogState();
}

class _EditSpinsDialogState extends State<_EditSpinsDialog> {
  late final _ctrl = TextEditingController(text: '${widget.customer.attemptCount}');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int? get _value {
    final v = int.tryParse(_ctrl.text.trim());
    return v == null || v < 0 || v > 1000 ? null : v;
  }

  void _step(int d) {
    final v = ((int.tryParse(_ctrl.text.trim()) ?? 0) + d).clamp(0, 1000);
    setState(() => _ctrl.text = '$v');
  }

  @override
  Widget build(BuildContext context) {
    final valid = _value != null;
    return AlertDialog(
      backgroundColor: DsColor.surface,
      surfaceTintColor: DsColor.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadius.lg)),
      title: Text("lw_edit_title".tr(namedArgs: {"name": widget.customer.displayName}), style: DsText.heading),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.outlined(onPressed: () => _step(-1), icon: const Icon(Icons.remove_rounded)),
              const SizedBox(width: DsSpace.sm),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  onChanged: (_) => setState(() {}),
                  style: DsText.number,
                  decoration: dsInput(),
                ),
              ),
              const SizedBox(width: DsSpace.sm),
              IconButton.outlined(onPressed: () => _step(1), icon: const Icon(Icons.add_rounded)),
            ],
          ),
          const SizedBox(height: DsSpace.sm),
          Text("lw_edit_help".tr(), style: DsText.caption.copyWith(color: valid ? DsColor.textMuted : DsColor.danger)),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(DsSpace.xxl, 0, DsSpace.xxl, DsSpace.xl),
      actions: [
        Row(
          children: [
            Expanded(child: DsButton(label: "lw_back".tr(), kind: DsButtonKind.secondary, onPressed: () => Navigator.of(context).pop())),
            const SizedBox(width: DsSpace.sm),
            Expanded(child: DsButton(label: "lw_save".tr(), onPressed: valid ? () => Navigator.of(context).pop(_value) : null)),
          ],
        ),
      ],
    );
  }
}
