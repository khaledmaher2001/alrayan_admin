/// `GET /delivery/wallet/remittances` has no documented response schema
/// beyond its query filters (`status`, `courierId`, `page`, `limit`,
/// `sortBy`, `sortOrder`). Field names below follow the conventions already
/// confirmed for the sibling wallet/transactions/release-log endpoints in
/// this module (nested `courier` object or flat `courierId`, money fields
/// possibly sent as numeric strings) — never inventing a name that hasn't
/// been seen elsewhere in this API.
class RemittancesModel {
  bool? success;
  String? message;
  RemittancesData? data;

  RemittancesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? RemittancesData.fromJson(json['data'])
        : null;
  }
}

class RemittancesData {
  List<Remittance>? items;
  RemittancesMetadata? metadata;

  RemittancesData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Remittance>[];
      json['items'].forEach((v) {
        items!.add(Remittance.fromJson(v));
      });
    }
    metadata = json['metadata'] != null
        ? RemittancesMetadata.fromJson(json['metadata'])
        : null;
  }
}

class RemittancesMetadata {
  int? totalItems;
  int? itemsPerPage;
  int? totalPages;
  int? currentPage;

  RemittancesMetadata.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    itemsPerPage = json['itemsPerPage'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }
}

class Remittance {
  int? id;
  int? courierId;
  String? courierName;
  num? amount;
  String? status;
  String? note;
  String? createdAt;

  /// Full raw JSON for this remittance, used to render any extra field the
  /// server actually returns beyond what's recognized above.
  final Map<String, dynamic> raw;

  Remittance.fromJson(Map<String, dynamic> json) : raw = json {
    id = json['id'];
    status = json['status'] is String ? json['status'] : null;
    createdAt = json['createdAt'] ?? json['date'];
    note = json['note'] ?? json['notes'] ?? json['reason'];

    final courier = json['courier'];
    if (courier is Map<String, dynamic>) {
      courierId = courier['id'];
      courierName = courier['fullName'];
    } else if (json['courierId'] is int) {
      courierId = json['courierId'];
    }

    amount = _num(json, ['amount', 'remittedAmount', 'value']);
  }
}

num? _num(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}
