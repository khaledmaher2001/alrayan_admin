/// One level of "spins by order value": an order whose products total (after
/// discounts, delivery excluded) reaches [minAmount] earns [spins].
class SpinOrderRule {
  num minAmount;
  int spins;

  SpinOrderRule({required this.minAmount, required this.spins});

  factory SpinOrderRule.fromJson(Map<String, dynamic> json) => SpinOrderRule(
        minAmount: num.tryParse('${json['minAmount']}') ?? 0,
        spins: int.tryParse('${json['spins']}') ?? 1,
      );

  Map<String, dynamic> toJson() => {'minAmount': minAmount, 'spins': spins};

  SpinOrderRule copy() => SpinOrderRule(minAmount: minAmount, spins: spins);
}

/// `GET/PATCH rewards/config`: lucky time (orders earn spins) + the order rules.
class SpinWheelConfigModel {
  final bool earningOpen;
  final List<SpinOrderRule> orderRules;

  SpinWheelConfigModel({required this.earningOpen, required this.orderRules});

  factory SpinWheelConfigModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map ? json['data'] : json) as Map;
    return SpinWheelConfigModel(
      earningOpen: data['earningOpen'] == true,
      orderRules: [
        for (final r in (data['orderRules'] as List? ?? const []))
          if (r is Map) SpinOrderRule.fromJson(Map<String, dynamic>.from(r)),
      ]..sort((a, b) => a.minAmount.compareTo(b.minAmount)),
    );
  }

  /// Spins an order of [amount] earns (same rule as the server: highest level
  /// reached wins; no rules = 1 spin per delivered order).
  static int spinsFor(num amount, List<SpinOrderRule> rules) {
    final active = rules.where((r) => r.spins > 0).toList()
      ..sort((a, b) => b.minAmount.compareTo(a.minAmount));
    if (active.isEmpty) return 1;
    for (final r in active) {
      if (amount >= r.minAmount) return r.spins;
    }
    return 0;
  }
}
