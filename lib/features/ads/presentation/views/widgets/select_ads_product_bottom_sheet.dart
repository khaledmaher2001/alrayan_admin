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
import '../../view_models/ads_assets/ads_assets_cubit.dart';

class SelectAdsProductBottomSheet extends StatefulWidget {
  const SelectAdsProductBottomSheet({super.key});

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
        return SelectAdsProductBottomSheet();
      },
    );
  }

  @override
  State<SelectAdsProductBottomSheet> createState() =>
      _SelectAdsProductBottomSheetState();
}

class _SelectAdsProductBottomSheetState
    extends State<SelectAdsProductBottomSheet> {
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  pagination() async {
    final cubit = context.read<GetProductsCubit>();
    if (cubit.productsList.length < cubit.productsModel!
        .data!
        .metadata!
        .totalItems!  &&
        scrollController.position.maxScrollExtent == scrollController.position.pixels) {
      setState(() {
        isLoading = true;
        ++cubit.page;
      });
      await cubit.getProducts(withLoading: false);
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
                    "أختر المنتج",
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
              child: BlocBuilder<AdsAssetsCubit, AdsAssetsState>(
                builder: (context, assetState) {
                  return BlocBuilder<GetProductsCubit, GetProductsStates>(
                    builder: (context, state) {
                      if (state is GetProductsSuccessState) {
                        final products = context.read<GetProductsCubit>().productsList;
                        if (products.isEmpty) {
                          return EmptyWidget(
                            icon: AssetData.search,
                            title: "لا يوجد منتجات",
                            description: "سيتم اشعارك في حال توفر منتجات",
                          );
                        }
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                controller: scrollController,
                                itemCount: products.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: AppConstants.height10(context)),
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  final isSelected = context
                                      .read<AdsAssetsCubit>()
                                      .selectedProduct
                                      ?.id ==
                                      product.id;

                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppConstants.width20(context),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        final cubit = context.read<AdsAssetsCubit>();
                                        if (isSelected) {
                                          cubit.removeProduct(); // deselect
                                        } else {
                                          cubit.selectProduct(instance: product); // select new
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(AppConstants.sp10(context)),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x33000000),
                                              blurRadius: 6,
                                              spreadRadius: 0,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                          borderRadius:
                                          BorderRadius.circular(AppConstants.sp10(context)),
                                        ),
                                        child: Row(
                                          children: [
                                            DefaultCachedNetworkImage(
                                              imageUrl: product.images?.firstOrNull?.attach ?? '',
                                              imageHeight:
                                              MediaQuery.of(context).size.width * .2,
                                              imageWidth:
                                              MediaQuery.of(context).size.width * .2,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product.name?.ar ?? '',
                                                      style: Styles.inter16500black(context),
                                                    ),
                                                    Text(
                                                      product.description?.ar ?? '',
                                                      style: Styles.inter14600gray(context),
                                                    ),
                                                    Text(
                                                      "${product.price} جنية",
                                                      style: Styles.inter16500black(context)
                                                          .copyWith(color: AppColors.primaryColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            isSelected
                                                ? SvgPicture.asset(
                                              AssetData.checked,
                                              color: AppColors.primaryColor,
                                            )
                                                : SvgPicture.asset(
                                              AssetData.uncheck,
                                              color: AppColors.gray,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (isLoading)
                              Padding(
                                padding:
                                EdgeInsets.symmetric(vertical: AppConstants.height10(context)),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        );
                      } else {
                        return ListView.separated(
                          itemCount: 5,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppConstants.height10(context)),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.width20(context)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[200]!,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * .11,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius:
                                      BorderRadius.circular(AppConstants.sp5(context)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
