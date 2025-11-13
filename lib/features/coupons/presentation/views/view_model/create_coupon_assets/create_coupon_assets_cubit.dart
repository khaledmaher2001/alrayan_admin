import 'package:alrayan_admin/features/products/data/models/products_model.dart'as prod;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../all_users/data/models/all_users_model.dart'as user;
import '../../../../../categories/data/models/categories_model.dart'as cat;


part 'create_coupon_assets_state.dart';

class CreateCouponAssetsCubit extends Cubit<CreateCouponAssetsState> {
  CreateCouponAssetsCubit() : super(CreateCouponAssetsInitial());

  static CreateCouponAssetsCubit get(context) => BlocProvider.of(context);

  final createCouponFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountPercentageValueController = TextEditingController();
  final discountFixedValueController = TextEditingController();
  final discountTypeController = TextEditingController();
  final minOrderAmountController = TextEditingController();
  final maxDiscountAmountController = TextEditingController();
  final usageLimitController = TextEditingController();
  List<prod.Items> selectedProducts=[];
  List<cat.Data> selectedCategories=[];
  List<user.Items> selectedUsers=[];

  DateTime? selectedDate;
  String? couponType;
  String? usersType;

  void clearAllData()
  {
    selectedProducts.clear();
    selectedUsers.clear();
    selectedCategories.clear();
    dateController.clear();
    usageLimitController.text='';
    maxDiscountAmountController.text='';
    minOrderAmountController.text='';
    discountTypeController.text='';
    discountFixedValueController.text='';
    discountPercentageValueController.text='';
    descriptionController.text='';
    codeController.text='';
    nameController.text='';
    dateController.text='';

  }
  void selectCouponType({required String type})
  {
    couponType=type;
    emit(SelectCouponTypeSuccessState());
  }
  void selectUsersType({required String type})
  {
    usersType=type;
    emit(SelectUsersTypeSuccessState());
  }

  void selectProducts({required prod.Items instance}){
   selectedProducts.add(instance);
   emit(SelectProductSuccessState());
  }
  void removeProduct({required prod.Items instance}){
   selectedProducts.remove(instance);
   emit(SelectProductSuccessState());
  }

  void selectUser({required user.Items instance}){
   selectedUsers.add(instance);
   emit(SelectUserSuccessState());
  }
  void removeUser({required user.Items instance}){
   selectedUsers.remove(instance);
   emit(SelectUserSuccessState());
  }

  void selectCategories({required cat.Data instance}){
   selectedCategories.add(instance);
   emit(SelectCategoriesSuccessState());
  }
  void removeCategories({required cat.Data instance}){
    selectedCategories.remove(instance);
   emit(SelectCategoriesSuccessState());
  }


}
