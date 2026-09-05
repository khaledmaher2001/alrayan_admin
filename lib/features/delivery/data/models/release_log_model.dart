/// `GET /delivery/release-logs` has no documented response schema, but its
/// query filters are `orderId` and `courierId` — almost certainly the real
/// column names on the log entity, since that convention holds for every
/// other filter/field-name pair already verified in this app. `reason` is
/// the exact field name accepted by `PATCH /orders/{id}/release`
/// (`ReleaseOrderDto.reason`), the action that produces these log rows.
class ReleaseLogsModel {
  bool? success;
  String? message;
  ReleaseLogsData? data;

  ReleaseLogsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ReleaseLogsData.fromJson(json['data']) : null;
  }
}

class ReleaseLogsData {
  List<ReleaseLog>? items;
  ReleaseLogsMetadata? metadata;

  ReleaseLogsData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <ReleaseLog>[];
      json['items'].forEach((v) {
        items!.add(ReleaseLog.fromJson(v));
      });
    }
    metadata = json['metadata'] != null
        ? ReleaseLogsMetadata.fromJson(json['metadata'])
        : null;
  }
}

class ReleaseLogsMetadata {
  int? totalItems;
  int? itemsPerPage;
  int? totalPages;
  int? currentPage;

  ReleaseLogsMetadata.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    itemsPerPage = json['itemsPerPage'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }
}

class ReleaseLog {
  int? id;
  int? orderId;
  String? orderNumber;
  int? courierId;
  String? courierName;
  String? courierPhone;
  String? reason;
  String? createdAt;

  /// `courier_voluntary` | `customer_unreachable` — the documented release
  /// types. Parsed from whichever key the server actually uses; unknown
  /// values fall through untranslated.
  String? releaseType;

  /// Order status before / after the release. No documented schema — parsed
  /// defensively from several plausible key names, null when absent.
  String? statusBefore;
  String? statusAfter;

  /// Who performed the release (admin / system / the courier themselves).
  String? performedByName;
  String? performedByRole;

  /// Full raw JSON for this log row, used to render any extra field the
  /// server actually returns beyond what's recognized above.
  final Map<String, dynamic> raw;

  ReleaseLog.fromJson(Map<String, dynamic> json) : raw = json {
    id = json['id'];
    reason = json['reason'];
    createdAt = json['createdAt'];

    releaseType = _str(json, const ['releaseType', 'release_type', 'type']);
    statusBefore = _str(json, const [
      'statusBefore',
      'status_before',
      'previousStatus',
      'fromStatus',
      'oldStatus',
    ]);
    statusAfter = _str(json, const [
      'statusAfter',
      'status_after',
      'newStatus',
      'toStatus',
      'resultingStatus',
    ]);

    final order = json['order'];
    if (order is Map<String, dynamic>) {
      orderId = order['id'];
      orderNumber = order['orderNumber'];
    } else if (json['orderId'] is int) {
      orderId = json['orderId'];
    }

    final courier = json['courier'];
    if (courier is Map<String, dynamic>) {
      courierId = courier['id'];
      courierName = courier['fullName'] ?? courier['name'];
      courierPhone = courier['phoneNumber'] ?? courier['phone'];
    } else if (json['courierId'] is int) {
      courierId = json['courierId'];
    }
    courierName ??= _str(json, const ['courierName']);
    courierPhone ??= _str(json, const ['courierPhone']);

    final actor =
        json['performedBy'] ??
        json['actor'] ??
        json['admin'] ??
        json['createdBy'];
    if (actor is Map<String, dynamic>) {
      performedByName = actor['fullName'] ?? actor['name'];
      performedByRole = actor['role'];
    }
    performedByName ??= _str(json, const [
      'performedByName',
      'actorName',
      'adminName',
    ]);
    performedByRole ??= _str(json, const ['performedByRole', 'actorRole']);
  }

  static String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}
