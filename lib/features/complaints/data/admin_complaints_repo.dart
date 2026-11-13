import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/api_service.dart';

/// Staff side of "الشكاوى والمقترحات" — same endpoints as the web dashboard.
class AdminComplaintsRepo {
  AdminComplaintsRepo(this._api);
  final ApiService _api;

  static const _base = 'complaints-suggestions';

  Future<AdminComplaintsPage> list({required String filter, int page = 1}) async {
    final query = <String, dynamic>{'page': page, 'limit': 20};
    if (filter == 'open') query['status'] = 'open';
    if (filter == 'overdue') query['overdue'] = 'true';
    final res = await _api.get(endPoint: _base, sendToken: true, query: query);
    return AdminComplaintsPage.fromJson(res.data['data']);
  }

  Future<AdminComplaintStats> stats() async {
    final res = await _api.get(endPoint: '$_base/stats', sendToken: true);
    return AdminComplaintStats.fromJson(res.data['data']);
  }

  Future<AdminComplaint> details(int id) async {
    final res = await _api.get(endPoint: '$_base/$id', sendToken: true);
    return AdminComplaint.fromJson(res.data['data']);
  }

  Future<List<AdminPerson>> assignees() async {
    final res = await _api.get(endPoint: '$_base/assignees', sendToken: true);
    return ((res.data['data'] as List?) ?? []).map((e) => AdminPerson.fromJson(e)).toList();
  }

  /// [expectedStatus] makes the server refuse the change if someone else
  /// moved the request in the meantime.
  Future<void> update(int id, {String? status, required String expectedStatus, String? priority, int? assignedToId, bool unassign = false}) async {
    final data = <String, dynamic>{'expectedStatus': expectedStatus};
    if (status != null) data['status'] = status;
    if (priority != null) data['priority'] = priority;
    if (assignedToId != null) data['assignedToId'] = assignedToId;
    if (unassign) data['assignedToId'] = null;
    await _api.patchData(endPoint: '$_base/$id', data: data);
  }

  Future<void> addMessage(int id, {required String body, required bool internal}) async {
    await _api.postData(endPoint: '$_base/$id/messages', sendToken: true, data: {'body': body, 'internal': internal});
  }

  /// Server message for the user, falling back to a generic text.
  static String errorText(Object e) {
    if (e is DioException) {
      final m = e.response?.data is Map ? e.response?.data['message'] : null;
      if (m is String && m.isNotEmpty) return m;
      if (m is List && m.isNotEmpty) return m.first.toString();
    }
    return 'adx_error'.tr();
  }
}

class AdminPerson {
  AdminPerson({required this.id, this.fullName, this.email, this.phoneNumber});
  final int id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;

  factory AdminPerson.fromJson(Map<String, dynamic> j) =>
      AdminPerson(id: j['id'], fullName: j['fullName'], email: j['email'], phoneNumber: j['phoneNumber']);

  String get label => (fullName ?? '').trim().isNotEmpty ? fullName!.trim() : (email ?? phoneNumber ?? '#$id');
}

class AdminComplaintMessage {
  AdminComplaintMessage({required this.kind, required this.authorRole, this.authorName, this.body, this.fromValue, this.toValue, required this.createdAt});
  final String kind; // reply, internal_note, status_change, assignment, priority
  final String authorRole; // customer, staff, system
  final String? authorName;
  final String? body;
  final String? fromValue;
  final String? toValue;
  final DateTime createdAt;

  factory AdminComplaintMessage.fromJson(Map<String, dynamic> j) => AdminComplaintMessage(
        kind: j['kind'] ?? 'reply',
        authorRole: j['authorRole'] ?? 'staff',
        authorName: j['author'] is Map ? j['author']['fullName'] : null,
        body: j['body'],
        fromValue: j['fromValue'],
        toValue: j['toValue'],
        createdAt: DateTime.tryParse(j['createdAt'] ?? '')?.toLocal() ?? DateTime.now(),
      );
}

class AdminComplaint {
  AdminComplaint({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.description,
    required this.status,
    required this.priority,
    required this.isOverdue,
    required this.canReply,
    required this.createdAt,
    required this.updatedAt,
    this.orderNumber,
    this.customer,
    this.assignedTo,
    this.attachments = const [],
    this.allowedTransitions = const [],
    this.messages = const [],
  });

  final int id;
  final String title, type, category, description, status, priority;
  final bool isOverdue, canReply;
  final DateTime createdAt, updatedAt;
  final String? orderNumber;
  final AdminPerson? customer;
  final AdminPerson? assignedTo;
  final List<String> attachments;
  final List<String> allowedTransitions;
  final List<AdminComplaintMessage> messages;

  factory AdminComplaint.fromJson(Map<String, dynamic> j) {
    final order = j['order'];
    return AdminComplaint(
      id: j['id'],
      title: j['title'] ?? '',
      type: j['type'] ?? 'complaint',
      category: j['category'] ?? 'other',
      description: j['description'] ?? '',
      status: j['status'] ?? 'pending',
      priority: j['priority'] ?? 'normal',
      isOverdue: j['isOverdue'] == true,
      canReply: j['canReply'] == true,
      createdAt: DateTime.tryParse(j['createdAt'] ?? '')?.toLocal() ?? DateTime.now(),
      updatedAt: DateTime.tryParse(j['updatedAt'] ?? '')?.toLocal() ?? DateTime.now(),
      orderNumber: j['orderNumber'] ?? (order is Map ? order['orderNumber'] : null),
      customer: j['user'] is Map ? AdminPerson.fromJson(Map<String, dynamic>.from(j['user'])) : null,
      assignedTo: j['assignedTo'] is Map ? AdminPerson.fromJson(Map<String, dynamic>.from(j['assignedTo'])) : null,
      attachments: ((j['attachments'] as List?) ?? []).map((e) => e.toString()).toList(),
      allowedTransitions: ((j['allowedTransitions'] as List?) ?? []).map((e) => e.toString()).toList(),
      messages: ((j['messages'] as List?) ?? []).map((e) => AdminComplaintMessage.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

class AdminComplaintsPage {
  AdminComplaintsPage({required this.items, required this.hasNext, required this.total});
  final List<AdminComplaint> items;
  final bool hasNext;
  final int total;

  factory AdminComplaintsPage.fromJson(Map<String, dynamic> j) => AdminComplaintsPage(
        items: ((j['items'] as List?) ?? []).map((e) => AdminComplaint.fromJson(Map<String, dynamic>.from(e))).toList(),
        hasNext: j['links'] is Map && j['links']['hasNext'] == true,
        total: j['metadata'] is Map ? (j['metadata']['totalItems'] ?? 0) : 0,
      );
}

class AdminComplaintStats {
  AdminComplaintStats({required this.open, required this.overdue, required this.unassignedOpen, required this.overdueHours});
  final int open, overdue, unassignedOpen, overdueHours;

  factory AdminComplaintStats.fromJson(Map<String, dynamic> j) => AdminComplaintStats(
        open: j['open'] ?? 0,
        overdue: j['overdue'] ?? 0,
        unassignedOpen: j['unassignedOpen'] ?? 0,
        overdueHours: j['overdueHours'] ?? 48,
      );
}

/// Translated labels for the API's enum values.
class AdxLabels {
  static String type(String v) => 'adx_type_$v'.tr();
  static String category(String v) => 'adx_cat_$v'.tr();
  static String status(String v) => 'adx_status_$v'.tr();
  static String priority(String v) => 'adx_priority_$v'.tr();
}
