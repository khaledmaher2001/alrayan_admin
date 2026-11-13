import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/helpers/staff_permissions.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/models/spin_wheel_config_model.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/repo/lucky_wheel_repo_impl.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/spin_config/spin_config_cubit.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _kMaxRules = 10;

/// "Spins by order value": an order whose products total (after discounts,
/// delivery excluded) reaches a level earns that level's spins; the highest
/// level reached wins; no levels = 1 spin per delivered order.
class SpinRulesView extends StatelessWidget {
  const SpinRulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpinConfigCubit(getIt.get<LuckyWheelRepoImpl>())..load(),
      child: const _SpinRulesBody(),
    );
  }
}

class _RuleDraft {
  _RuleDraft(num amount, int spins)
      : amount = TextEditingController(text: _fmt(amount)),
        spins = TextEditingController(text: '$spins');

  final TextEditingController amount;
  final TextEditingController spins;

  static String _fmt(num v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  num? get amountValue => num.tryParse(amount.text.trim());
  int? get spinsValue => int.tryParse(spins.text.trim());

  void dispose() {
    amount.dispose();
    spins.dispose();
  }
}

class _SpinRulesBody extends StatefulWidget {
  const _SpinRulesBody();

  @override
  State<_SpinRulesBody> createState() => _SpinRulesBodyState();
}

class _SpinRulesBodyState extends State<_SpinRulesBody> {
  final List<_RuleDraft> _rules = [];
  bool _loaded = false;

  @override
  void dispose() {
    for (final r in _rules) {
      r.dispose();
    }
    super.dispose();
  }

  void _fill(SpinWheelConfigModel config) {
    for (final r in _rules) {
      r.dispose();
    }
    _rules
      ..clear()
      ..addAll(config.orderRules.map((r) => _RuleDraft(r.minAmount, r.spins)));
    _loaded = true;
  }

  List<SpinOrderRule> get _valid => [
        for (final r in _rules)
          if (r.amountValue != null && r.spinsValue != null)
            SpinOrderRule(minAmount: r.amountValue!, spins: r.spinsValue!),
      ];

  bool get _hasDuplicate {
    final mins = _valid.map((r) => r.minAmount).toList();
    return mins.toSet().length != mins.length;
  }

  String? get _invalidMessage {
    for (final r in _rules) {
      final a = r.amountValue;
      final s = r.spinsValue;
      if (a == null || a < 0 || a > 1000000) return "lw_rule_amount_invalid".tr();
      if (s == null || s < 1 || s > 20) return "lw_rule_spins_invalid".tr();
    }
    if (_hasDuplicate) return "lw_dup_min".tr();
    return null;
  }

  void _addRule() {
    final sorted = _valid..sort((a, b) => a.minAmount.compareTo(b.minAmount));
    final last = sorted.isEmpty ? null : sorted.last;
    setState(() => _rules.add(_RuleDraft((last?.minAmount ?? 0) + 200, ((last?.spins ?? 0) + 1).clamp(1, 20))));
  }

  void _removeRule(int i) {
    setState(() => _rules.removeAt(i).dispose());
  }

  String _example(num amount, List<SpinOrderRule> rules) {
    final n = SpinWheelConfigModel.spinsFor(amount, rules);
    final spins = n == 0
        ? "lw_example_none".tr()
        : n == 1
            ? "lw_example_one".tr()
            : "lw_example_many".tr(namedArgs: {"n": DsFormat.count(n)});
    return "lw_example".tr(namedArgs: {"amount": DsFormat.money(amount), "spins": spins});
  }

