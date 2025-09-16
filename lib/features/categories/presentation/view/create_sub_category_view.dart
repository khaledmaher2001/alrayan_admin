import 'package:alrayan_admin/core/shared_widgets/cherry_toast.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_button.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/shared_widgets/default_text_form_field.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/categories/data/models/sub_categories_model.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo_impl.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/create_sub_category/create_sub_category_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/create_sub_category/create_sub_category_states.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/delete_sub_category/delete_sub_category_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/delete_sub_category/delete_sub_category_states.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/edit_sub_category/edit_sub_category_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/edit_sub_category/edit_sub_category_states.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_sub_categories/get_sub_categories_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/text_field_header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateSubCategoryView extends StatefulWidget {
  const CreateSubCategoryView({super.key, this.subCategoryData, required this.mainCategoryId});

  final Data? subCategoryData;
  final int mainCategoryId;

  @override
  State<CreateSubCategoryView> createState() => _CreateSubCategoryViewState();
}

class _CreateSubCategoryViewState extends State<CreateSubCategoryView> {
  TextEditingController nameAr = TextEditingController();
  TextEditingController nameEn = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.subCategoryData != null) {
      nameAr.text = widget.subCategoryData!.name!.ar ?? "";
      nameEn.text = widget.subCategoryData!.name!.en ?? "";
    }
    super.initState();
  }

  @override
  void dispose() {
    nameEn.dispose();
    nameAr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CreateSubCategoryCubit(getIt<CategoriesRepoImpl>())),
        BlocProvider(create: (context) => EditSubCategoryCubit(getIt<CategoriesRepoImpl>())),
        BlocProvider(create: (context) => DeleteSubCategoryCubit(getIt<CategoriesRepoImpl>())),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: AppConstants.height10(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomBackButton(),
                      Text(widget.subCategoryData==null?"قسم فرعى جديد":"تعديل", style: Styles.inter18500Black(context)),
                      SizedBox(width: AppConstants.width20(context) * 2),
                    ],
                  ),
                  SizedBox(height: AppConstants.height20(context)),
                  Expanded(
                    child: BlocConsumer<CreateSubCategoryCubit, CreateSubCategoryStates>(
                      listener: (context, state) {
                        if (state is CreateSubCategorySuccessState) {
                          cherryToast(text: state.message, context: context);
                          context.read<GetSubCategoriesCubit>().getSubCategories(mainCategoryId: widget.mainCategoryId);
                          NavigationUtils.navigateBack(context: context);
                        } else if (state is CreateSubCategoryErrorState) {
                          cherryToast(text: state.error, context: context, isSuccess: false);
                        }
                      },
                      builder: (context, state) {
                        return ListView(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.read<CreateSubCategoryCubit>().selectSubCategoryIcon();
                              },
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  context.read<CreateSubCategoryCubit>().subCategoryIcon != null
                                      ? ClipOval(
                                          child: Image.file(
                                            context.read<CreateSubCategoryCubit>().subCategoryIcon!,
                                            width: MediaQuery.of(context).size.width * 0.2,
                                            height: MediaQuery.of(context).size.width * 0.2,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : widget.subCategoryData != null
                                      ? ClipOval(
                                          child: DefaultCachedNetworkImage(
                                            imageUrl: widget.subCategoryData!.icon ?? "",
                                            imageWidth: MediaQuery.of(context).size.width * 0.2,
                                            imageHeight: MediaQuery.of(context).size.width * 0.2,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : SizedBox(),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.width * 0.2,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                                  ),
                                  Icon(CupertinoIcons.camera, color: Colors.white),
                                ],
                              ),
                            ),
                            TextFieldHeader(text: "اسم القسم الفرعى"),
                            SizedBox(height: AppConstants.height5(context)),
                            DefaultTextFormField(
                              textInputType: TextInputType.text,
                              controller: nameAr,
                              hintText: "ادخل القسم الفرعى",
                              validationMsg: "يجب ادخال القسم الفرعى",
                            ),
                            SizedBox(height: AppConstants.height20(context)),
                            TextFieldHeader(text: "القسم الفرعى (EN)"),
                            SizedBox(height: AppConstants.height5(context)),
                            DefaultTextFormField(
                              textInputType: TextInputType.text,
                              controller: nameEn,
                              hintText: "ادخل القسم الفرعى (EN)",
                              validationMsg: "يجب ادخال القسم الفرعى (EN)",
                            ),
                            SizedBox(height: AppConstants.height20(context) * 2),
                            if (widget.subCategoryData == null)
                              state is CreateSubCategoryLoadingState
                                  ? const Center(child: CircularProgressIndicator())
                                  : DefaultButton(
                                      onPress: () async {
                                        if (formKey.currentState!.validate()) {
                                          if (context.read<CreateSubCategoryCubit>().subCategoryIcon != null) {
                                            context.read<CreateSubCategoryCubit>().createSubCategory(
                                              data: {
                                                "icon": await MultipartFile.fromFile(
                                                  context.read<CreateSubCategoryCubit>().subCategoryIcon!.path,
                                                ),
                                                "name": {"en": nameEn.text, "ar": nameAr.text},
                                                "main_category_id":widget.mainCategoryId
                                              },
                                            );
                                          } else {
                                            cherryToast(
                                              text: "اختر ايقونة القسم الفرعى اولا",
                                              context: context,
                                              isSuccess: false,
                                            );
                                          }
                                        }
                                      },
                                      text: "حفظ",
                                      borderRadius: AppConstants.sp10(context),
                                    ),
                            if (widget.subCategoryData != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: BlocConsumer<EditSubCategoryCubit, EditSubCategoryStates>(
                                      listener: (context, editState) {
                                        if (editState is EditSubCategorySuccessState) {
                                          cherryToast(text: editState.message, context: context);
                                          context.read<GetSubCategoriesCubit>().getSubCategories(mainCategoryId: widget.mainCategoryId);
                                          NavigationUtils.navigateBack(context: context);
                                        } else if (editState is EditSubCategoryErrorState) {
                                          cherryToast(text: editState.error, context: context, isSuccess: false);
                                        }
                                      },
                                      builder: (context, editState) {
                                        return editState is EditSubCategoryLoadingState
                                            ? CustomLoadingItem()
                                            : DefaultButton(
                                                onPress: () async {
                                                  if (formKey.currentState!.validate()) {
                                                    context.read<EditSubCategoryCubit>().editSubCategory(
                                                      data: {
                                                        if (context.read<CreateSubCategoryCubit>().subCategoryIcon !=
                                                            null)
                                                          "icon": await MultipartFile.fromFile(
                                                            context
                                                                .read<CreateSubCategoryCubit>()
                                                                .subCategoryIcon!
                                                                .path,
                                                          ),
                                                        "name": {"en": nameEn.text, "ar": nameAr.text},
                                                        "main_category_id":widget.mainCategoryId

                                                      },
                                                      subCategoryId: widget.subCategoryData!.id!,
                                                    );
                                                  }
                                                },
                                                text: "تعديل",
                                                backgroundColor: Colors.green,
                                                borderRadius: AppConstants.sp10(context),
                                              );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: AppConstants.width15(context)),
                                  GestureDetector(
                                    onTap: () {
                                      context.read<DeleteSubCategoryCubit>().deleteSubCategory(
                                        subCategoryId: widget.subCategoryData!.id!,
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(AppConstants.width20(context)),
                                      decoration: BoxDecoration(
                                        color: AppColors.redColor,
                                        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                      ),
                                      child: BlocConsumer<DeleteSubCategoryCubit, DeleteSubCategoryStates>(
                                        listener: (context, deleteState) {
                                          if (deleteState is DeleteSubCategorySuccessState) {
                                            cherryToast(text: deleteState.message, context: context);
                                            context.read<GetSubCategoriesCubit>().getSubCategories(mainCategoryId: widget.mainCategoryId);
                                            NavigationUtils.navigateBack(context: context);
                                          } else if (deleteState is DeleteSubCategoryErrorState) {
                                            cherryToast(text: deleteState.error, context: context, isSuccess: false);
                                          }
                                        },
                                        builder: (context, deleteState) {
                                          return deleteState is DeleteSubCategoryLoadingState
                                              ? CustomLoadingItem(
                                                  color: Colors.white,
                                                  size: MediaQuery.of(context).size.height * .026,
                                                )
                                              : SvgPicture.asset(
                                                  AssetData.delete,
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context).size.height * .026,
                                                  height: MediaQuery.of(context).size.height * .026,
                                                );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
