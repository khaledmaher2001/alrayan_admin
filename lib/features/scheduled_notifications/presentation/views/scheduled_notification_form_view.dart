import 'dart:io';

import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/image_picker_dialog.dart';
import 'package:alrayan_admin/core/shared_widgets/search_pick_sheet.dart';
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/helpers/cairo_time.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/scheduled_notification_model.dart';
import '../../data/repo/scheduled_notifications_repo_impl.dart';
import '../view_models/save_scheduled_notification/save_scheduled_notification_cubit.dart';
import 'widgets/push_preview.dart';

const _targets = ['Home', 'ProductDetails', 'Category', 'SubCategory', 'Offers'];
const _repeats = ['none', 'daily', 'weekly'];

/// Create / edit a push. [copy] = "send again" (a new one prefilled from [item]).
/// Pops true when saved.
class ScheduledNotificationFormView extends StatelessWidget {
  const ScheduledNotificationFormView({super.key, this.item, this.copy = false});

  final ScheduledNotificationModel? item;
  final bool copy;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SaveScheduledNotificationCubit(getIt.get<ScheduledNotificationsRepoImpl>()),
      child: _FormBody(item: item, copy: copy),
    );
  }
}

class _FormBody extends StatefulWidget {
  const _FormBody({this.item, required this.copy});
  final ScheduledNotificationModel? item;
  final bool copy;

  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final _repo = getIt.get<ScheduledNotificationsRepoImpl>();
  final _title = TextEditingController();
  final _message = TextEditingController();

  UploadedImage? _image;
  File? _localImage;
  String _audience = 'all';
  List<PickOption> _customers = [];
  String _target = 'Home';
  PickOption? _product;
  int? _categoryId;
  int? _subCategoryId; // with _categoryId as its main category when _target == 'SubCategory'
  List<NotificationCategoryOption> _categories = [];
  bool _now = true;
  late DateTime _wall; // Cairo wall-clock time of the send
  String _repeat = 'none';
  String? _error;
  bool _tried = false;

