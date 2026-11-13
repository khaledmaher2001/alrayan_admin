import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/api_service.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';

import '../data/admin_complaints_repo.dart';
import 'widgets/adx_widgets.dart';

/// One request (staff view): details, customer, status actions allowed by the
/// server, priority, assignee, full history with internal notes, and a reply box.
class AdminComplaintDetailsView extends StatefulWidget {
  const AdminComplaintDetailsView({super.key, required this.id});
  final int id;

  @override
  State<AdminComplaintDetailsView> createState() => _AdminComplaintDetailsViewState();
}

class _AdminComplaintDetailsViewState extends State<AdminComplaintDetailsView> {
  final _repo = AdminComplaintsRepo(getIt.get<ApiService>());
  final _reply = TextEditingController();

  AdminComplaint? _c;
  List<AdminPerson> _assignees = [];
  bool _loading = true, _busy = false, _internal = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _repo.assignees().then((a) {
      if (mounted) setState(() => _assignees = a);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final c = await _repo.details(widget.id);
      if (mounted) setState(() { _c = c; _loading = false; _error = null; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = AdminComplaintsRepo.errorText(e); });
    }
  }

  void _toast(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: error ? AppColors.redColor : const Color(0xff15803D)),
    );
  }

  /// Runs a change, then reloads; one action at a time.
  Future<bool> _run(Future<void> Function() action, String done) async {
    if (_busy) return false;
    setState(() => _busy = true);
    try {
      await action();
      await _load();
      if (mounted) _toast(done);
      return true;
    } catch (e) {
      if (mounted) _toast(AdminComplaintsRepo.errorText(e), error: true);
      await _load(); // someone else may have changed it
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    if (text.length < 2) return;
    FocusScope.of(context).unfocus();
    final ok = await _run(() => _repo.addMessage(widget.id, body: text, internal: _internal), _internal ? 'adx_note_added'.tr() : 'adx_reply_sent'.tr());
    if (ok && mounted) _reply.clear(); // keep the text if sending failed
  }

  Future<void> _pick<T>(String title, List<(T, String)> options, T current, void Function(T) onPick) async {
    final picked = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheet) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .7),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: [
              Text(title, style: Styles.inter16500black(context)),
              const SizedBox(height: 12),
              for (final (value, label) in options)
                ListTile(
                  minTileHeight: 52,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: value == current ? AppColors.primaryColor.withValues(alpha: .08) : null,
                  title: Text(label, style: Styles.inter14600black(context)),
                  trailing: value == current ? Icon(Icons.check_circle, color: AppColors.primaryColor) : null,
                  onTap: () => Navigator.of(sheet).pop(value),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && picked != current) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: c != null ? 'adx_request_no'.tr(namedArgs: {'id': '${c.id}'}) : 'more_complaints'.tr(),
              hasBack: true,
              withNotifications: false,
              textColor: Colors.black,
            ),
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : c == null
                      ? AdxMessage(icon: Icons.wifi_off_rounded, title: _error ?? 'adx_error'.tr(), action: TextButton(onPressed: _load, child: Text('home_retry'.tr())))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: EdgeInsets.fromLTRB(AppConstants.width20(context), 4, AppConstants.width20(context), 20),
                            children: [
                              _summary(c),
                              const SizedBox(height: 12),
                              _manage(c),
                              const SizedBox(height: 18),
                              Text('adx_history'.tr(), style: Styles.inter16500black(context)),
                              const SizedBox(height: 10),
                              _event('adx_created'.tr(namedArgs: {'when': adxDate(context, c.createdAt)})),
                              for (final m in c.messages) ...[const SizedBox(height: 10), _message(m)],
                            ],
                          ),
                        ),
            ),
            if (c != null) _composer(c),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppConstants.sp15(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
          border: Border.all(color: const Color(0xffEDEDED)),
        ),
        child: child,
      );

  Widget _summary(AdminComplaint c) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${AdxLabels.type(c.type)} · ${AdxLabels.category(c.category)}',
                      style: Styles.inter12500Black(context).copyWith(color: const Color(0xff6B7280))),
                ),
                AdxChip.status(c.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(c.title, style: Styles.inter16500black(context).copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(c.description, style: Styles.inter14500black(context).copyWith(height: 1.6, fontWeight: FontWeight.w400)),
            if (c.orderNumber != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.receipt_long_outlined, 'adx_order'.tr(namedArgs: {'n': c.orderNumber!})),
            ],
            if (c.customer != null) ...[
              const SizedBox(height: 6),
              _infoRow(Icons.person_outline_rounded, [c.customer!.label, c.customer!.phoneNumber].whereType<String>().toSet().join(' · ')),
            ],
            if (c.attachments.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final src in c.attachments)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(width: 72, height: 72, child: DefaultCachedNetworkImage(imageUrl: src, fit: BoxFit.cover)),
                    ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: Styles.inter12500Black(context).copyWith(color: AppColors.primaryColor))),
        ],
      );

  /// Status actions (only what the server allows from here), priority and assignee.
  Widget _manage(AdminComplaint c) => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.allowedTransitions.isNotEmpty) ...[
              Text('adx_move_to'.tr(), style: Styles.inter14600black(context)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in c.allowedTransitions)
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _run(() => _repo.update(c.id, status: s, expectedStatus: c.status),
                              'adx_status_changed'.tr(namedArgs: {'s': AdxLabels.status(s)})),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        side: BorderSide(color: AppColors.primaryColor.withValues(alpha: .4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(AdxLabels.status(s), style: Styles.inter12500Black(context).copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const Divider(height: 24),
            ],
            _setting(
              icon: Icons.flag_outlined,
              label: 'adx_priority'.tr(),
              value: AdxChip.priority(c.priority),
              onTap: () => _pick<String>(
                'adx_priority'.tr(),
                [for (final p in const ['low', 'normal', 'high']) (p, AdxLabels.priority(p))],
                c.priority,
                (p) => _run(() => _repo.update(c.id, priority: p, expectedStatus: c.status), 'adx_saved'.tr()),
              ),
            ),
            _setting(
              icon: Icons.support_agent_rounded,
              label: 'adx_assignee'.tr(),
              value: Text(c.assignedTo?.label ?? 'adx_unassigned'.tr(),
                  style: Styles.inter12500Black(context).copyWith(fontWeight: FontWeight.w600)),
              onTap: () => _pick<int>(
                'adx_assignee'.tr(),
                [(0, 'adx_unassigned'.tr()), for (final a in _assignees) (a.id, a.label)],
                c.assignedTo?.id ?? 0,
                (id) => _run(
                  () => _repo.update(c.id, expectedStatus: c.status, assignedToId: id == 0 ? null : id, unassign: id == 0),
                  'adx_saved'.tr(),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _setting({required IconData icon, required String label, required Widget value, required VoidCallback onTap}) => InkWell(
        onTap: _busy ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xff6B7280)),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: Styles.inter14500black(context))),
              value,
              const Icon(Icons.chevron_right_rounded, color: Color(0xffB0B5BD)),
            ],
          ),
        ),
      );

  Widget _event(String text) => Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: .4), shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Styles.inter10400grey(context))),
        ],
      );

  Widget _message(AdminComplaintMessage m) {
    final when = adxDate(context, m.createdAt);
    final who = m.authorName ?? '';
    switch (m.kind) {
      case 'status_change':
        return _event('adx_ev_status'.tr(namedArgs: {'s': AdxLabels.status(m.toValue ?? ''), 'who': who, 'when': when}));
      case 'priority':
        return _event('adx_ev_priority'.tr(namedArgs: {'p': AdxLabels.priority(m.toValue ?? 'normal'), 'who': who, 'when': when}));
      case 'assignment':
        return _event('adx_ev_assign'.tr(namedArgs: {'who': who, 'when': when}));
    }
    final customer = m.authorRole == 'customer';
    final note = m.kind == 'internal_note';
    final bg = note ? const Color(0xFFFFF8E1) : customer ? Colors.white : AppColors.primaryColor.withValues(alpha: .08);
    return Align(
      alignment: customer ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .82),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: note ? const Color(0xFFF2D27A) : const Color(0xffEDEDED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (note) const Padding(padding: EdgeInsetsDirectional.only(end: 4), child: Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF8A5A00))),
                Flexible(
                  child: Text(
                    note ? 'adx_internal_by'.tr(namedArgs: {'who': who}) : customer ? 'adx_customer'.tr() : (who.isEmpty ? 'adx_support'.tr() : who),
                    style: Styles.inter12500Black(context).copyWith(fontWeight: FontWeight.w700, color: note ? const Color(0xFF8A5A00) : null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(m.body ?? '', style: Styles.inter14500black(context).copyWith(height: 1.5, fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            Text(when, style: Styles.inter10400grey(context)),
          ],
        ),
      ),
    );
  }

  Widget _composer(AdminComplaint c) {
    // Internal notes are always possible; replies only while the request is open.
    final internal = _internal || !c.canReply;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xffEDEDED)))),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: internal ? const Color(0xFFFFF8E1) : AppColors.primaryColor.withValues(alpha: .1),
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    ButtonSegment(value: false, enabled: c.canReply, label: Text('adx_reply_customer'.tr(), style: Styles.inter12500Black(context))),
                    ButtonSegment(value: true, label: Text('adx_internal_note'.tr(), style: Styles.inter12500Black(context))),
                  ],
                  selected: {internal},
                  onSelectionChanged: (s) => setState(() => _internal = s.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _reply,
                  enabled: !_busy,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 2000,
                  style: Styles.inter14500black(context),
                  decoration: InputDecoration(
                    hintText: internal ? 'adx_note_hint'.tr() : 'adx_reply_hint'.tr(),
                    hintStyle: Styles.inter14500black(context).copyWith(color: AppColors.gray),
                    counterText: '',
                    filled: true,
                    fillColor: internal ? const Color(0xFFFFFBEF) : const Color(0xffF7F7F8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 52,
                height: 52,
                child: IconButton.filled(
                  tooltip: 'adx_send'.tr(),
                  onPressed: _busy ? null : () { _internal = internal; _send(); },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
