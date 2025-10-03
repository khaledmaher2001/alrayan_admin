class ZonesModel {
  final bool? success;
  final String? message;
  final List<Zone>? data;

  ZonesModel({
    this.success,
    this.message,
    this.data,
  });

  factory ZonesModel.fromJson(Map<String, dynamic> json) {
    return ZonesModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Zone.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class Zone {
  final int? id;
  final String? name;
  final PolygonModel? polygon;
  final bool? isActive;
  final String? shippingCost;

  Zone({
    this.id,
    this.name,
    this.polygon,
    this.isActive,
    this.shippingCost,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as int?,
      name: json['name'] as String?,
      polygon: json['polygon'] != null
          ? PolygonModel.fromJson(json['polygon'] as Map<String, dynamic>)
          : null,
      isActive: json['isActive'] as bool?,
      shippingCost: json['shippingCost']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'polygon': polygon?.toJson(),
      'isActive': isActive,
      'shippingCost': shippingCost,
    };
  }
}

class PolygonModel {
  final String? type;
  final List<List<List<double>>>? coordinates;

  PolygonModel({
    this.type,
    this.coordinates,
  });

  factory PolygonModel.fromJson(Map<String, dynamic> json) {
    return PolygonModel(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List?)
          ?.map(
            (outer) => (outer as List)
            .map(
              (inner) => (inner as List)
              .map((coord) => (coord as num).toDouble())
              .toList(),
        )
            .toList(),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
