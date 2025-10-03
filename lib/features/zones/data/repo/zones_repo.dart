import 'package:alrayan_admin/features/zones/data/models/zones_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class ZonesRepo{
  Future<Either<Failure,ZonesModel>> getZones();
  Future<Either<Failure,String>> addZone({required Map<String,dynamic> data});
  Future<Either<Failure,String>> editZone({required int zoneId,required Map<String,dynamic> data});
  Future<Either<Failure,String>> deleteZone({required int zoneId});

}