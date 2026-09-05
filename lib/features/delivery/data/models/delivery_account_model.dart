class DeliveryAccountsModel {
  bool? success;
  String? message;
  DeliveryAccountsData? data;

  DeliveryAccountsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? DeliveryAccountsData.fromJson(json['data'])
        : null;
  }
}

class DeliveryAccountsData {
  List<DeliveryAccount>? items;
  DeliveryAccountsMetadata? metadata;

  DeliveryAccountsData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <DeliveryAccount>[];
      json['items'].forEach((v) {
        items!.add(DeliveryAccount.fromJson(v));
      });
    }
    metadata = json['metadata'] != null
        ? DeliveryAccountsMetadata.fromJson(json['metadata'])
        : null;
  }
}

class DeliveryAccountsMetadata {
  int? totalItems;
  int? itemsPerPage;
  int? totalPages;
  int? currentPage;

  DeliveryAccountsMetadata.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    itemsPerPage = json['itemsPerPage'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }
}

/// Two real shapes have been observed/documented for this entity:
///
///  A) `GET /delivery/accounts` items (confirmed from a live response) —
///     the courier's **user** fields sit at the top level (`id`, `fullName`,
///     `email`, `phoneNumber`, `isAvailableForDelivery`), with the
///     delivery-specific fields nested under `profile`.
///  B) `PATCH /delivery/accounts/{userId}/profile` (per the documented
///     `DeliveryProfile` Swagger schema) — the profile fields sit at the
///     top level, with the courier's user record nested under `user`.
///
/// `fromJson` detects which shape it got (by checking for a `profile` key)
/// and reads from the right place either way, so both endpoints map onto
/// the exact same public fields below.
///
/// Also confirmed from the live response: `earningPercentage` and
/// `walletBalance` are returned as numeric **strings** (e.g. `"80.00"`),
/// not JSON numbers — parsed defensively via [_parseNum].
class DeliveryAccount {
  int? userId;
  String fullName = '';
  String email = '';
  String phoneNumber = '';
  bool? isAvailableForDelivery;

  int? profileId;
  String? vehicleName;
  String? vehiclePlateNumber;
  num? earningPercentage;
  int? maxActiveOrdersOverride;
  num? walletBalance;
  String? createdAt;
  String? updatedAt;

  /// Full raw JSON for this item, kept so any field the server actually
  /// returns beyond what's recognized above can still be shown verbatim
  /// instead of being silently dropped or guessed at.
  final Map<String, dynamic> raw;

  DeliveryAccount.fromJson(Map<String, dynamic> json) : raw = json {
    final profileJson = json['profile'];

    if (profileJson is Map<String, dynamic>) {
      // Shape A — top level is the user record.
      userId = json['id'];
      fullName = json['fullName'] ?? '';
      email = json['email'] ?? '';
      phoneNumber = json['phoneNumber'] ?? '';
      isAvailableForDelivery = json['isAvailableForDelivery'];

      profileId = profileJson['id'];
      vehicleName = profileJson['vehicleName'];
      vehiclePlateNumber = profileJson['vehiclePlateNumber'];
      earningPercentage = _parseNum(profileJson['earningPercentage']);
      maxActiveOrdersOverride =
          profileJson['maxActiveOrdersOverride'] ??
          profileJson['maxActiveOrders'];
      walletBalance = _parseNum(profileJson['walletBalance']);
      createdAt = profileJson['createdAt'];
      updatedAt = profileJson['updatedAt'];
    } else {
      // Shape B — top level is the delivery profile.
      final userJson = json['user'];
      final user = userJson is Map<String, dynamic> ? userJson : null;

      userId = json['userId'] ?? user?['id'];
      fullName = user?['fullName'] ?? '';
      email = user?['email'] ?? '';
      phoneNumber = user?['phoneNumber'] ?? '';
      isAvailableForDelivery = user?['isAvailableForDelivery'];

      profileId = json['id'];
      vehicleName = json['vehicleName'];
      vehiclePlateNumber = json['vehiclePlateNumber'];
      earningPercentage = _parseNum(json['earningPercentage']);
      maxActiveOrdersOverride =
          json['maxActiveOrdersOverride'] ?? json['maxActiveOrders'];
      walletBalance = _parseNum(json['walletBalance']);
      createdAt = json['createdAt'];
      updatedAt = json['updatedAt'];
    }
  }
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
