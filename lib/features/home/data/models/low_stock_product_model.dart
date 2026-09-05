class LowStockProductModel {
  int? id;
  String? name;
  num? currentStock;
  num? sold;
  bool? isRecommended;

  LowStockProductModel({
    this.id,
    this.name,
    this.currentStock,
    this.sold,
    this.isRecommended,
  });

  LowStockProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    currentStock = json['currentStock'];
    sold = json['sold'];
    isRecommended = json['isRecommended'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentStock': currentStock,
      'sold': sold,
      'isRecommended': isRecommended,
    };
  }
}

class LowStockProductsMetadata {
  int? totalItems;
  int? itemsPerPage;
  int? totalPages;
  int? currentPage;

  LowStockProductsMetadata({
    this.totalItems,
    this.itemsPerPage,
    this.totalPages,
    this.currentPage,
  });

  LowStockProductsMetadata.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    itemsPerPage = json['itemsPerPage'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
  }
}

class LowStockProductsLinks {
  bool? hasNext;
  String? next;
  String? last;

  LowStockProductsLinks({this.hasNext, this.next, this.last});

  LowStockProductsLinks.fromJson(Map<String, dynamic> json) {
    hasNext = json['hasNext'];
    next = json['next'];
    last = json['last'];
  }
}

/// Wraps the `/orders/low-stock-products` paginated response:
/// `{ items: [...], metadata: {...}, links: {...} }`.
class LowStockProductsResponseModel {
  List<LowStockProductModel> items;
  LowStockProductsMetadata? metadata;
  LowStockProductsLinks? links;

  LowStockProductsResponseModel({
    List<LowStockProductModel>? items,
    this.metadata,
    this.links,
  }) : items = items ?? [];

  LowStockProductsResponseModel.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List? ?? [])
            .map((e) => LowStockProductModel.fromJson(e))
            .toList(),
        metadata = json['metadata'] != null
            ? LowStockProductsMetadata.fromJson(json['metadata'])
            : null,
        links = json['links'] != null
            ? LowStockProductsLinks.fromJson(json['links'])
            : null;
}
