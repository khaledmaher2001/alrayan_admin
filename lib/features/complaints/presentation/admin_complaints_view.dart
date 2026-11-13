import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/api_service.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';

import '../data/admin_complaints_repo.dart';
import 'admin_complaint_details_view.dart';
import 'widgets/adx_widgets.dart';

/// Complaints, inquiries and suggestions from customers (staff view).
class AdminComplaintsView extends StatefulWidget {
  const AdminComplaintsView({super.key});

  @override
  State<AdminComplaintsView> createState() => _AdminComplaintsViewState();
}

class _AdminComplaintsViewState extends State<AdminComplaintsView> {
  final _repo = AdminComplaintsRepo(getIt.get<ApiService>());
  final _scroll = ScrollController();

  String _filter = 'open';
  final List<AdminComplaint> _items = [];
  AdminComplaintStats? _stats;
  int _page = 1;
  bool _hasNext = false, _loading = true, _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) _loadMore();
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([_repo.list(filter: _filter), _repo.stats()]);
      final page = results[0] as AdminComplaintsPage;
      if (!mounted) return;
      setState(() {
        _items..clear()..addAll(page.items);
        _hasNext = page.hasNext;
        _page = 1;
        _stats = results[1] as AdminComplaintStats;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = AdminComplaintsRepo.errorText(e); });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasNext || _loadingMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _repo.list(filter: _filter, page: _page + 1);
      if (!mounted) return;
      setState(() { _items.addAll(page.items); _hasNext = page.hasNext; _page++; });
    } catch (_) {
      // The next scroll tries again.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _setFilter(String f) {
    if (f == _filter) return;
    setState(() => _filter = f);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'more_complaints'.tr(), hasBack: true, withNotifications: false, textColor: Colors.black),
            if (_stats != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                child: Row(
                  children: [
                    AdxStat(label: 'adx_open'.tr(), value: _stats!.open, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    AdxStat(label: 'adx_overdue'.tr(namedArgs: {'h': '${_stats!.overdueHours}'}), value: _stats!.overdue, color: const Color(0xffB91C1C)),
                    const SizedBox(width: 8),
                    AdxStat(label: 'adx_unassigned'.tr(), value: _stats!.unassignedOpen, color: const Color(0xffB45309)),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(AppConstants.width20(context), 12, AppConstants.width20(context), 4),
              child: Row(
                children: [
                  for (final f in const ['open', 'overdue', 'all']) ...[
                    if (f != 'open') const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('adx_filter_$f'.tr()),
                      selected: _filter == f,
                      showCheckmark: false,
                      onSelected: (_) => _setFilter(f),
                      labelStyle: Styles.inter12500Black(context).copyWith(
                        color: _filter == f ? Colors.white : const Color(0xff374151),
                        fontWeight: FontWeight.w600,
                      ),
                      selectedColor: AppColors.primaryColor,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: _filter == f ? AppColors.primaryColor : const Color(0xffE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return AdxMessage(
        icon: Icons.wifi_off_rounded,
        title: _error!,
        action: TextButton(onPressed: _load, child: Text('home_retry'.tr())),
      );
    }
    if (_items.isEmpty) {
      return AdxMessage(icon: Icons.inbox_outlined, title: 'adx_empty_$_filter'.tr());
    }
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: ListView.separated(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(AppConstants.width20(context), 8, AppConstants.width20(context), 24),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i >= _items.length) {
            return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
          }
          final c = _items[i];
          return AdxComplaintCard(
            c: c,
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminComplaintDetailsView(id: c.id)));
              _load(silent: true);
            },
          );
        },
      ),
    );
  }
}
