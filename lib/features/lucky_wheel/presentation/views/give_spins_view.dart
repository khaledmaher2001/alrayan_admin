import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/search_pick_sheet.dart';
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/lucky_wheel/data/repo/lucky_wheel_repo_impl.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/grant_spins/grant_spins_cubit.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "إدّي لفات": pick customers, the spins each gets, an optional staff note,
/// and whether to notify them. Pops true when spins were added.
class GiveSpinsView extends StatelessWidget {
  const GiveSpinsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => GrantSpinsCubit(getIt.get<LuckyWheelRepoImpl>()), child: const _GiveSpinsBody());
  }
}

class _GiveSpinsBody extends StatefulWidget {
  const _GiveSpinsBody();

  @override
  State<_GiveSpinsBody> createState() => _GiveSpinsBodyState();
}

class _GiveSpinsBodyState extends State<_GiveSpinsBody> {
  final _repo = getIt.get<LuckyWheelRepoImpl>();
  final _spins = TextEditingController(text: '1');
  final _note = TextEditingController();
  List<PickOption> _customers = [];
  bool _notify = true;
  bool _all = false;
  int? _allCount;
  bool _triedSubmit = false;

  @override
  void dispose() {
    _spins.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _spinsValue {
    final v = int.tryParse(_spins.text.trim());
    return v == null || v < 1 || v > 50 ? null : v;
  }

  void _step(int d) {
    final v = ((int.tryParse(_spins.text.trim()) ?? 0) + d).clamp(1, 50);
    setState(() => _spins.text = '$v');
  }

  Future<void> _pickCustomers() async {
    final picked = await showSearchPickSheet(
      context,
      title: "lw_customers".tr(),
      hint: "lw_customers_ph".tr(),
      search: _repo.searchCustomers,
      selected: _customers,
    );
    if (picked != null) setState(() => _customers = picked.take(500).toList());
  }

  Future<void> _loadAllCount() async {
    final r = await _repo.activeCustomersCount();
    if (!mounted) return;
    r.fold((_) {}, (n) => setState(() => _allCount = n));
  }

  void _setAll(bool all) {
    setState(() => _all = all);
    if (all) _loadAllCount();
  }

  Future<void> _submit() async {
    setState(() => _triedSubmit = true);
    final spins = _spinsValue;
    if (spins == null) return;
    if (_all) {
      await _loadAllCount();
      if (!mounted) return;
      final ok = await dsConfirm(
        context,
        title: "lw_all_confirm_title".tr(),
        message: "lw_all_confirm".tr(
          namedArgs: {
            "s": spins == 1 ? "lw_one_spin".tr() : "lw_n_spins".tr(namedArgs: {"n": DsFormat.count(spins)}),
            "n": DsFormat.count(_allCount ?? 0),
          },
        ),
        confirmLabel: "lw_all_ok".tr(),
      );
      if (!ok || !mounted) return;
      context.read<GrantSpinsCubit>().grant(allCustomers: true, spins: spins, notify: _notify, note: _note.text);
      return;
    }
    if (_customers.isEmpty) return;
    context.read<GrantSpinsCubit>().grant(userIds: _customers.map((c) => c.id).toList(), spins: spins, notify: _notify, note: _note.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GrantSpinsCubit, GrantSpinsState>(
      listener: (context, state) {
        if (state is GrantSpinsSuccessState) {
          toast(
            text: "lw_given".tr(namedArgs: {"n": DsFormat.count(state.customers)}),
            color: DsColor.success,
          );
          Navigator.of(context).pop(true);
        } else if (state is GrantSpinsErrorState) {
          toast(text: state.error, color: DsColor.danger);
        }
      },
      builder: (context, state) {
        final loading = state is GrantSpinsLoadingState;
        return Scaffold(
          backgroundColor: DsColor.page,
          bottomNavigationBar: DsBottomBar(
            child: DsButton(label: "lw_give_btn".tr(), icon: Icons.casino_outlined, loading: loading, onPressed: _submit),
          ),
          body: SafeArea(
            child: Column(
              children: [
                DsTopBar(title: "lw_give_title".tr()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.sm, DsSpace.page, DsSpace.xxl),
                    children: [
                      DsField(
                        label: "lw_who".tr(),
                        child: Wrap(
                          spacing: DsSpace.sm,
                          children: [
                            DsChip(label: "lw_pick_some".tr(), selected: !_all, onTap: () => _setAll(false)),
                            DsChip(label: "lw_pick_all".tr(), selected: _all, onTap: () => _setAll(true)),
                          ],
                        ),
                      ),
                      const SizedBox(height: DsSpace.xl),
                      if (_all)
                        Text(
                          _allCount == null ? "lw_all_hint".tr() : "lw_all_hint_n".tr(namedArgs: {"n": DsFormat.count(_allCount!)}),
                          style: DsText.body.copyWith(color: DsColor.text2),
                        )
                      else ...[
                        DsField(
                          label: "lw_customers".tr(),
                          required: true,
                          help: _triedSubmit && _customers.isEmpty ? "lw_required".tr() : null,
                          child: DsCard(
                            onTap: _pickCustomers,
                            highlight: _triedSubmit && _customers.isEmpty ? DsColor.danger : null,
                            padding: const EdgeInsets.symmetric(horizontal: DsSpace.lg, vertical: DsSpace.md),
                            child: Row(
                              children: [
                                const Icon(Icons.person_search_outlined, color: DsColor.textMuted),
                                const SizedBox(width: DsSpace.md),
                                Expanded(
                                  child: Text(
                                    _customers.isEmpty
                                        ? "lw_customers_ph".tr()
                                        : "lw_customers_count".tr(namedArgs: {"n": DsFormat.count(_customers.length)}),
                                    style: DsText.body.copyWith(color: _customers.isEmpty ? DsColor.textSubtle : DsColor.text),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: DsColor.textSubtle),
                              ],
                            ),
                          ),
                        ),
                        if (_customers.isNotEmpty) ...[
                          const SizedBox(height: DsSpace.sm),
                          Wrap(
                            spacing: DsSpace.sm,
                            runSpacing: DsSpace.xs,
                            children: [
                              for (final c in _customers)
                                InputChip(
                                  label: Text(c.label, style: DsText.caption.copyWith(color: DsColor.text)),
                                  backgroundColor: DsColor.surface,
                                  side: const BorderSide(color: DsColor.border),
                                  onDeleted: () => setState(() => _customers = [..._customers]..remove(c)),
                                ),
                            ],
                          ),
                        ],
                      ],
                      const SizedBox(height: DsSpace.xl),
                      DsField(
                        label: "lw_how_many".tr(),
                        required: true,
                        help: "lw_how_many_help".tr(),
                        child: Row(
                          children: [
                            IconButton.outlined(onPressed: () => _step(-1), icon: const Icon(Icons.remove_rounded)),
                            const SizedBox(width: DsSpace.sm),
                            SizedBox(
                              width: 96,
                              child: TextField(
                                controller: _spins,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                                onChanged: (_) => setState(() {}),
                                style: DsText.number,
                                decoration: dsInput().copyWith(errorText: _spinsValue == null ? '' : null),
                              ),
                            ),
                            const SizedBox(width: DsSpace.sm),
                            IconButton.outlined(onPressed: () => _step(1), icon: const Icon(Icons.add_rounded)),
                          ],
                        ),
                      ),
                      const SizedBox(height: DsSpace.xl),
                      DsField(
                        label: "lw_note".tr(),
                        child: TextField(
                          controller: _note,
                          maxLength: 200,
                          style: DsText.body,
                          decoration: dsInput(hint: "lw_note_ph".tr()),
                        ),
                      ),
                      const SizedBox(height: DsSpace.md),
                      DsGroup(
                        children: [
                          DsRow(
                            icon: Icons.notifications_active_outlined,
                            title: "lw_notify".tr(),
                            trailing: Switch(
                              value: _notify,
                              activeThumbColor: Colors.white,
                              activeTrackColor: DsColor.primary,
                              onChanged: (v) => setState(() => _notify = v),
                            ),
                            onTap: () => setState(() => _notify = !_notify),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