  bool get _editing => widget.item != null && !widget.copy;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final nowWall = CairoTime.now();
    _wall = DateTime.utc(nowWall.year, nowWall.month, nowWall.day, nowWall.hour).add(const Duration(hours: 1));
    if (item != null) {
      _title.text = item.title;
      _message.text = item.message;
      _audience = item.audience;
      _customers = [for (final id in item.userIds) PickOption(id: id, label: '#$id')];
      _target = _targets.contains(item.targetScreen) ? item.targetScreen : 'Home';
      if (item.targetScreen == 'ProductDetails' && item.targetId != null) {
        _product = PickOption(id: item.targetId!, label: item.targetLabel ?? '#${item.targetId}');
      }
      if (item.targetScreen == 'Category') _categoryId = item.targetId;
      if (item.targetScreen == 'SubCategory') {
        _categoryId = item.targetCategoryId;
        _subCategoryId = item.targetId;
      }
      _repeat = _repeats.contains(item.repeat) ? item.repeat : 'none';
      if (item.imagePath != null) _image = UploadedImage(path: item.imagePath!, url: item.imageUrl);
      final next = DateTime.tryParse(item.nextRunAt ?? '');
      if (_editing && next != null && next.isAfter(DateTime.now())) {
        _now = false;
        _wall = CairoTime.wall(next);
      }
      if (_now) _repeat = _editing ? _repeat : 'none';
      _loadCustomerNames(item.userIds);
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await _repo.getCategories();
      if (mounted) setState(() => _categories = list);
    } catch (_) {}
  }

  /// Names for the customers of an existing notification (ids are all it stores).
  Future<void> _loadCustomerNames(List<int> ids) async {
    if (ids.isEmpty) return;
    final named = await Future.wait(ids.take(50).map(_repo.customerById));
    if (!mounted) return;
    setState(() {
      _customers = [
        for (final c in _customers) named.firstWhere((n) => n.id == c.id, orElse: () => c),
      ];
    });
  }

  Future<void> _pickImage() async {
    final source = await showImageSourceSelector(context);
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() => _localImage = File(picked.path));
    context.read<SaveScheduledNotificationCubit>().uploadImage(picked.path);
  }

  Future<void> _pickCustomers() async {
    final picked = await showSearchPickSheet(
      context,
      title: "sn_customers".tr(),
      hint: "sn_customers_ph".tr(),
      search: _repo.searchCustomers,
      selected: _customers,
    );
    if (picked != null) setState(() => _customers = picked);
  }

  Future<void> _pickProduct() async {
    final picked = await showSearchPickSheet(
      context,
      title: "sn_product".tr(),
      hint: "sn_product_ph".tr(),
      search: _repo.searchProducts,
      selected: _product == null ? const [] : [_product!],
      multiple: false,
    );
    if (picked != null && picked.isNotEmpty) setState(() => _product = picked.first);
  }

  Future<void> _pickCategory() async {
    if (_categories.isEmpty) await _loadCategories();
    if (!mounted) return;
    final options = _target == 'SubCategory' ? _categories.where((c) => c.subCategories.isNotEmpty).toList() : _categories;
    final picked = await _pickFrom("sn_category".tr(), options, _categoryId);
    if (picked != null) {
      setState(() {
        if (picked != _categoryId) _subCategoryId = null;
        _categoryId = picked;
      });
    }
  }

  List<NotificationCategoryOption> get _subOptions =>
      _categories.where((c) => c.id == _categoryId).map((c) => c.subCategories).firstOrNull ?? const [];

  Future<void> _pickSubCategory() async {
    if (_categoryId == null) return;
    if (_categories.isEmpty) await _loadCategories();
    if (!mounted) return;
    final picked = await _pickFrom("sn_subcategory".tr(), _subOptions, _subCategoryId);
    if (picked != null) setState(() => _subCategoryId = picked);
  }

  Future<int?> _pickFrom(String title, List<NotificationCategoryOption> options, int? selected) {
    return showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: DsColor.page,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DsRadius.lg))),
      builder: (sheet) => FractionallySizedBox(
        heightFactor: .7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DsSpace.page),
              child: Text(title, style: DsText.heading),
            ),
            Expanded(
              child: options.isEmpty
                  ? DsMessage(icon: Icons.category_outlined, title: "pick_no_results".tr())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(DsSpace.page, 0, DsSpace.page, DsSpace.lg),
                      children: [
                        DsGroup(children: [
                          for (final c in options)
                            DsRow(
                              title: c.name,
                              trailing: c.id == selected ? const Icon(Icons.check_circle, color: DsColor.primary) : null,
                              onTap: () => Navigator.of(sheet).pop(c.id),
                            ),
                        ]),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final today = CairoTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(_wall.year, _wall.month, _wall.day),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year, today.month, today.day).add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _wall.hour, minute: _wall.minute));
    if (time == null) return;
    setState(() => _wall = DateTime.utc(date.year, date.month, date.day, time.hour, time.minute));
  }

  String get _who => _audience == 'users'
      ? "sn_some_customers".tr(namedArgs: {"n": DsFormat.count(_customers.length)})
      : "sn_all_customers".tr();

  String get _summary => "sn_summary".tr(namedArgs: {
        "who": _who,
        "when": _now ? "sn_summary_now".tr() : "sn_summary_at".tr(namedArgs: {"d": CairoTime.formatWall(context, _wall)}),
        "rep": _repeat == 'none' ? '' : "sn_summary_rep_$_repeat".tr(),
      });

  String? _validate() {
    if (_title.text.trim().isEmpty || _message.text.trim().isEmpty) return "sn_fill_required".tr();
    if (_audience == 'users' && _customers.isEmpty) return "sn_customers_req".tr();
    if (_target == 'ProductDetails' && _product == null) return "sn_product_req".tr();
    if (_target == 'Category' && _categoryId == null) return "sn_category_req".tr();
    if (_target == 'SubCategory' && (_categoryId == null || _subCategoryId == null)) return "sn_subcategory_req".tr();
    if (!_now) {
      final at = CairoTime.fromWall(_wall.year, _wall.month, _wall.day, _wall.hour, _wall.minute);
      if (!at.isAfter(DateTime.now())) return "sn_past_err".tr();
    }
    return null;
  }

  Future<void> _submit(bool uploading) async {
    if (uploading) return;
    setState(() {
      _tried = true;
      _error = _validate();
    });
    if (_error != null) return;
    if (_now && !_editing) {
      final ok = await dsConfirm(
        context,
        title: "sn_sure_now".tr(),
        message: "sn_sure_now_body".tr(namedArgs: {"who": _who}),
        confirmLabel: "sn_yes_send".tr(),
      );
      if (!ok || !mounted) return;
    }
    final sendAt = _now
        ? DateTime.now().toUtc()
        : CairoTime.fromWall(_wall.year, _wall.month, _wall.day, _wall.hour, _wall.minute);
    final body = <String, dynamic>{
      "title": _title.text.trim(),
      "message": _message.text.trim(),
      "imagePath": _image?.path,
      "audience": _audience,
      if (_audience == 'users') "userIds": _customers.map((c) => c.id).toList(),
      "targetScreen": _target,
      "targetId": _target == 'ProductDetails'
          ? _product?.id
          : _target == 'Category'
              ? _categoryId
              : _target == 'SubCategory'
                  ? _subCategoryId
                  : null,
      "sendAt": sendAt.toIso8601String(),
      "repeat": _now ? 'none' : _repeat,
    };
    if (!mounted) return;
    context.read<SaveScheduledNotificationCubit>().save(id: _editing ? widget.item!.id : null, body: body, sentNow: _now);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SaveScheduledNotificationCubit, SaveScheduledNotificationState>(
      listener: (context, state) {
        if (state is ScheduledImageUploadedState) {
          setState(() => _image = state.image);
        } else if (state is ScheduledImageUploadErrorState) {
          setState(() => _localImage = null);
          toast(text: "${"sn_upload_fail".tr()} — ${state.error}", color: DsColor.danger);
        } else if (state is SaveScheduledNotificationSuccessState) {
          toast(
            text: state.edited ? "sn_saved".tr() : state.sentNow ? "sn_sent_ok".tr() : "sn_created".tr(),
            color: DsColor.success,
          );
          Navigator.of(context).pop(true);
        } else if (state is SaveScheduledNotificationErrorState) {
          setState(() => _error = state.error);
        }
      },
      builder: (context, state) {
        final uploading = state is ScheduledImageUploadingState;
        final saving = state is SaveScheduledNotificationLoadingState;
        return Scaffold(
          backgroundColor: DsColor.page,
          bottomNavigationBar: DsBottomBar(
            child: DsButton(
              label: _editing ? "sn_save".tr() : _now ? "sn_send_now".tr() : "sn_schedule".tr(),
              icon: Icons.send_rounded,
              loading: saving,
              onPressed: uploading ? null : () => _submit(uploading),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                DsTopBar(title: _editing ? "sn_edit".tr() : widget.copy ? "sn_again".tr() : "sn_add".tr()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(DsSpace.page, DsSpace.sm, DsSpace.page, DsSpace.xxl),
                    children: [
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(DsSpace.md),
                          decoration: BoxDecoration(color: DsColor.dangerBg, borderRadius: BorderRadius.circular(DsRadius.md)),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: DsColor.danger, size: DsSize.iconSm),
                              const SizedBox(width: DsSpace.sm),
                              Expanded(child: Text(_error!, style: DsText.caption.copyWith(color: DsColor.danger))),
                            ],
                          ),
                        ),
                        const SizedBox(height: DsSpace.md),
                      ],
                      PushPreview(
                        title: _title.text,
                        message: _message.text,
                        imageUrl: _image?.url,
                        localImage: _localImage,
                      ),
                      const SizedBox(height: DsSpace.xl),
                      DsField(
                        label: "sn_f_title".tr(),
                        required: true,
                        child: TextField(
                          controller: _title,
                          maxLength: 120,
                          onChanged: (_) => setState(() {}),
                          style: DsText.body,
                          decoration: dsInput(hint: "sn_f_title_ph".tr()).copyWith(
                            errorText: _tried && _title.text.trim().isEmpty ? "sn_required".tr() : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: DsSpace.md),
                      DsField(
                        label: "sn_f_msg".tr(),
                        required: true,
                        help: "sn_f_msg_hint".tr(),
                        child: TextField(
                          controller: _message,
                          maxLength: 1000,
                          minLines: 3,
                          maxLines: 6,
                          onChanged: (_) => setState(() {}),
                          style: DsText.body,
                          decoration: dsInput(hint: "sn_f_msg_ph".tr()).copyWith(
                            errorText: _tried && _message.text.trim().isEmpty ? "sn_required".tr() : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: DsSpace.xl),
                      DsField(
                        label: "sn_f_image".tr(),
                        help: "sn_f_image_hint".tr(),
                        child: _buildImagePicker(uploading),
                      ),
                      const SizedBox(height: DsSpace.xl),
                      DsField(
                        label: "sn_f_audience".tr(),
                        child: _Choices(
                          values: const ['all', 'users'],
                          labelOf: (v) => v == 'all' ? "sn_all_customers".tr() : "sn_customers".tr(),
                          selected: _audience,
                          onSelect: (v) => setState(() => _audience = v),
                        ),
                      ),
                      if (_audience == 'users') ...[
                        const SizedBox(height: DsSpace.sm),
                        _PickerTile(
                          icon: Icons.person_search_outlined,
                          text: _customers.isEmpty
                              ? "sn_customers_ph".tr()
                              : "sn_some_customers".tr(namedArgs: {"n": DsFormat.count(_customers.length)}),
                          empty: _customers.isEmpty,
                          error: _tried && _customers.isEmpty,
                          onTap: _pickCustomers,
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
                        label: "sn_f_target".tr(),
                        child: _Choices(
                          values: _targets,
                          labelOf: (v) => "sn_target_$v".tr(),
                          selected: _target,
                          onSelect: (v) => setState(() {
                            _target = v;
                            _product = null;
                            _categoryId = null;
                            _subCategoryId = null;
                          }),
                        ),
                      ),
                      if (_target == 'ProductDetails') ...[
                        const SizedBox(height: DsSpace.sm),
                        _PickerTile(
                          icon: Icons.inventory_2_outlined,
                          text: _product?.label ?? "sn_product_ph".tr(),
                          empty: _product == null,
                          error: _tried && _product == null,
                          onTap: _pickProduct,
                        ),
                      ],
                      if (_target == 'Category') ...[
                        const SizedBox(height: DsSpace.sm),
                        _PickerTile(
                          icon: Icons.category_outlined,
                          text: _categories.where((c) => c.id == _categoryId).map((c) => c.name).firstOrNull ??
                              (_categoryId != null ? (widget.item?.targetLabel ?? '#$_categoryId') : "sn_pick_category".tr()),
                          empty: _categoryId == null,
                          error: _tried && _categoryId == null,
                          onTap: _pickCategory,
                        ),
                      ],
                      if (_target == 'SubCategory') ...[
                        const SizedBox(height: DsSpace.sm),
                        _PickerTile(
                          icon: Icons.category_outlined,
                          text: _categories.where((c) => c.id == _categoryId).map((c) => c.name).firstOrNull ??
                              (_categoryId != null ? '#$_categoryId' : "sn_pick_category".tr()),
                          empty: _categoryId == null,
                          error: _tried && _categoryId == null,
                          onTap: _pickCategory,
                        ),
                        const SizedBox(height: DsSpace.sm),
                        _PickerTile(
                          icon: Icons.account_tree_outlined,
                          text: _subOptions.where((c) => c.id == _subCategoryId).map((c) => c.name).firstOrNull ??
                              (_subCategoryId != null
                                  ? (widget.item?.targetLabel ?? '#$_subCategoryId')
                                  : _categoryId == null
                                      ? "sn_pick_category_first".tr()
                                      : "sn_pick_subcategory".tr()),
                          empty: _subCategoryId == null,
                          error: _tried && _categoryId != null && _subCategoryId == null,
                          onTap: _pickSubCategory,
                        ),
                      ],
                      const SizedBox(height: DsSpace.xl),
                      DsField(
                        label: "sn_f_when".tr(),
                        child: _Choices(
                          values: const ['now', 'later'],
                          labelOf: (v) => v == 'now' ? "sn_now".tr() : "sn_later".tr(),
                          selected: _now ? 'now' : 'later',
                          onSelect: (v) => setState(() {
                            _now = v == 'now';
                            if (_now) _repeat = 'none';
                          }),
                        ),
                      ),
                      if (!_now) ...[
                        const SizedBox(height: DsSpace.sm),
                        _PickerTile(
                          icon: Icons.event_outlined,
                          text: "${CairoTime.formatWall(context, _wall)}  (${"sn_cairo".tr()})",
                          empty: false,
                          error: false,
                          onTap: _pickDateTime,
                        ),
                        const SizedBox(height: DsSpace.xl),
                        DsField(
                          label: "sn_f_repeat".tr(),
                          child: _Choices(
                            values: _repeats,
                            labelOf: (v) => "sn_repeat_$v".tr(),
                            selected: _repeat,
                            onSelect: (v) => setState(() => _repeat = v),
                          ),
                        ),
                      ],
                      const SizedBox(height: DsSpace.xl),
                      Container(
                        padding: const EdgeInsets.all(DsSpace.md),
                        decoration: BoxDecoration(color: DsColor.infoBg, borderRadius: BorderRadius.circular(DsRadius.md)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: DsSize.iconSm, color: DsColor.info),
                            const SizedBox(width: DsSpace.sm),
                            Expanded(child: Text(_summary, style: DsText.caption.copyWith(color: DsColor.info))),
                          ],
                        ),
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

  Widget _buildImagePicker(bool uploading) {
    final hasImage = _localImage != null || _image != null;
    if (!hasImage) {
      return DsCard(
        onTap: uploading ? null : _pickImage,
        child: Column(
          children: [
            const Icon(Icons.add_photo_alternate_outlined, color: DsColor.textMuted, size: 28),
            const SizedBox(height: DsSpace.xs),
            Text("sn_pick_image".tr(), style: DsText.body.copyWith(fontWeight: FontWeight.w600)),
            Text("JPG · PNG · WebP", style: DsText.caption),
          ],
        ),
      );
    }
    final Widget thumb = _localImage != null
        ? Image.file(_localImage!, width: 80, height: 80, fit: BoxFit.cover)
        : Image.network(_image!.url ?? '', width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(width: 80, height: 80, color: DsColor.fill));
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(DsRadius.md), child: thumb),
            if (uploading)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(DsRadius.md)),
                child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
              ),
          ],
        ),
        const SizedBox(width: DsSpace.md),
        Expanded(
          child: uploading
              ? Text("sn_uploading".tr(), style: DsText.caption)
              : Wrap(
                  spacing: DsSpace.sm,
                  runSpacing: DsSpace.sm,
                  children: [
                    DsButton(label: "sn_change_image".tr(), kind: DsButtonKind.secondary, expand: false, onPressed: _pickImage),
                    DsButton(
                      label: "sn_remove_image".tr(),
                      kind: DsButtonKind.destructive,
                      expand: false,
                      onPressed: () => setState(() {
                        _image = null;
                        _localImage = null;
                      }),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// A row of selectable chips (one choice).
class _Choices extends StatelessWidget {
  const _Choices({required this.values, required this.labelOf, required this.selected, required this.onSelect});
  final List<String> values;
  final String Function(String) labelOf;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: DsSpace.sm,
        runSpacing: DsSpace.sm,
        children: [
          for (final v in values) DsChip(label: labelOf(v), selected: v == selected, onTap: () => onSelect(v)),
        ],
      );
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.icon, required this.text, required this.empty, required this.error, required this.onTap});
  final IconData icon;
  final String text;
  final bool empty;
  final bool error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DsCard(
        onTap: onTap,
        highlight: error ? DsColor.danger : null,
        padding: const EdgeInsets.symmetric(horizontal: DsSpace.lg, vertical: DsSpace.md),
        child: Row(
          children: [
            Icon(icon, color: DsColor.textMuted),
            const SizedBox(width: DsSpace.md),
            Expanded(
              child: Text(text, style: DsText.body.copyWith(color: empty ? DsColor.textSubtle : DsColor.text)),
            ),
            const Icon(Icons.chevron_right_rounded, color: DsColor.textSubtle),
          ],
        ),
      );
}
