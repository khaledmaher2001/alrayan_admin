class LowStockConfigModel {
  final int? threshold;

  LowStockConfigModel({this.threshold});

  factory LowStockConfigModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>) ? json['data'] : json;
    return LowStockConfigModel(
      threshold: (data['threshold'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'threshold': threshold};
  }
}
