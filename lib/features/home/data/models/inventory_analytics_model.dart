class InventoryAnalyticsModel {
  int? id;
  String? name;
  num? currentStock;
  num? totalSold;
  num? currentPrice;
  num? totalInventory;
  num? sellThroughRate;

  InventoryAnalyticsModel({
    this.id,
    this.name,
    this.currentStock,
    this.totalSold,
    this.currentPrice,
    this.totalInventory,
    this.sellThroughRate,
  });

  InventoryAnalyticsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    currentStock = json['currentStock'];
    totalSold = json['totalSold'];
    currentPrice = json['currentPrice'];
    totalInventory = json['totalInventory'];
    sellThroughRate = json['sellThroughRate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentStock': currentStock,
      'totalSold': totalSold,
      'currentPrice': currentPrice,
      'totalInventory': totalInventory,
      'sellThroughRate': sellThroughRate,
    };
  }
}

class InventoryAnalyticsMetadata {
  int? totalItems;
  int? itemsPerPage;
  int? totalPages;
  int? currentPage;

  InventoryAnalyticsMetadata({
    this.totalItems,
    this.itemsPerPage,
    this.totalPages,
    this.currentPage,
  });

  InventoryAnalyticsMetadata.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    itemsPerPage = json['itemsPerPage'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }
}

/// Wraps the `/orders/inventory-analytics` paginated response:
/// `{ items: [...], metadata: {...} }`.
class InventoryAnalyticsResponseModel {
  List<InventoryAnalyticsModel> items;
  InventoryAnalyticsMetadata? metadata;

  InventoryAnalyticsResponseModel({
    List<InventoryAnalyticsModel>? items,
    this.metadata,
  }) : items = items ?? [];

  InventoryAnalyticsResponseModel.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List? ?? [])
            .map((e) => InventoryAnalyticsModel.fromJson(e))
            .toList(),
        metadata = json['metadata'] != null
            ? InventoryAnalyticsMetadata.fromJson(json['metadata'])
            : null;
}
