/// A customer and the spins saved on their account (`GET rewards/attempts`).
class SpinCustomer {
  final int id;
  final String? fullName;
  final String? phoneNumber;
  int attemptCount;
  final String? lastGrantedAt;
  final String? lastSpunAt;

  SpinCustomer({
    required this.id,
    this.fullName,
    this.phoneNumber,
    required this.attemptCount,
    this.lastGrantedAt,
    this.lastSpunAt,
  });

  factory SpinCustomer.fromJson(Map<String, dynamic> json) => SpinCustomer(
        id: int.tryParse('${json['id']}') ?? 0,
        fullName: json['fullName']?.toString(),
        phoneNumber: json['phoneNumber']?.toString(),
        attemptCount: int.tryParse('${json['attemptCount']}') ?? 0,
        lastGrantedAt: json['lastGrantedAt']?.toString(),
        lastSpunAt: json['lastSpunAt']?.toString(),
      );

  String get displayName => (fullName ?? '').trim().isEmpty ? '#$id' : fullName!.trim();
}

/// Wheel figures shown above the customers list.
class SpinStats {
  final int holders;
  final int savedSpins;
  final int fromOrders30d;
  final int fromStaff30d;
  final int spun30d;

  const SpinStats({
    this.holders = 0,
    this.savedSpins = 0,
    this.fromOrders30d = 0,
    this.fromStaff30d = 0,
    this.spun30d = 0,
  });

  static int _i(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

  factory SpinStats.fromJson(Map<String, dynamic> json) => SpinStats(
        holders: _i(json['holders']),
        savedSpins: _i(json['savedSpins']),
        fromOrders30d: _i(json['fromOrders30d']),
        fromStaff30d: _i(json['fromStaff30d']),
        spun30d: _i(json['spun30d']),
      );
}

class SpinAttemptsModel {
  final List<SpinCustomer> items;
  final SpinStats stats;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  SpinAttemptsModel({
    required this.items,
    required this.stats,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory SpinAttemptsModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map ? json['data'] : json) as Map;
    final meta = (data['metadata'] is Map ? data['metadata'] : const {}) as Map;
    return SpinAttemptsModel(
      items: [
        for (final e in (data['items'] as List? ?? const []))
          if (e is Map) SpinCustomer.fromJson(Map<String, dynamic>.from(e)),
      ],
      stats: data['stats'] is Map
          ? SpinStats.fromJson(Map<String, dynamic>.from(data['stats']))
          : const SpinStats(),
      totalItems: int.tryParse('${meta['totalItems'] ?? 0}') ?? 0,
      totalPages: int.tryParse('${meta['totalPages'] ?? 1}') ?? 1,
      currentPage: int.tryParse('${meta['currentPage'] ?? 1}') ?? 1,
    );
  }
}
