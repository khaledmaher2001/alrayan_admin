import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/products_details_view.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo_impl.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/toggle_product_hidden/toggle_product_hidden_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/toggle_product_hidden/toggle_product_hidden_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class MainProductItem extends StatefulWidget {
  const MainProductItem({super.key, required this.productDetails});

  final Items productDetails;

  @override
  State<MainProductItem> createState() => _MainProductItemState();
}

class _MainProductItemState extends State<MainProductItem> {
  late bool _isHidden;

  @override
  void initState() {
    super.initState();
    _isHidden = widget.productDetails.isHidden ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ToggleProductHiddenCubit(getIt.get<ProductsRepoImpl>()),
      child: BlocConsumer<ToggleProductHiddenCubit, ToggleProductHiddenStates>(
        listener: (context, state) {
          if (state is ToggleProductHiddenSuccessState) {
            context.read<GetProductsCubit>().updateHiddenLocally(
                  widget.productDetails.id!,
                  _isHidden,
                );
          } else if (state is ToggleProductHiddenErrorState) {
            setState(() => _isHidden = !_isHidden);
            toast(text: state.error, color: Colors.red);
          }
        },
        builder: (context, state) {
          final isLoading = state is ToggleProductHiddenLoadingState;
          return GestureDetector(
            onTap: () {
              NavigationUtils.navigateTo(
                context: context,
                destinationScreen: ProductsDetailsView(
                  productData: widget.productDetails,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.sp20(context)),
                border: Border.all(color: Color(0xffE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width10(context),
                      vertical: AppConstants.height5(context),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _isHidden ? "مخفي" : "ظاهر",
                          style: Styles.inter14600black(context).copyWith(
                            color: _isHidden ? Colors.grey : AppColors.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : Transform.scale(
                                scale: 0.8,
                                child: Switch(
                                  value: !_isHidden,
                                  activeThumbColor: AppColors.primaryColor,
                                  onChanged: (_) {
                                    setState(() => _isHidden = !_isHidden);
                                    context.read<ToggleProductHiddenCubit>().toggleHidden(
                                          productId: widget.productDetails.id!,
                                        );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppConstants.sp10(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: AppConstants.height20(context)),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.01),
                                child: DefaultCachedNetworkImage(
                                  imageUrl: widget.productDetails.images!.isNotEmpty
                                      ? widget.productDetails.images!.first.attach ?? ""
                                      : "",
                                  fit: BoxFit.contain,
                                  imageWidth: MediaQuery.of(context).size.width,
                                  imageHeight: MediaQuery.of(context).size.height * 0.14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppConstants.height5(context)),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              CacheKeysManger.getUserLanguageFromCache() == "en"
                                  ? widget.productDetails.name!.en ?? ""
                                  : widget.productDetails.name!.ar ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Styles.inter16500black(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: AppConstants.width5(context)),
                      Text(
                        "${widget.productDetails.priceAfterDiscount.toStringAsFixed(2)} ج.م",
                        style: Styles.inter14600black(context).copyWith(color: AppColors.primaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: AppConstants.width5(context)),
                      Text(
                        widget.productDetails.discount != 0.0 &&
                                widget.productDetails.discount != 0 &&
                                widget.productDetails.discount != null
                            ? "${widget.productDetails.price} ج.م"
                            : "",
                        style: Styles.inter14600black(context).copyWith(
                          color: const Color(0xffC8C8C8),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(0xffC8C8C8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width10(context),
                      vertical: AppConstants.height5(context),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: AppConstants.width10(context)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
                      color: AppColors.primaryColor,
                    ),
                    alignment: AlignmentDirectional.center,
                    child: Text("عرض التفاصيل", style: Styles.inter14600black(context).copyWith(color: Colors.white)),
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
