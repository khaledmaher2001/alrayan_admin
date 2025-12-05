import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';


abstract class AdsRepo {
  Future<Either<Failure, bool>> addAds({required var data,void Function(int, int)? onSendProgress,});

}
