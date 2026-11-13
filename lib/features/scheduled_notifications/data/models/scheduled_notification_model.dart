/// A staff-written push to customers, sent now or at a set time (once, daily
/// or weekly). Shape of `GET scheduled-notifications` items (service toView +
/// withLabels).
class ScheduledNotificationModel {
  final int id;
  final String title;
  final String message;
  final String? imagePath;
  final String? imageUrl;

  /// 'all' | 'users'
  final String audience;
  final List<int> userIds;
  final int? usersCount;

  /// 'Home' | 'ProductDetails' | 'Category' | 'SubCategory' | 'Offers'
  final String targetScreen;
  final int? targetId;
  final String? targetLabel;

  /// Main category of a 'SubCategory' target (to preselect the pickers when editing).
  final int? targetCategoryId;

  /// 'none' | 'daily' | 'weekly'
  final String repeat;
  final String? sendAt;
  final String? nextRunAt;

  /// 'scheduled' | 'sending' | 'sent' | 'cancelled' | 'failed'
  final String status;
  final int runCount;
  final String? lastRunAt;
  final int? lastRecipients;
  final String? lastError;
  final String? createdByName;

  ScheduledNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.imagePath,
    this.imageUrl,
    required this.audience,
    required this.userIds,
    this.usersCount,
    required this.targetScreen,
    this.targetId,
    this.targetLabel,
    this.targetCategoryId,
    required this.repeat,
    this.sendAt,
    this.nextRunAt,
    required this.status,
    required this.runCount,
    this.lastRunAt,
    this.lastRecipients,
    this.lastError,
    this.createdByName,
  });

  static int? _int(dynamic v) => v == null ? null : int.tryParse('$v');
  static String? _str(dynamic v) => v == null || '$v'.isEmpty ? null : '$v';

  factory ScheduledNotificationModel.fromJson(Map<String, dynamic> json) => ScheduledNotificationModel(
        id: _int(json['id']) ?? 0,
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        imagePath: _str(json['imagePath']),
        imageUrl: _str(json['imageUrl']),
        audience: json['audience']?.toString() ?? 'all',
        userIds: [for (final e in (json['userIds'] as List? ?? const [])) ?_int(e)],
        usersCount: _int(json['usersCount']),
        targetScreen: json['targetScreen']?.toString() ?? 'Home',
        targetId: _int(json['targetId']),
        targetLabel: _str(json['targetLabel']),
        targetCategoryId: _int(json['targetCategoryId']),
        repeat: json['repeat']?.toString() ?? 'none',
        sendAt: _str(json['sendAt']),
        nextRunAt: _str(json['nextRunAt']),
        status: json['status']?.toString() ?? 'scheduled',
        runCount: _int(json['runCount']) ?? 0,
        lastRunAt: _str(json['lastRunAt']),
        lastRecipients: _int(json['lastRecipients']),
        lastError: _str(json['lastError']),
        createdByName: _str(json['createdByName']),
      );

  bool get isScheduled => status == 'scheduled';
}

/// A page of the list plus the per-status counts for the tabs.
class ScheduledNotificationsPage {
  final List<ScheduledNotificationModel> items;
  final int total;
  final int page;
  final int limit;
  final Map<String, int> counts;

  ScheduledNotificationsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.counts,
  });

  factory ScheduledNotificationsPage.fromJson(Map<String, dynamic> json) {
    // The endpoint answers without the usual {data: …} wrapper; accept both.
    final data = (json['data'] is Map ? json['data'] : json) as Map;
    final counts = <String, int>{};
    if (data['counts'] is Map) {
      (data['counts'] as Map).forEach((k, v) => counts['$k'] = int.tryParse('$v') ?? 0);
    }
    return ScheduledNotificationsPage(
      items: [
        for (final e in (data['items'] as List? ?? const []))
          if (e is Map) ScheduledNotificationModel.fromJson(Map<String, dynamic>.from(e)),
      ],
      total: int.tryParse('${data['total'] ?? 0}') ?? 0,
      page: int.tryParse('${data['page'] ?? 1}') ?? 1,
      limit: int.tryParse('${data['limit'] ?? 20}') ?? 20,
      counts: counts,
    );
  }
}

/// `POST scheduled-notifications/image` → where the uploaded image lives.
class UploadedImage {
  final String path;
  final String? url;
  const UploadedImage({required this.path, this.url});
}

/// A category for the "tap opens a category" picker.
class NotificationCategoryOption {
  final int id;
  final String name;
  final List<NotificationCategoryOption> subCategories;
  const NotificationCategoryOption({required this.id, required this.name, this.subCategories = const []});
}
