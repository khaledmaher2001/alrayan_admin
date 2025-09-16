import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class ProductsRepo {
  Future<Either<Failure, ProductsModel>> getProducts({required Map<String, dynamic> data});

  Future<Either<Failure, Data>> getProductDetails({required int productId});

  Future<Either<Failure, String>> createProduct({required Map<String, dynamic> data});
  Future<Either<Failure, String>> editProduct({required Map<String, dynamic> data,required int id});
  Future<Either<Failure, String>> deleteProduct({required int id});
  Future<Either<Failure, String>> deleteProductAttachments({required int id});
}
