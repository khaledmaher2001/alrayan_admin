class LoyaltyConfigModel {
  int? pointsEarnRatio;
  double? pointsRedeemValue;
  bool? enabled;

  LoyaltyConfigModel({
    this.pointsEarnRatio,
    this.pointsRedeemValue,
    this.enabled,
  });

  factory LoyaltyConfigModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>) ? json['data'] : json;
    return LoyaltyConfigModel(
      pointsEarnRatio: (data['pointsEarnRatio'] as num?)?.round(),
      pointsRedeemValue: (data['pointsRedeemValue'] as num?)?.toDouble(),
      enabled: data['enabled'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pointsEarnRatio': pointsEarnRatio,
      'pointsRedeemValue': pointsRedeemValue,
      'enabled': enabled,
    };
  }
}
