import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:alrayan_admin/core/shared_widgets/toast.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';
import 'package:alrayan_admin/core/utils/services/remote_services/service_locator.dart';
import 'package:alrayan_admin/features/product_details/presentation/views/products_details_view.dart';
import 'package:alrayan_admin/features/products/data/repo/products_repo_impl.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/get_products/get_products_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/toggle_product_hidden/toggle_product_hidden_cubit.dart';
import 'package:alrayan_admin/features/products/presentation/view_model/toggle_product_hidden/toggle_product_hidden_states.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/shared_widgets/default_cached_network_image.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/features/products/data/models/products_model.dart';

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
            toast(text: state.error, color: DsColor.danger);
          }
        },
        builder: (context, state) {
          final isLoading = state is ToggleProductHiddenLoadingState;
          final p = widget.productDetails;
          final name = context.locale.languageCode == "en" ? (p.name?.en ?? p.name?.ar ?? "") : (p.name?.ar ?? "");
          final hasDiscount = p.discount != null && p.discount != 0 && p.discount != 0.0;
          final stock = p.stock;
          final lowStock = stock != null && stock <= 0;
          // Compact row: image, name, price, stock, labelled visibility switch.
          return DsCard(
            padding: const EdgeInsets.all(DsSpace.md),
            onTap: () => NavigationUtils.navigateTo(context: context, destinationScreen: ProductsDetailsView(productData: p)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(DsRadius.md),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: DsColor.page,
                    child: DefaultCachedNetworkImage(
                      imageUrl: (p.images ?? []).isNotEmpty ? p.images!.first.attach ?? "" : "",
                      fit: BoxFit.cover,
                      imageWidth: 64,
                      imageHeight: 64,
                    ),
                  ),
                ),
                const SizedBox(width: DsSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: DsText.bodyStrong),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Text(DsFormat.money(num.tryParse('${p.priceAfterDiscount}')), style: DsText.bodyStrong.copyWith(color: AppColors.primaryColor)),
                          if (hasDiscount)
                            Text(
                              DsFormat.money(num.tryParse('${p.price}')),
                              style: DsText.caption.copyWith(decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                      if (stock != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          "prd_stock".tr(namedArgs: {"n": DsFormat.count(stock), "u": p.unit ?? ""}).trim(),
                          style: DsText.caption.copyWith(color: lowStock ? DsColor.danger : DsColor.textMuted, fontWeight: lowStock ? FontWeight.w700 : null),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: DsSpace.sm),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      child: isLoading
                          ? Center(
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)),
                            )
                          : Semantics(
                              label: "prd_visible_toggle".tr(),
                              child: Switch(
                                value: !_isHidden,
                                activeThumbColor: AppColors.primaryColor,
                                onChanged: (_) {
                                  setState(() => _isHidden = !_isHidden);
                                  context.read<ToggleProductHiddenCubit>().toggleHidden(productId: p.id!);
                                },
                              ),
                            ),
                    ),
                    Text(
                      _isHidden ? "s_hidden".tr() : "s_visible".tr(),
                      style: DsText.caption.copyWith(fontSize: 11, color: _isHidden ? DsColor.textMuted : AppColors.primaryColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
