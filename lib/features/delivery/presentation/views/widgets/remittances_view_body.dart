import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_remittances/get_remittances_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_remittances/get_remittances_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/remittance_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RemittancesViewBody extends StatefulWidget {
  const RemittancesViewBody({super.key});

  @override
  State<RemittancesViewBody> createState() => _RemittancesViewBodyState();
}

class _RemittancesViewBodyState extends State<RemittancesViewBody> {
  final ScrollController scrollController = ScrollController();

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<GetRemittancesCubit>().loadMore();
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetRemittancesCubit, GetRemittancesStates>(
      builder: (context, state) {
        if (state is GetRemittancesErrorState) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.width20(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: DsColor.danger,
                    size: 48,
                  ),
                  SizedBox(height: AppConstants.height10(context)),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Styles.inter14500black(context),
                  ),
                  SizedBox(height: AppConstants.height15(context)),
                  ElevatedButton(
                    onPressed: () => context
                        .read<GetRemittancesCubit>()
                        .getRemittances(withLoading: true),
                    child: Text("retry".tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is GetRemittancesSuccessState) {
          final cubit = context.read<GetRemittancesCubit>();
          final list = cubit.remittancesList;
          if (list.isEmpty) {
            return Center(child: SvgPicture.asset(AssetData.emptyCategory));
          }
          return RefreshIndicator(
            onRefresh: () => cubit.getRemittances(withLoading: true),
            child: ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  SizedBox(height: AppConstants.height15(context)),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    if (index == 0)
                      SizedBox(height: AppConstants.height5(context)),
                    RemittanceItem(remittance: list[index]),
                    if (context.read<GetRemittancesCubit>().isLoadingMore &&
                        index == list.length - 1)
                      Padding(
                        padding: EdgeInsets.all(AppConstants.sp10(context)),
                        child: CustomLoadingItem(
                          size: MediaQuery.of(context).size.width * 0.08,
                        ),
                      ),
                    if (index == list.length - 1)
                      SizedBox(height: AppConstants.height30(context)),
                  ],
                );
              },
            ),
          );
        }

        return const CustomLoadingItem();
      },
    );
  }
}
