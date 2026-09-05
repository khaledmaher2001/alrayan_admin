class DeliveryAppSettingsModel {
  final int? id;
  final bool? delivery;
  final int? maxActiveDeliveriesPerCourier;

  DeliveryAppSettingsModel({
    this.id,
    this.delivery,
    this.maxActiveDeliveriesPerCourier,
  });

  factory DeliveryAppSettingsModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>) ? json['data'] : json;
    return DeliveryAppSettingsModel(
      id: (data['id'] as num?)?.toInt(),
      delivery: data['delivery'] as bool?,
      maxActiveDeliveriesPerCourier:
          (data['maxActiveDeliveriesPerCourier'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery': delivery,
      'maxActiveDeliveriesPerCourier': maxActiveDeliveriesPerCourier,
    };
  }
}
