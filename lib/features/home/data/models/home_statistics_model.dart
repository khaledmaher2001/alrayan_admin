class HomeStatisticsModel {
  Overview? overview;
  RecentStats? recentStats;
  OrderStats? orderStats;
  ProductStats? productStats;
  Trends? trends;

  HomeStatisticsModel(
      {this.overview,
        this.recentStats,
        this.orderStats,
        this.productStats,
        this.trends});

  HomeStatisticsModel.fromJson(Map<String, dynamic> json) {
    overview = json['overview'] != null
        ? new Overview.fromJson(json['overview'])
        : null;
    recentStats = json['recentStats'] != null
        ? new RecentStats.fromJson(json['recentStats'])
        : null;
    orderStats = json['orderStats'] != null
        ? new OrderStats.fromJson(json['orderStats'])
        : null;
    productStats = json['productStats'] != null
        ? new ProductStats.fromJson(json['productStats'])
        : null;
    trends =
    json['trends'] != null ? new Trends.fromJson(json['trends']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.overview != null) {
      data['overview'] = this.overview!.toJson();
    }
    if (this.recentStats != null) {
      data['recentStats'] = this.recentStats!.toJson();
    }
    if (this.orderStats != null) {
      data['orderStats'] = this.orderStats!.toJson();
    }
    if (this.productStats != null) {
      data['productStats'] = this.productStats!.toJson();
    }
    if (this.trends != null) {
      data['trends'] = this.trends!.toJson();
    }
    return data;
  }
}

class Overview {
  dynamic totalRevenue;
  int? totalOrders;
  int? totalProducts;
  int? totalCustomers;
  dynamic averageOrderValue;
  dynamic completionRate;

  Overview(
      {this.totalRevenue,
        this.totalOrders,
        this.totalProducts,
        this.totalCustomers,
        this.averageOrderValue,
        this.completionRate});

  Overview.fromJson(Map<String, dynamic> json) {
    totalRevenue = json['totalRevenue'];
    totalOrders = json['totalOrders'];
    totalProducts = json['totalProducts'];
    totalCustomers = json['totalCustomers'];
    averageOrderValue = json['averageOrderValue'];
    completionRate = json['completionRate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalRevenue'] = this.totalRevenue;
    data['totalOrders'] = this.totalOrders;
    data['totalProducts'] = this.totalProducts;
    data['totalCustomers'] = this.totalCustomers;
    data['averageOrderValue'] = this.averageOrderValue;
    data['completionRate'] = this.completionRate;
    return data;
  }
}

class RecentStats {
  int? todayRevenue;
  int? todayOrders;
  int? weeklyRevenue;
  int? weeklyOrders;
  dynamic monthlyRevenue;
  int? monthlyOrders;

  RecentStats(
      {this.todayRevenue,
        this.todayOrders,
        this.weeklyRevenue,
        this.weeklyOrders,
        this.monthlyRevenue,
        this.monthlyOrders});

  RecentStats.fromJson(Map<String, dynamic> json) {
    todayRevenue = json['todayRevenue'];
    todayOrders = json['todayOrders'];
    weeklyRevenue = json['weeklyRevenue'];
    weeklyOrders = json['weeklyOrders'];
    monthlyRevenue = json['monthlyRevenue'];
    monthlyOrders = json['monthlyOrders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['todayRevenue'] = this.todayRevenue;
    data['todayOrders'] = this.todayOrders;
    data['weeklyRevenue'] = this.weeklyRevenue;
    data['weeklyOrders'] = this.weeklyOrders;
    data['monthlyRevenue'] = this.monthlyRevenue;
    data['monthlyOrders'] = this.monthlyOrders;
    return data;
  }
}

class OrderStats {
  List<OrdersByStatus>? ordersByStatus;
  List<OrdersByPaymentStatus>? ordersByPaymentStatus;
  List<OrdersByPaymentMethod>? ordersByPaymentMethod;

  OrderStats(
      {this.ordersByStatus,
        this.ordersByPaymentStatus,
        this.ordersByPaymentMethod});

