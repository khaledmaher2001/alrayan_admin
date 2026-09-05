import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_release_logs/get_release_logs_cubit.dart';
import 'package:alrayan_admin/features/delivery/presentation/view_models/get_release_logs/get_release_logs_states.dart';
import 'package:alrayan_admin/features/delivery/presentation/views/widgets/release_log_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReleaseLogsViewBody extends StatefulWidget {
  const ReleaseLogsViewBody({super.key});

  @override
  State<ReleaseLogsViewBody> createState() => _ReleaseLogsViewBodyState();
}

class _ReleaseLogsViewBodyState extends State<ReleaseLogsViewBody> {
  final ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;

  Future<void> _pagination() async {
    final cubit = context.read<GetReleaseLogsCubit>();
    final totalPages = cubit.logsModel?.data?.metadata?.totalPages;
    if (totalPages == null) return;

    if (cubit.page < totalPages &&
        scrollController.position.maxScrollExtent ==
            scrollController.position.pixels &&
        !isLoadingMore) {
      isLoadingMore = true;
      cubit.page++;
      await cubit
          .getReleaseLogs(withLoading: false)
          .then((_) => setState(() => isLoadingMore = false));
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_pagination);
  }

  @override
  void dispose() {
    scrollController.removeListener(_pagination);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<GetReleaseLogsCubit>().logsModel?.data?.metadata?.totalItems ??
        context.watch<GetReleaseLogsCubit>().logsList.length;

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
          child: _SummaryCard(count: count),
        ),
        SizedBox(height: AppConstants.height15(context)),
        Expanded(
          child: BlocBuilder<GetReleaseLogsCubit, GetReleaseLogsStates>(
            builder: (context, state) {
              if (state is GetReleaseLogsErrorState) {
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
                          color: Colors.red.shade300,
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
                              .read<GetReleaseLogsCubit>()
                              .getReleaseLogs(withLoading: true),
                          child: Text("retry".tr()),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is GetReleaseLogsSuccessState) {
                final cubit = context.read<GetReleaseLogsCubit>();
                final list = cubit.logsList;
                if (list.isEmpty) {
                  return Center(child: SvgPicture.asset(AssetData.emptyCategory));
                }
                return RefreshIndicator(
                  onRefresh: () => cubit.getReleaseLogs(withLoading: true),
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsetsDirectional.symmetric(horizontal: AppConstants.width15(context)),
                    itemCount: list.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: AppConstants.height15(context)),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ReleaseLogItem(log: list[index]),
                          if (isLoadingMore && index == list.length - 1)
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
          ),
        ),
      ],
    );
  }
}

/// "سجل التحرير — N عملية تحرير" summary card at the top of the screen.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.sp15(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp15(context)),
        border: Border.all(color: const Color(0xffE3E7EC)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppConstants.sp10(context)),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
            ),
            child: const Icon(Icons.history_rounded, color: Colors.white),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("سجل التحرير", style: Styles.inter16500black(context)),
                SizedBox(height: AppConstants.height5(context) / 2),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$count ",
                        style: Styles.inter14500black(context).copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: "عملية تحرير",
                        style: Styles.inter14500black(context).copyWith(color: const Color(0xff9CA4AB)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: AppConstants.height30(context), color: Colors.grey.shade200),
          SizedBox(width: AppConstants.width10(context)),
          Icon(Icons.edit_note_rounded, size: AppConstants.sp30(context), color: Colors.black87),
        ],
      ),
    );
  }
}
