import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/delivery_account_model.dart';
import '../models/delivery_statistics_model.dart';
import '../models/delivery_transaction_model.dart';
import '../models/delivery_wallet_model.dart';
import '../models/release_log_model.dart';
import '../models/remittance_model.dart';

abstract class DeliveryRepo {
  Future<Either<Failure, DeliveryAccountsModel>> getDeliveryAccounts({
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, DeliveryStatisticsModel>> getDeliveryStatistics();

  Future<Either<Failure, DeliveryAccount>> createDeliveryAccount({
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, DeliveryAccount>> updateDeliveryProfile({
    required int userId,
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, bool>> deleteDeliveryAccount(int userId);

  Future<Either<Failure, DeliveryWalletModel>> getDeliveryWallet(int userId);

  Future<Either<Failure, DeliveryTransactionsModel>> getDeliveryTransactions({
    required int userId,
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, ReleaseLogsModel>> getReleaseLogs({
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, RemittancesModel>> getRemittances({
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, String>> approveRemittance(int id);

  Future<Either<Failure, String>> rejectRemittance(int id);
}
