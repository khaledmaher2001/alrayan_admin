import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';

class ProductsRepoImpl implements ProductsRepo {
  final ApiService? apiService;

  ProductsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, ProductsModel>> getProducts({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.products, query: data, sendToken: true);
      var result = ProductsModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      print(e);
      if (e is DioException) {
        print(e.response);

        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Data>> getProductDetails({required int productId}) async {
    try {
      var response = await apiService!.get(endPoint: "${EndPoints.products}/$productId", sendToken: true);
      var result = Data.fromJson(response.data["data"]);
      return right(result);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> createProduct({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.postData(
        endPoint: EndPoints.products,
        sendToken: true,
        data: FormData.fromMap(data),
      );
      return right(response.data["message"]);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> editProduct({required Map<String, dynamic> data, required int id}) async {
    try {
      var response = await apiService!.patchData(
        endPoint: "${EndPoints.products}/$id",
        sendToken: true,
        data: FormData.fromMap(data),
      );
      return right(response.data["message"]);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> deleteProduct({required int id}) async {
    try {
      var response = await apiService!.deleteData(endPoint: "${EndPoints.products}/$id", sendToken: true);
      return right(response.data["message"]);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }  @override
  Future<Either<Failure, String>> deleteProductAttachments({required int id}) async {
    try {
      var response = await apiService!.deleteData(endPoint: "${EndPoints.products}/remove-attachment/$id", sendToken: true);
      return right("");
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
