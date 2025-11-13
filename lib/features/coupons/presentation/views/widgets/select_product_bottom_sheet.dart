import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../core/shared_widgets/empty_widget.dart';
import '../../../../../../core/utils/assets/assets.dart';
import '../../../../../../core/utils/colors/colors.dart';
import '../../../../../../core/utils/constants.dart';
import '../../../../../../core/utils/text_styles/styles.dart';
import '../../../../../core/shared_widgets/default_text_form_field.dart';
import '../view_model/create_coupon_assets/create_coupon_assets_cubit.dart';

class SelectProductBottomSheet extends StatefulWidget {
  const SelectProductBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      useSafeArea: true,
      builder: (context) {
        return SelectProductBottomSheet();
      },
    );
  }

  @override
  State<SelectProductBottomSheet> createState() =>
      _SelectProductBottomSheetState();
}

class _SelectProductBottomSheetState extends State<SelectProductBottomSheet> {
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  bool show = false;

  pagination() async {
    if (context.read<GetProductsCubit>().productsList.length <
            context
                .read<GetProductsCubit>()
                .productsModel!
                .data!
                .metadata!
                .totalItems! &&
        scrollController.position.maxScrollExtent ==
            scrollController.position.pixels) {
      setState(() {
        isLoading = true;
        ++context.read<GetProductsCubit>().page;
      });
      await context.read<GetProductsCubit>().getProducts(withLoading: false);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    context.read<GetProductsCubit>().page = 1;
    scrollController.addListener(pagination);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: Column(
                children: [
                  SizedBox(height: AppConstants.height10(context)),
                  Container(
                    height: AppConstants.height5(context),
                    width: MediaQuery.sizeOf(context).width * .45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.width20(context),
                      ),
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  Text(
                    "أختر المنتجات",
                    style: Styles.inter16400white(
                      context,
                    ).copyWith(color: Colors.black),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  DefaultTextFormField(
                    textInputType: TextInputType.text,
                    controller: searchController,
                    hintText: "ابحث عن المنتج...",
                    onFilledSubmit: (value) {
                      print(value.trim());
                      context.read<GetProductsCubit>().getProducts(
                        name: value.trim(),
                      );
                    },
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<CreateCouponAssetsCubit, CreateCouponAssetsState>(
                builder: (context, assetState) {
                  return BlocBuilder<GetProductsCubit, GetProductsStates>(
                    builder: (context, state) {
                      if (state is GetProductsSuccessState) {
                        return Column(
                          children: [
                            Expanded(
                              child:
                                  context
                                      .read<GetProductsCubit>()
                                      .productsList
                                      .isNotEmpty
                                  ? ListView.separated(
                                      controller: scrollController,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            if (index == 0)
                                              SizedBox(
                                                height: AppConstants.height10(
                                                  context,
                                                ),
                                              ),

                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    AppConstants.width20(
                                                      context,
                                                    ),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  if (context
                                                      .read<
                                                        CreateCouponAssetsCubit
                                                      >()
                                                      .selectedProducts
                                                      .contains(
                                                        context
                                                            .read<
                                                              GetProductsCubit
                                                            >()
                                                            .productsList[index],
                                                      )) {
                                                    context
                                                        .read<
                                                          CreateCouponAssetsCubit
                                                        >()
                                                        .removeProduct(
                                                          instance: context
                                                              .read<
                                                                GetProductsCubit
                                                              >()
                                                              .productsList[index],
                                                        );
                                                  } else {
                                                    context
                                                        .read<
                                                          CreateCouponAssetsCubit
                                                        >()
                                                        .selectProducts(
                                                          instance: context
                                                              .read<
                                                                GetProductsCubit
                                                              >()
                                                              .productsList[index],
                                                        );
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                    AppConstants.sp10(context),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(
                                                          0x33000000,
                                                        ),
                                                        blurRadius: 6,
                                                        spreadRadius: 0,
                                                        offset: Offset(0, 0),
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppConstants.sp10(
                                                            context,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      DefaultCachedNetworkImage(
                                                        imageUrl:
                                                            context
                                                                .read<
                                                                  GetProductsCubit
                                                                >()
                                                                .productsList[index]
                                                                .images!
                                                                .firstOrNull!
                                                                .attach ??
                                                            '',
                                                        imageHeight:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            .2,
                                                        imageWidth:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            .2,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              context
                                                                      .read<
                                                                        GetProductsCubit
                                                                      >()
                                                                      .productsList[index]
                                                                      .name!.ar ??
                                                                  '',
                                                              style:
                                                                  Styles.inter16500black(
                                                                    context,
                                                                  ),
                                                            ),
                                                            Text(
                                                              context
                                                                      .read<
                                                                        GetProductsCubit
                                                                      >()
                                                                      .productsList[index]
                                                                      .description!.ar ??
                                                                  '',
                                                              style:
                                                                  Styles.inter14600gray(
                                                                    context,
                                                                  ),
                                                            ),
                                                            Text(
                                                              "${context.read<GetProductsCubit>().productsList[index].price.toString()} جنية",
                                                              style:
                                                                  Styles.inter16500black(
                                                                    context,
                                                                  ).copyWith(
                                                                    color: AppColors
                                                                        .primaryColor,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      context
                                                              .read<
                                                                CreateCouponAssetsCubit
                                                              >()
                                                              .selectedProducts
                                                              .contains(
                                                                context
                                                                    .read<
                                                                      GetProductsCubit
                                                                    >()
                                                                    .productsList[index],
                                                              )
                                                          ? SvgPicture.asset(
                                                              AssetData.checked,
                                                              color: AppColors
                                                                  .primaryColor,
                                                            )
                                                          : SvgPicture.asset(
                                                              AssetData.uncheck,
                                                              color: AppColors
                                                                  .gray,
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                            return SizedBox(
                                              height: AppConstants.height10(
                                                context,
                                              ),
                                            );
                                          },
                                      itemCount: context
                                          .read<GetProductsCubit>()
                                          .productsList
                                          .length,
                                    )
                                  : EmptyWidget(
                                      icon: AssetData.search,
                                      title: "لا يوجد حلقات",
                                      description:
                                          "سيتم اشعارك في حين اضافتك في حلقة او اكثر",
                                    ),
                            ),
                            if (isLoading)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppConstants.height10(context),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        );
                      } else {
                        return ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppConstants.width20(context),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.sp10(context),
                                ),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[200]!,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        .11,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.sp5(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: AppConstants.height10(context),
                            );
                          },
                          itemCount: 5,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
