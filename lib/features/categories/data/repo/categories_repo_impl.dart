import 'package:alrayan_admin/features/categories/data/models/sub_categories_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:alrayan_admin/core/errors/failure.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo.dart';
import '../../../../core/utils/services/remote_services/api_service.dart';
import '../../../../core/utils/services/remote_services/endpoints.dart';

class CategoriesRepoImpl implements CategoriesRepo {
  final ApiService? apiService;

  CategoriesRepoImpl(this.apiService);

  @override
  Future<Either<Failure, CategoriesModel>> getCategories() async {
    try {
      var response = await apiService!.get(endPoint: EndPoints.categories, sendToken: true);
      var result = CategoriesModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, SubCategoriesModel>> getSubCategories({required int mainCategoryId}) async {
    try {
      var response = await apiService!.get(
        endPoint: EndPoints.subCategories,
        query: {"main_category": mainCategoryId},
        sendToken: true,
      );
      var result = SubCategoriesModel.fromJson(response.data);
      return right(result);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> createCategory({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.postData(
        endPoint: EndPoints.categories,
        data: FormData.fromMap(data),
        sendToken: true,
      );
      return right(response.data["message"]);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> editCategory({required Map<String, dynamic> data, required int categoryId}) async {
    try {
      var response = await apiService!.patchData(
        endPoint: "${EndPoints.categories}/$categoryId",
        data: FormData.fromMap(data),
        sendToken: true,
      );
      return right(response.data["message"]);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> deleteCategory({required int categoryId}) async {
    try {
      var response = await apiService!.deleteData(endPoint: "${EndPoints.categories}/$categoryId", sendToken: true);
      return right(response.data["message"]);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> createSubCategory({required Map<String, dynamic> data}) async {
    try {
      var response = await apiService!.postData(
        endPoint: EndPoints.subCategories,
        data: FormData.fromMap(data),
        sendToken: true,
      );
      return right(response.data["message"]);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> editSubCategory({
    required Map<String, dynamic> data,
    required int subCategoryId,
  }) async {
    try {
      var response = await apiService!.patchData(
        endPoint: "${EndPoints.subCategories}/$subCategoryId",
        data: FormData.fromMap(data),
        sendToken: true,
      );
      return right(response.data["message"]);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> deleteSubCategory({required int subCategoryId}) async {
    try {
      var response = await apiService!.deleteData(endPoint: "${EndPoints.categories}/$subCategoryId", sendToken: true);
      return right(response.data["message"]);
    } catch (e) {
      print("RRRRRRRRRRRRRRRRRRRR:${e.toString()}");
      if (e is DioException) {
        print(e.response);
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
