import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_dropdown_formfield.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/product_details/presentation/view_model/select_product_photos/select_product_photos_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/add_edit_product_item.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/category_row_item.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/product_photos_list.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/text_field_header.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/constants.dart';

class ProductsDetailsViewBody extends StatefulWidget {
  const ProductsDetailsViewBody({super.key, this.productData});

  final Items? productData;

  @override
  State<ProductsDetailsViewBody> createState() => _ProductsDetailsViewBodyState();
}

class _ProductsDetailsViewBodyState extends State<ProductsDetailsViewBody> {
  TextEditingController name = TextEditingController();
  TextEditingController nameEn = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController descriptionEn = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController supplierPrice = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController unit = TextEditingController();
  TextEditingController discount = TextEditingController();
  String? discountType;
  bool isRecommended = false;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.productData != null) {
      final cubit = context.read<SelectProductPhotosCubit>();
      print(widget.productData!.discountType);
      name.text = widget.productData!.name!.ar ?? "";
      nameEn.text = widget.productData!.name!.en ?? "";
      description.text = widget.productData!.description!.ar ?? "";
      descriptionEn.text = widget.productData!.description!.en ?? "";
      price.text = widget.productData!.price.toStringAsFixed(2);
      supplierPrice.text = widget.productData!.supplierPrice.toStringAsFixed(2);
      stock.text = widget.productData!.stock.toString();
      unit.text = widget.productData!.unit ?? "";
      discount.text = widget.productData!.discount.toString();
      cubit.mainCategory = widget.productData!.mainCategory!.name ?? "";
      cubit.subCategory = widget.productData!.subCategory!.name ?? "";
      cubit.mainCategoryId = widget.productData!.mainCategoryId;
      cubit.subCategoryId = widget.productData!.subCategoryId;
      discountType = widget.productData!.discountType == "fixed"
          ? "نسبة ثابتة"
          : widget.productData!.discountType == "percentage"
          ? "نسبة مئوية"
          : null;
      isRecommended = widget.productData!.isRecommended ?? false;
    }
    context.read<SelectProductPhotosCubit>().productPhotos.clear();

    super.initState();
  }

  @override
  void dispose() {
    name.dispose();
    nameEn.dispose();
    description.dispose();
    descriptionEn.dispose();
    price.dispose();
    supplierPrice.dispose();
    unit.dispose();
    stock.dispose();
    discount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text("تفاصيل المنتج", style: Styles.inter16500black(context)),
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
                              TextFieldHeader(text: "نوع الخصم", isRequired: false),
                              SizedBox(height: AppConstants.height5(context)),
                              CustomDropDownButton(
                                hintText: "اختر نوع الخصم",
                                onChanged: (value) {
                                  setState(() {
                                    discountType = value;
                                  });
                                },
                                items: ["نسبة مئوية", "نسبة ثابتة"],
                                validator: (value) {
                                  return null;
                                },
                                value: discountType,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppConstants.width10(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldHeader(text: "قيمة الخصم", isRequired: false),
                              SizedBox(height: AppConstants.height5(context)),
                              DefaultTextFormField(
                                textInputType: TextInputType.number,
                                controller: discount,
                                hintText: "00",
                                suffixIcon: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      discountType == "نسبة مئوية" ? "%" : "ج.م",
                                      style: Styles.inter14500black(context).copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                validation: (value) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),
                    CategoryRowItem(),
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
                              TextFieldHeader(text: "وحدة المنتج", isRequired: false),
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
                    Row(
                      children: [
                        TextFieldHeader(text: "صور المنتج"),
                        SizedBox(width: AppConstants.width5(context)),
                        GestureDetector(
                          onTap: () {
                            context.read<SelectProductPhotosCubit>().selectProductPhotos();
                          },
                          child: Container(
                            padding: EdgeInsets.all(AppConstants.sp5(context)),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor),
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: AppConstants.width5(context)),
                        Text("(اقصى عدد 5 صور)", style: Styles.inter12500Black(context).copyWith(color: Colors.grey)),
                      ],
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
                              isRecommended = !isRecommended;
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          activeColor: AppColors.primaryColor,
                        ),
                        Text("من المنتجات الموصى بها", style: Styles.inter16500black(context)),
                      ],
                    ),
                    SizedBox(height: AppConstants.height15(context)),
                    AddEditProductItem(
                      productData: widget.productData,
                      formKey: formKey,
                      name: name,
                      nameEn: nameEn,
                      description: description,
                      descriptionEn: descriptionEn,
                      categoryId: context.read<SelectProductPhotosCubit>().mainCategoryId ?? 0,
                      subCategoryId: context.read<SelectProductPhotosCubit>().subCategoryId ?? 0,
                      discount: discount,
                      discountType: discountType ?? "",
                      isRecommended: isRecommended,
                      price: price,
                      stock: stock,
                      supplierPrice: supplierPrice,
                      unit: unit,
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
