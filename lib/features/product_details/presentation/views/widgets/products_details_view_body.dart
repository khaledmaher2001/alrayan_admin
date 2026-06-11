import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_dropdown_formfield.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_states.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/add_edit_product_item.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/category_row_item.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/product_photos_list.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/text_field_header.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsDetailsViewBody extends StatefulWidget {
  const ProductsDetailsViewBody({super.key, this.productData});

  final Items? productData;

  @override
  State<ProductsDetailsViewBody> createState() =>
      _ProductsDetailsViewBodyState();
}

class _ProductsDetailsViewBodyState extends State<ProductsDetailsViewBody> {
  final TextEditingController name = TextEditingController();
  final TextEditingController nameEn = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController descriptionEn = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController supplierPrice = TextEditingController();
  final TextEditingController stock = TextEditingController();
  final TextEditingController unit = TextEditingController();
  final TextEditingController discount = TextEditingController(text: "0");

  String? discountTypeUi;
  bool isRecommended = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool get _hasDiscountType =>
      discountTypeUi != null && discountTypeUi!.trim().isNotEmpty;

  String _getDiscountTypeForApi() {
    if (!_hasDiscountType) return "";

    switch (discountTypeUi) {
      case "نسبة ثابتة":
        return "fixed";
      case "نسبة مئوية":
        return "percentage";
      default:
        return "";
    }
  }

  void _syncDiscountWithType() {
    if (!_hasDiscountType) {
      discount.text = "0";
      return;
    }

    if (discount.text.trim().isEmpty) {
      discount.text = "0";
    }
  }

  String? _getMainCategoryNameForCurrentLang(Items product) {
    final lang = CacheKeysManger.getUserLanguageFromCache();

    if (lang == "en") {
      return product.mainCategory?.name ?? "";
    }

    return product.mainCategory?.name ?? "";
  }

  String? _getSubCategoryNameForCurrentLang(Items product) {
    final lang = CacheKeysManger.getUserLanguageFromCache();

    if (lang == "en") {
      return product.subCategory?.name ?? "";
    }

    return product.subCategory?.name ?? "";
  }

  @override
  void initState() {
    super.initState();

    final selectCubit = context.read<SelectProductPhotosCubit>();
    selectCubit.productPhotos.clear();

    if (widget.productData != null) {
      final product = widget.productData!;

      name.text = product.name?.ar ?? "";
      nameEn.text = product.name?.en ?? "";
      description.text = product.description?.ar ?? "";
      descriptionEn.text = product.description?.en ?? "";
      price.text = product.price?.toStringAsFixed(2) ?? "0.00";
      supplierPrice.text = product.supplierPrice?.toStringAsFixed(2) ?? "0.00";
      stock.text = product.stock?.toString() ?? "0";
      unit.text = product.unit ?? "";
      discount.text = product.discount?.toString() ?? "0";

      selectCubit.setInitialCategory(
        mainId: product.mainCategoryId,
        mainName: _getMainCategoryNameForCurrentLang(product),
        subId: product.subCategoryId,
        subName: _getSubCategoryNameForCurrentLang(product),
      );

      discountTypeUi = product.discountType == "fixed"
          ? "نسبة ثابتة"
          : product.discountType == "percentage"
          ? "نسبة مئوية"
          : null;

      isRecommended = product.isRecommended ?? false;
    } else {
      discount.text = "0";

      selectCubit.setInitialCategory(
        mainId: null,
        mainName: null,
        subId: null,
        subName: null,
      );
    }

    _syncDiscountWithType();
  }

