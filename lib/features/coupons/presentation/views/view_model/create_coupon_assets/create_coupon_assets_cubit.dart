import 'package:alrayan_admin/features/products/data/models/products_model.dart' as prod;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../all_users/data/models/all_users_model.dart' as user;
import '../../../../../categories/data/models/categories_model.dart' as cat;

part 'create_coupon_assets_state.dart';

class CreateCouponAssetsCubit extends Cubit<CreateCouponAssetsState> {
  CreateCouponAssetsCubit() : super(CreateCouponAssetsInitial());

  static CreateCouponAssetsCubit get(context) => BlocProvider.of(context);

  final createCouponFormKey = GlobalKey<FormState>();
  final nameArController = TextEditingController();
  final nameEnController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionArController = TextEditingController();
  final descriptionEnController = TextEditingController();
  final discountValueController = TextEditingController();
  final discountTypeController = TextEditingController();
  final minOrderAmountController = TextEditingController();
  final maxDiscountAmountController = TextEditingController();
  final usageLimitController = TextEditingController();
  final usageLimitPerUserController = TextEditingController();
  final splitValueController = TextEditingController();
  final numberOfSplitsController = TextEditingController();
  List<prod.Items> selectedProducts = [];
  List<cat.Data> selectedCategories = [];
  List<user.Items> selectedUsers = [];

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String? couponType;
  String? usersType;
  bool isHidden = false;

  void clearAllData() {
    selectedProducts.clear();
    selectedUsers.clear();
    selectedCategories.clear();
    startDateController.clear();
    nameArController.clear();
    nameEnController.clear();
    endDateController.clear();
    codeController.clear();
    descriptionArController.clear();
    descriptionEnController.clear();
    discountValueController.clear();
    discountTypeController.clear();
    minOrderAmountController.clear();
    maxDiscountAmountController.clear();
    usageLimitController.clear();
    usageLimitPerUserController.clear();
    splitValueController.clear();
    numberOfSplitsController.clear();
    selectedStartDate = null;
    selectedEndDate = null;
    couponType = null;
    usersType = null;
    isHidden = false;
  }

  void selectCouponType({required String type}) {
    couponType = type;
    emit(SelectCouponTypeSuccessState());
  }

  void selectUsersType({required String type}) {
    usersType = type;
    if (usersType != "all") {
      isHidden = false;
    }
    if (usersType != "specific_users") {
      selectedUsers.clear();
    }
    emit(SelectUsersTypeSuccessState());
  }

  void toggleIsHidden(bool value) {
    isHidden = usersType == "all" ? value : false;
    emit(ToggleIsHiddenSuccessState());
  }

  void selectProducts({required prod.Items instance}) {
    selectedProducts.add(instance);
    emit(SelectProductSuccessState());
  }

  void removeProduct({required prod.Items instance}) {
    selectedProducts.remove(instance);
    emit(SelectProductSuccessState());
  }

  void selectUser({required user.Items instance}) {
    selectedUsers.add(instance);
    emit(SelectUserSuccessState());
  }

  void removeUser({required user.Items instance}) {
    selectedUsers.remove(instance);
    emit(SelectUserSuccessState());
  }

  void setSelectedUsers(List<user.Items> users) {
    selectedUsers = users;
    emit(SelectUserSuccessState());
  }

  void selectCategories({required cat.Data instance}) {
    selectedCategories.add(instance);
    emit(SelectCategoriesSuccessState());
  }

  void removeCategories({required cat.Data instance}) {
    selectedCategories.remove(instance);
    emit(SelectCategoriesSuccessState());
  }
}