  OrderStats.fromJson(Map<String, dynamic> json) {
    if (json['ordersByStatus'] != null) {
      ordersByStatus = <OrdersByStatus>[];
      json['ordersByStatus'].forEach((v) {
        ordersByStatus!.add(new OrdersByStatus.fromJson(v));
      });
    }
    if (json['ordersByPaymentStatus'] != null) {
      ordersByPaymentStatus = <OrdersByPaymentStatus>[];
      json['ordersByPaymentStatus'].forEach((v) {
        ordersByPaymentStatus!.add(new OrdersByPaymentStatus.fromJson(v));
      });
    }
    if (json['ordersByPaymentMethod'] != null) {
      ordersByPaymentMethod = <OrdersByPaymentMethod>[];
      json['ordersByPaymentMethod'].forEach((v) {
        ordersByPaymentMethod!.add(new OrdersByPaymentMethod.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.ordersByStatus != null) {
      data['ordersByStatus'] =
          this.ordersByStatus!.map((v) => v.toJson()).toList();
    }
    if (this.ordersByPaymentStatus != null) {
      data['ordersByPaymentStatus'] =
          this.ordersByPaymentStatus!.map((v) => v.toJson()).toList();
    }
    if (this.ordersByPaymentMethod != null) {
      data['ordersByPaymentMethod'] =
          this.ordersByPaymentMethod!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrdersByStatus {
  String? status;
  int? count;
  dynamic percentage;

  OrdersByStatus({this.status, this.count, this.percentage});

  OrdersByStatus.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    data['percentage'] = this.percentage;
    return data;
  }
}

class OrdersByPaymentStatus {
  String? status;
  int? count;
  int? percentage;

  OrdersByPaymentStatus({this.status, this.count, this.percentage});

  OrdersByPaymentStatus.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    data['percentage'] = this.percentage;
    return data;
  }
}

class OrdersByPaymentMethod {
  String? method;
  int? count;
  int? percentage;

  OrdersByPaymentMethod({this.method, this.count, this.percentage});

  OrdersByPaymentMethod.fromJson(Map<String, dynamic> json) {
    method = json['method'];
    count = json['count'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['method'] = this.method;
    data['count'] = this.count;
    data['percentage'] = this.percentage;
    return data;
  }
}

class ProductStats {
  List<TopSellingProducts>? topSellingProducts;
  List<LowStockProducts>? lowStockProducts;
  List<CategoryPerformance>? categoryPerformance;

  ProductStats(
      {this.topSellingProducts,
        this.lowStockProducts,
        this.categoryPerformance});

  ProductStats.fromJson(Map<String, dynamic> json) {
    if (json['topSellingProducts'] != null) {
      topSellingProducts = <TopSellingProducts>[];
      json['topSellingProducts'].forEach((v) {
        topSellingProducts!.add(new TopSellingProducts.fromJson(v));
      });
    }
    if (json['lowStockProducts'] != null) {
      lowStockProducts = <LowStockProducts>[];
      json['lowStockProducts'].forEach((v) {
        lowStockProducts!.add(new LowStockProducts.fromJson(v));
      });
    }
    if (json['categoryPerformance'] != null) {
      categoryPerformance = <CategoryPerformance>[];
      json['categoryPerformance'].forEach((v) {
        categoryPerformance!.add(new CategoryPerformance.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.topSellingProducts != null) {
      data['topSellingProducts'] =
          this.topSellingProducts!.map((v) => v.toJson()).toList();
    }
    if (this.lowStockProducts != null) {
      data['lowStockProducts'] =
          this.lowStockProducts!.map((v) => v.toJson()).toList();
    }
    if (this.categoryPerformance != null) {
      data['categoryPerformance'] =
          this.categoryPerformance!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TopSellingProducts {
  int? id;
  String? name;
  int? totalSold;
  dynamic revenue;
  int? averagePrice;

  TopSellingProducts(
      {this.id, this.name, this.totalSold, this.revenue, this.averagePrice});

  TopSellingProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    totalSold = json['totalSold'];
    revenue = json['revenue'];
    averagePrice = json['averagePrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['totalSold'] = this.totalSold;
    data['revenue'] = this.revenue;
    data['averagePrice'] = this.averagePrice;
    return data;
  }
}

class LowStockProducts {
  int? id;
  String? name;
  int? currentStock;
  int? sold;
  bool? isRecommended;

  LowStockProducts(
      {this.id, this.name, this.currentStock, this.sold, this.isRecommended});

  LowStockProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    currentStock = json['currentStock'];
    sold = json['sold'];
    isRecommended = json['isRecommended'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['currentStock'] = this.currentStock;
    data['sold'] = this.sold;
    data['isRecommended'] = this.isRecommended;
    return data;
  }
}

class CategoryPerformance {
  int? categoryId;
  String? categoryName;
  int? totalProducts;
  int? totalSold;
  dynamic revenue;

  CategoryPerformance(
      {this.categoryId,
        this.categoryName,
        this.totalProducts,
        this.totalSold,
        this.revenue});

  CategoryPerformance.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    totalProducts = json['totalProducts'];
    totalSold = json['totalSold'];
    revenue = json['revenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryId'] = this.categoryId;
    data['categoryName'] = this.categoryName;
    data['totalProducts'] = this.totalProducts;
    data['totalSold'] = this.totalSold;
    data['revenue'] = this.revenue;
    return data;
  }
}

class Trends {
  List<DailyRevenue>? dailyRevenue;
  List<WeeklyRevenue>? weeklyRevenue;
  List<MonthlyRevenue>? monthlyRevenue;

  Trends({this.dailyRevenue, this.weeklyRevenue, this.monthlyRevenue});

  Trends.fromJson(Map<String, dynamic> json) {
    if (json['dailyRevenue'] != null) {
      dailyRevenue = <DailyRevenue>[];
      json['dailyRevenue'].forEach((v) {
        dailyRevenue!.add(new DailyRevenue.fromJson(v));
      });
    }
    if (json['weeklyRevenue'] != null) {
      weeklyRevenue = <WeeklyRevenue>[];
      json['weeklyRevenue'].forEach((v) {
        weeklyRevenue!.add(new WeeklyRevenue.fromJson(v));
      });
    }
    if (json['monthlyRevenue'] != null) {
      monthlyRevenue = <MonthlyRevenue>[];
      json['monthlyRevenue'].forEach((v) {
        monthlyRevenue!.add(new MonthlyRevenue.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dailyRevenue != null) {
      data['dailyRevenue'] = this.dailyRevenue!.map((v) => v.toJson()).toList();
    }
    if (this.weeklyRevenue != null) {
      data['weeklyRevenue'] =
          this.weeklyRevenue!.map((v) => v.toJson()).toList();
    }
    if (this.monthlyRevenue != null) {
      data['monthlyRevenue'] =
          this.monthlyRevenue!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DailyRevenue {
  String? date;
  dynamic revenue;
  int? orders;

  DailyRevenue({this.date, this.revenue, this.orders});

  DailyRevenue.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    revenue = json['revenue'];
    orders = json['orders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['revenue'] = this.revenue;
    data['orders'] = this.orders;
    return data;
  }
}

class WeeklyRevenue {
  String? week;
  dynamic revenue;
  int? orders;

  WeeklyRevenue({this.week, this.revenue, this.orders});

  WeeklyRevenue.fromJson(Map<String, dynamic> json) {
    week = json['week'];
    revenue = json['revenue'];
    orders = json['orders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['week'] = this.week;
    data['revenue'] = this.revenue;
    data['orders'] = this.orders;
    return data;
  }
}

class MonthlyRevenue {
  String? month;
  dynamic revenue;
  int? orders;

  MonthlyRevenue({this.month, this.revenue, this.orders});

  MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    revenue = json['revenue'];
    orders = json['orders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['month'] = this.month;
    data['revenue'] = this.revenue;
    data['orders'] = this.orders;
    return data;
  }
}