  @override
  void dispose() {
    name.dispose();
    nameEn.dispose();
    description.dispose();
    descriptionEn.dispose();
    price.dispose();
    supplierPrice.dispose();
    stock.dispose();
    unit.dispose();
    discount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedDiscountType = _getDiscountTypeForApi();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
        child: Column(
          children: [
            SizedBox(height: AppConstants.height5(context)),
            Row(
              children: [
                CustomBackButton(),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      "تفاصيل المنتج",
                      style: Styles.inter16500black(context),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.width30(context)),
              ],
            ),
            SizedBox(height: AppConstants.height15(context)),
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFieldHeader(text: "اسم المنتج"),
                    SizedBox(height: AppConstants.height5(context)),
                    DefaultTextFormField(
                      textInputType: TextInputType.text,
                      controller: name,
                      hintText: "ادخل اسم المنتج",
                      validationMsg: "يجب ادخال اسم المنتج",
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    TextFieldHeader(text: "اسم المنتج (En)"),
                    SizedBox(height: AppConstants.height5(context)),
                    DefaultTextFormField(
                      textInputType: TextInputType.text,
                      controller: nameEn,
                      hintText: "ادخل اسم المنتج (En)",
                      validationMsg: "يجب ادخال اسم المنتج (En)",
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    TextFieldHeader(text: "وصف المنتج"),
                    SizedBox(height: AppConstants.height5(context)),
                    DefaultTextFormField(
                      textInputType: TextInputType.text,
                      controller: description,
                      maxLines: 3,
                      hintText: "ادخل وصف المنتج",
                      validationMsg: "يجب ادخال وصغ المنتج",
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    TextFieldHeader(text: "وصف المنتج (EN)"),
                    SizedBox(height: AppConstants.height5(context)),
                    DefaultTextFormField(
                      textInputType: TextInputType.text,
                      controller: descriptionEn,
                      maxLines: 3,
                      hintText: "ادخل وصف المنتج (EN)",
                      validationMsg: "يجب ادخال وصغ المنتج (EN)",
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldHeader(text: "سعر البيع للجمهور"),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                textInputType: TextInputType.number,
                                controller: price,
                                hintText: "ادخل سعر الجمهور",
                                validationMsg: "يجب ادخال سعر للجمهور",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppConstants.width10(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldHeader(text: "سعر الشراء"),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                textInputType: TextInputType.number,
                                controller: supplierPrice,
                                hintText: "ادخل سعر الشراء",
                                validationMsg: "يجب ادخال سعر الشراء",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldHeader(
                                text: "نوع الخصم",
                                isRequired: false,
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              CustomDropDownButton(
                                hintText: "اختر نوع الخصم",
                                value: discountTypeUi,
                                onChanged: (value) {
                                  setState(() {
                                    discountTypeUi = value;
                                    _syncDiscountWithType();
                                  });
                                },
                                items: const ["نسبة مئوية", "نسبة ثابتة"],
                                validator: (value) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppConstants.width10(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldHeader(
                                text: "قيمة الخصم",
                                isRequired: false,
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                textInputType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                controller: discount,
                                hintText: "00",
                                readOnly: !_hasDiscountType,
                                suffixIcon: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      discountTypeUi == "نسبة مئوية"
                                          ? "%"
                                          : "ج.م",
                                      style: Styles.inter14500black(context)
                                          .copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                validation: (value) {
                                  if (!_hasDiscountType) return null;

                                  final parsed = double.tryParse(
                                    (value ?? "").trim(),
                                  );

                                  if (parsed == null) {
                                    return "ادخل قيمة خصم صحيحة";
                                  }

                                  if (parsed < 0) {
                                    return "قيمة الخصم لا يمكن أن تكون سالبة";
                                  }

                                  if (discountTypeUi == "نسبة مئوية" &&
                                      parsed > 100) {
                                    return "النسبة المئوية يجب ألا تزيد عن 100";
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    const CategoryRowItem(),
                    SizedBox(height: AppConstants.height15(context)),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldHeader(text: "عدد المنتج"),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                textInputType: TextInputType.number,
                                controller: stock,
                                hintText: "ادخل عدد المنتج",
                                validationMsg: "يجب ادخال عدد المنتج",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppConstants.width15(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldHeader(
                                text: "وحدة المنتج",
                                isRequired: false,
                              ),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                textInputType: TextInputType.text,
                                controller: unit,
                                hintText: "ادخل الوحدة",
                                validation: (value) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height20(context)),

                    BlocBuilder<SelectProductPhotosCubit,
                        SelectProductPhotosStates>(
                      builder: (context, state) {
                        final selectPhotosCubit =
                        context.read<SelectProductPhotosCubit>();

                        return Row(
                          children: [
                            TextFieldHeader(text: "صور المنتج"),
                            SizedBox(width: AppConstants.width5(context)),
                            GestureDetector(
                              onTap: () {
                                selectPhotosCubit.selectProductPhotos();
                              },
                              child: Container(
                                padding:
                                EdgeInsets.all(AppConstants.sp5(context)),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor,
                                ),
                                child:
                                const Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                            SizedBox(width: AppConstants.width5(context)),
                            Text(
                              "(اقصى عدد 5 صور)",
                              style: Styles.inter12500Black(context).copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    ProductPhotosList(
                      images: widget.productData?.images ?? [],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    Row(
                      children: [
                        Checkbox(
                          value: isRecommended,
                          onChanged: (value) {
                            setState(() {
                              isRecommended = value ?? false;
                            });
                          },
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          activeColor: AppColors.primaryColor,
                        ),
                        Text(
                          "من المنتجات الموصى بها",
                          style: Styles.inter16500black(context),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),

                    BlocBuilder<SelectProductPhotosCubit,
                        SelectProductPhotosStates>(
                      builder: (context, state) {
                        final selectCubit =
                        context.read<SelectProductPhotosCubit>();

                        return AddEditProductItem(
                          productData: widget.productData,
                          formKey: formKey,
                          name: name,
                          nameEn: nameEn,
                          description: description,
                          descriptionEn: descriptionEn,
                          categoryId: selectCubit.mainCategoryId ?? 0,
                          subCategoryId: selectCubit.subCategoryId,
                          discount: discount,
                          discountType: normalizedDiscountType,
                          isRecommended: isRecommended,
                          price: price,
                          stock: stock,
                          supplierPrice: supplierPrice,
                          unit: unit,
                        );
                      },
                    ),

                    SizedBox(height: AppConstants.height15(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}