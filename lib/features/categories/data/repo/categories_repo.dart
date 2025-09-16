import 'package:alrayan_admin/features/categories/data/models/sub_categories_model.dart';
import 'package:dartz/dartz.dart';
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import '../../../../core/errors/failure.dart';

abstract class CategoriesRepo{
  Future<Either<Failure,CategoriesModel>> getCategories();
  Future<Either<Failure,SubCategoriesModel>> getSubCategories({required int mainCategoryId});
  Future<Either<Failure,String>> createCategory({required Map<String,dynamic> data});
  Future<Either<Failure,String>> editCategory({required Map<String,dynamic> data,required int categoryId});
  Future<Either<Failure,String>> deleteCategory({required int categoryId});
  Future<Either<Failure,String>> createSubCategory({required Map<String,dynamic> data});
  Future<Either<Failure,String>> editSubCategory({required Map<String,dynamic> data,required int subCategoryId});
  Future<Either<Failure,String>> deleteSubCategory({required int subCategoryId});

}