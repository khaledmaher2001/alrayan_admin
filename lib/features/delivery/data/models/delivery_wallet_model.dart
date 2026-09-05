/// `GET /delivery/accounts/{userId}/wallet` has no documented response
/// schema in Swagger. This model never invents field names: it keeps the
/// full raw map for display, and only exposes `balance` if one of the
/// field names already confirmed elsewhere in this API (`walletBalance` on
/// the documented `DeliveryProfile` schema, or the common `balance`
/// spelling) is actually present in the response.
class DeliveryWalletModel {
  bool? success;
  String? message;
  DeliveryWallet? data;

  DeliveryWalletModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    final body = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    data = DeliveryWallet.fromJson(body);
  }
}

class DeliveryWallet {
  num? balance;

  /// Full raw JSON of the wallet object, used to render any field the
  /// server actually returns without guessing its meaning.
  final Map<String, dynamic> raw;

  DeliveryWallet.fromJson(Map<String, dynamic> json) : raw = json {
    for (final key in ['walletBalance', 'balance', 'currentBalance']) {
      final value = json[key];
      if (value is num) {
        balance = value;
        break;
      }
      // Money fields on this API are commonly returned as numeric strings
      // (e.g. "81.00") rather than JSON numbers — see delivery_transaction_model.dart.
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) {
          balance = parsed;
          break;
        }
      }
    }
  }
}
