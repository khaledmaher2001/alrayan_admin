import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../models/lucky_wheel_model.dart';

abstract class LuckyWheelRepo{
  Future<Either<Failure,String>> createLuckyItem({required Map<String,dynamic> data});
  Future<Either<Failure, LuckyWheelModel>> getLuckyWheelItems();
  Future<Either<Failure, String>> deleteLuckyItem({required int itemId});

}