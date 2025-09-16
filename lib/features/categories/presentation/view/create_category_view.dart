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
import 'package:alrayan_admin/features/categories/data/models/categories_model.dart';
import 'package:alrayan_admin/features/categories/data/repo/categories_repo_impl.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/create_category/create_category_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/create_category/create_category_states.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/delete_category/delete_category_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/delete_category/delete_category_states.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/edit_category/edit_category_cubit.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/edit_category/edit_category_states.dart';
import 'package:alrayan_admin/features/categories/presentation/view_model/get_categories/get_categories_cubit.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/widgets/text_field_header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key, this.categoryData});

  final Data? categoryData;

  @override
  State<CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<CreateCategoryView> {
  TextEditingController nameAr = TextEditingController();
  TextEditingController nameEn = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.categoryData != null) {
      nameAr.text = widget.categoryData!.name!.ar ?? "";
      nameEn.text = widget.categoryData!.name!.en ?? "";
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
        BlocProvider(create: (context) => CreateCategoryCubit(getIt<CategoriesRepoImpl>())),
        BlocProvider(create: (context) => EditCategoryCubit(getIt<CategoriesRepoImpl>())),
        BlocProvider(create: (context) => DeleteCategoryCubit(getIt<CategoriesRepoImpl>())),
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
                      Text(
                        widget.categoryData == null ? "تصنيف جديد" : "تعديل التصنيف",
                        style: Styles.inter18500Black(context),
                      ),
                      SizedBox(width: AppConstants.width20(context) * 2),
                    ],
                  ),
                  SizedBox(height: AppConstants.height20(context)),
                  Expanded(
                    child: BlocConsumer<CreateCategoryCubit, CreateCategoryStates>(
                      listener: (context, state) {
                        if (state is CreateCategorySuccessState) {
                          cherryToast(text: state.message, context: context);
                          context.read<GetCategoriesCubit>().getCategories();
                          NavigationUtils.navigateBack(context: context);
                        } else if (state is CreateCategoryErrorState) {
                          cherryToast(text: state.error, context: context, isSuccess: false);
                        }
                      },
                      builder: (context, state) {
                        return ListView(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.read<CreateCategoryCubit>().selectCategoryIcon();
                              },
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  context.read<CreateCategoryCubit>().categoryIcon != null
                                      ? ClipOval(
                                          child: Image.file(
                                            context.read<CreateCategoryCubit>().categoryIcon!,
                                            width: MediaQuery.of(context).size.width * 0.2,
                                            height: MediaQuery.of(context).size.width * 0.2,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : widget.categoryData != null
                                      ? ClipOval(
                                          child: DefaultCachedNetworkImage(
                                            imageUrl: widget.categoryData!.icon ?? "",
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
                            TextFieldHeader(text: "اسم التصنيف"),
                            SizedBox(height: AppConstants.height5(context)),
                            DefaultTextFormField(
                              textInputType: TextInputType.text,
                              controller: nameAr,
                              hintText: "ادخل اسم التصنيف",
                              validationMsg: "يجب ادخال اسم التصنيف",
                            ),
                            SizedBox(height: AppConstants.height20(context)),
                            TextFieldHeader(text: "اسم التصنيف (EN)"),
                            SizedBox(height: AppConstants.height5(context)),
                            DefaultTextFormField(
                              textInputType: TextInputType.text,
                              controller: nameEn,
                              hintText: "ادخل اسم التصنيف (EN)",
                              validationMsg: "يجب ادخال اسم التصنيف (EN)",
                            ),
                            SizedBox(height: AppConstants.height20(context) * 2),
                            if (widget.categoryData == null)
                              state is CreateCategoryLoadingState
                                  ? const Center(child: CircularProgressIndicator())
                                  : DefaultButton(
                                      onPress: () async {
                                        if (formKey.currentState!.validate()) {
                                          if (context.read<CreateCategoryCubit>().categoryIcon != null) {
                                            context.read<CreateCategoryCubit>().createCategory(
                                              data: {
                                                "icon": await MultipartFile.fromFile(
                                                  context.read<CreateCategoryCubit>().categoryIcon!.path,
                                                ),
                                                "name": {"en": nameEn.text, "ar": nameAr.text},
                                              },
                                            );
                                          } else {
                                            cherryToast(
                                              text: "اختر ايقونة التصنيف اولا",
                                              context: context,
                                              isSuccess: false,
                                            );
                                          }
                                        }
                                      },
                                      text: "حفظ",
                                      borderRadius: AppConstants.sp10(context),
                                    ),
                            if (widget.categoryData != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: BlocConsumer<EditCategoryCubit, EditCategoryStates>(
                                      listener: (context, editState) {
                                        if (editState is EditCategorySuccessState) {
                                          cherryToast(text: editState.message, context: context);
                                          context.read<GetCategoriesCubit>().getCategories();
                                          NavigationUtils.navigateBack(context: context);
                                        } else if (editState is EditCategoryErrorState) {
                                          cherryToast(text: editState.error, context: context, isSuccess: false);
                                        }
                                      },
                                      builder: (context, editState) {
                                        return editState is EditCategoryLoadingState
                                            ? CustomLoadingItem()
                                            : DefaultButton(
                                                onPress: () async {
                                                  if (formKey.currentState!.validate()) {
                                                    context.read<EditCategoryCubit>().editCategory(
                                                      data: {
                                                        if (context.read<CreateCategoryCubit>().categoryIcon != null)
                                                          "icon": await MultipartFile.fromFile(
                                                            context.read<CreateCategoryCubit>().categoryIcon!.path,
                                                          ),
                                                        "name": {"en": nameEn.text, "ar": nameAr.text},
                                                      },
                                                      categoryId: widget.categoryData!.id!,
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
                                      context.read<DeleteCategoryCubit>().deleteCategory(
                                        categoryId: widget.categoryData!.id!,
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(AppConstants.width20(context)),
                                      decoration: BoxDecoration(
                                        color: AppColors.redColor,
                                        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                      ),
                                      child: BlocConsumer<DeleteCategoryCubit, DeleteCategoryStates>(
                                        listener: (context, deleteState) {
                                          if (deleteState is DeleteCategorySuccessState) {
                                            cherryToast(text: deleteState.message, context: context);

                                            context.read<GetCategoriesCubit>().getCategories();
                                            NavigationUtils.navigateBack(context: context);
                                          } else if (deleteState is DeleteCategoryErrorState) {
                                            cherryToast(text: deleteState.error, context: context, isSuccess: false);
                                          }
                                        },
                                        builder: (context, deleteState) {
                                          return deleteState is DeleteCategoryLoadingState
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
