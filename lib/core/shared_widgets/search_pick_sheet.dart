import 'dart:async';

import 'package:alrayan_admin/core/design/ds.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// One choice in a remote search picker (a customer, a product…).
class PickOption {
  const PickOption({required this.id, required this.label, this.subtitle});
  final int id;
  final String label;
  final String? subtitle;

  @override
  bool operator ==(Object other) => other is PickOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

typedef PickSearch = Future<List<PickOption>> Function(String keyword);

/// Opens a full-height sheet that searches remotely as the staff member types
/// and lets them pick one ([multiple] = false) or several options.
/// Returns the new selection, or null when dismissed.
Future<List<PickOption>?> showSearchPickSheet(
  BuildContext context, {
  required String title,
  required String hint,
  required PickSearch search,
  List<PickOption> selected = const [],
  bool multiple = true,
}) {
  return showModalBottomSheet<List<PickOption>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: DsColor.page,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DsRadius.lg))),
    builder: (_) => FractionallySizedBox(
      heightFactor: .9,
      child: _SearchPickSheet(title: title, hint: hint, search: search, selected: selected, multiple: multiple),
    ),
  );
}

class _SearchPickSheet extends StatefulWidget {
  const _SearchPickSheet({
    required this.title,
    required this.hint,
    required this.search,
    required this.selected,
    required this.multiple,
  });

  final String title;
  final String hint;
  final PickSearch search;
  final List<PickOption> selected;
  final bool multiple;

  @override
  State<_SearchPickSheet> createState() => _SearchPickSheetState();
}

class _SearchPickSheetState extends State<_SearchPickSheet> {
  late final List<PickOption> _picked = [...widget.selected];
  List<PickOption> _results = [];
  bool _loading = true;
  bool _failed = false;
  Timer? _debounce;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _run('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _run(v.trim()));
  }

  Future<void> _run(String keyword) async {
    final id = ++_seq;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final r = await widget.search(keyword);
      if (!mounted || id != _seq) return;
      setState(() {
        _results = r;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || id != _seq) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _toggle(PickOption o) {
    if (!widget.multiple) {
      Navigator.of(context).pop([o]);
      return;
    }
    setState(() => _picked.contains(o) ? _picked.remove(o) : _picked.add(o));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: DsSpace.sm),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: DsColor.border, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.page, DsSpace.md, DsSpace.sm, 0),
          child: Row(
            children: [
              Expanded(child: Text(widget.title, style: DsText.heading)),
              IconButton(
                tooltip: "s_cancel".tr(),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.sm, DsSpace.page, DsSpace.sm),
          child: DsSearchField(hint: widget.hint, onChanged: _onChanged, autofocus: true),
        ),
        if (widget.multiple && _picked.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: DsSpace.page),
              children: [
                for (final o in _picked)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: DsSpace.sm),
                    child: InputChip(
                      label: Text(o.label, style: DsText.caption.copyWith(color: DsColor.text)),
                      onDeleted: () => setState(() => _picked.remove(o)),
                      backgroundColor: DsColor.surface,
                      side: const BorderSide(color: DsColor.border),
                    ),
                  ),
              ],
            ),
          ),
        Expanded(child: _buildResults()),
        if (widget.multiple)
          DsBottomBar(
            child: DsButton(
              label: "pick_done_x".tr(namedArgs: {'n': DsFormat.count(_picked.length)}),
              onPressed: () => Navigator.of(context).pop(_picked),
            ),
          ),
      ],
    );
  }

  Widget _buildResults() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed) {
      return DsMessage(
        icon: Icons.cloud_off_rounded,
        title: "pick_load_failed".tr(),
        actionLabel: "s_retry".tr(),
        onAction: () => _run(''),
      );
    }
    if (_results.isEmpty) return DsMessage(icon: Icons.search_off_rounded, title: "pick_no_results".tr());
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.xs, DsSpace.page, DsSpace.lg),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: DsSpace.sm),
      itemBuilder: (_, i) {
        final o = _results[i];
        final on = _picked.contains(o);
        return DsCard(
          padding: const EdgeInsetsDirectional.fromSTEB(DsSpace.lg, DsSpace.sm, DsSpace.sm, DsSpace.sm),
          highlight: on ? DsColor.primary : null,
          onTap: () => _toggle(o),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.body.copyWith(fontWeight: FontWeight.w600)),
                    if ((o.subtitle ?? '').isNotEmpty)
                      Text(ltrIsolate(o.subtitle!), maxLines: 1, overflow: TextOverflow.ellipsis, style: DsText.caption),
                  ],
                ),
              ),
              if (widget.multiple)
                Checkbox(value: on, activeColor: DsColor.primary, onChanged: (_) => _toggle(o))
              else
                const Icon(Icons.chevron_right_rounded, color: DsColor.textSubtle),
            ],
          ),
        );
      },
    );
  }
}

/// Keeps phone numbers / ids left-to-right inside Arabic text without
/// flipping their alignment.
String ltrIsolate(String s) => '${String.fromCharCode(0x2066)}$s${String.fromCharCode(0x2069)}';