  List<String> _examples() {
    final rules = _valid..sort((a, b) => a.minAmount.compareTo(b.minAmount));
    if (rules.isEmpty) return const [];
    final amounts = <num>{
      (rules.first.minAmount - 50).clamp(0, double.infinity),
      ...rules.map((r) => r.minAmount),
      rules.last.minAmount + 200,
    };
    return [for (final a in amounts) _example(a, rules)];
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = staffCan(context, 'spin_wheel.edit');
    return BlocConsumer<SpinConfigCubit, SpinConfigState>(
      listener: (context, state) {
        if (state is SpinConfigLoadedState) {
          setState(() => _fill(state.config));
        } else if (state is SpinConfigSavedState) {
          setState(() => _fill(state.config));
          toast(text: "lw_rules_saved".tr(), color: DsColor.success);
        } else if (state is SpinConfigSaveErrorState) {
          toast(text: state.error, color: DsColor.danger);
        }
      },
      builder: (context, state) {
        final saving = state is SpinConfigSavingState;
        final invalid = _invalidMessage;
        return Scaffold(
          backgroundColor: DsColor.page,
          bottomNavigationBar: canEdit && _loaded
              ? DsBottomBar(
                  child: DsButton(
                    label: "lw_save_rules".tr(),
                    icon: Icons.check_rounded,
                    loading: saving,
                    onPressed: invalid != null ? null : () => context.read<SpinConfigCubit>().saveRules(_valid),
                  ),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                DsTopBar(title: "lw_rules_title".tr()),
                Expanded(child: _buildContent(context, state, canEdit, invalid)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SpinConfigState state, bool canEdit, String? invalid) {
    if (!_loaded) {
      if (state is SpinConfigErrorState) {
        return DsMessage(
          icon: Icons.cloud_off_rounded,
          title: "lw_rules_load_failed".tr(),
          subtitle: state.error,
          actionLabel: "s_retry".tr(),
          onAction: () => context.read<SpinConfigCubit>().load(),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final examples = _examples();
    return ListView(
      padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.sm, DsSpace.page, DsSpace.xxl),
      children: [
        _InfoBox(icon: Icons.info_outline_rounded, text: "lw_rules_hint".tr()),
        const SizedBox(height: DsSpace.lg),
        if (_rules.isEmpty)
          DsCard(
            child: Row(
              children: [
                const Icon(Icons.casino_outlined, color: DsColor.textMuted),
                const SizedBox(width: DsSpace.md),
                Expanded(child: Text("lw_rules_none".tr(), style: DsText.body.copyWith(color: DsColor.text2))),
              ],
            ),
          ),
        for (var i = 0; i < _rules.length; i++) ...[
          if (i > 0) const SizedBox(height: DsSpace.sm),
          DsCard(
            padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, DsSpace.md, DsSpace.xs, DsSpace.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: DsField(
                    label: "lw_rule_from".tr(),
                    child: TextField(
                      controller: _rules[i].amount,
                      enabled: canEdit,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                      onChanged: (_) => setState(() {}),
                      style: DsText.body,
                      decoration: dsInput().copyWith(suffixText: "s_egp".tr(), suffixStyle: DsText.caption),
                    ),
                  ),
                ),
                const SizedBox(width: DsSpace.sm),
                Expanded(
                  flex: 2,
                  child: DsField(
                    label: "lw_rule_spins".tr(),
                    child: TextField(
                      controller: _rules[i].spins,
                      enabled: canEdit,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      onChanged: (_) => setState(() {}),
                      style: DsText.body,
                      decoration: dsInput(),
                    ),
                  ),
                ),
                if (canEdit)
                  IconButton(
                    tooltip: "lw_remove_rule".tr(),
                    onPressed: () => _removeRule(i),
                    icon: const Icon(Icons.delete_outline_rounded, color: DsColor.danger),
                  ),
              ],
            ),
          ),
        ],
        if (invalid != null && _rules.isNotEmpty) ...[
          const SizedBox(height: DsSpace.sm),
          Text(invalid, style: DsText.caption.copyWith(color: DsColor.danger)),
        ],
        if (canEdit) ...[
          const SizedBox(height: DsSpace.md),
          DsButton(
            label: _rules.length >= _kMaxRules ? "lw_rules_max".tr() : "lw_add_rule".tr(),
            icon: Icons.add_rounded,
            kind: DsButtonKind.secondary,
            onPressed: _rules.length >= _kMaxRules ? null : _addRule,
          ),
        ],
        if (examples.isNotEmpty) ...[
          const SizedBox(height: DsSpace.xl),
          DsSectionHeader(title: "lw_examples".tr(), padding: const EdgeInsetsDirectional.only(bottom: DsSpace.sm, start: 4)),
          DsGroup(children: [
            for (final e in examples)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DsSpace.lg, vertical: DsSpace.md),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: DsSize.iconSm, color: DsColor.textMuted),
                    const SizedBox(width: DsSpace.sm),
                    Expanded(child: Text(e, style: DsText.body)),
                  ],
                ),
              ),
          ]),
        ],
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(DsSpace.md),
        decoration: BoxDecoration(color: DsColor.infoBg, borderRadius: BorderRadius.circular(DsRadius.md)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: DsSize.iconSm, color: DsColor.info),
            const SizedBox(width: DsSpace.sm),
            Expanded(child: Text(text, style: DsText.caption.copyWith(color: DsColor.info))),
          ],
        ),
      );
}
