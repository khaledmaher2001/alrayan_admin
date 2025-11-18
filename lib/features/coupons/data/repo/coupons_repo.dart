import 'package:alrayan_admin/features/categories/data/models/sub_categories_model.dart';
import 'package:dartz/dartz.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import '../../../../core/errors/failure.dart';

abstract class CouponsRepo{
  Future<Either<Failure,String>> createCoupon({required Map<String,dynamic> data});

}