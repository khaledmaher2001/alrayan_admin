part of 'create_coupon_assets_cubit.dart';

@immutable
abstract class CreateCouponAssetsState {}

class CreateCouponAssetsInitial extends CreateCouponAssetsState {}



class SelectCouponTypeSuccessState extends CreateCouponAssetsState {}
class SelectUsersTypeSuccessState extends CreateCouponAssetsState {}
class SelectProductSuccessState extends CreateCouponAssetsState {}
class SelectUserSuccessState extends CreateCouponAssetsState {}
class SelectCategoriesSuccessState extends CreateCouponAssetsState {}


