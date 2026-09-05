import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/shimmer_helpers.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/home/data/models/home_statistics_model.dart';
import 'package:alrayan_admin/features/top_users/presentation/view_models/get_top_users_cubit/get_top_users_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/text_styles/styles.dart';

/// "العملاء الأكثر طلبًا" as a leaderboard: a 3-place podium up top (the
/// API doesn't send profile photos, so each place gets an initials avatar
/// instead), then a ranked list for #4 onward. Each customer's "score" is
/// their order count as a percentage of the #1 customer's — there's no
/// score field from the API, so this is the most honest stand-in: it's
/// always 100% for #1 and tapers off from there.
class TopUsersViewBody extends StatelessWidget {
  const TopUsersViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.height20(context)),
          CustomAppBar(
            title: "العملاء الاكثر طلبا",
            textColor: Colors.black,
            withNotifications: false,
            hasBack: true,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Text(
              "حاول انشاء كوبونات خصم تشجيعا للعملاء الاكثر طلبا",
              style: Styles.inter14600gray(context),
            ),
          ),
          SizedBox(height: AppConstants.height10(context)),
          Expanded(
            child: BlocBuilder<GetTopUsersCubit, GetTopUsersState>(
              builder: (context, state) {
                if (state is! GetTopUsersLoaded) return const _TopUsersShimmer();
                if (state.users.isEmpty) {
                  return Center(
                    child: Text("لا يوجد عملاء حتى الآن", style: Styles.inter14600gray(context)),
                  );
                }

                final sorted = [...state.users]..sort(
                    (a, b) => (b.orderCount ?? 0).compareTo(a.orderCount ?? 0),
                  );
                final topScore = sorted.first.orderCount ?? 0;
                final podium = sorted.take(3).toList();
                final rest = sorted.length > 3 ? sorted.sublist(3) : <TopCustomers>[];

                return ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width20(context),
                    vertical: AppConstants.height10(context),
                  ),
                  children: [
                    _Podium(customers: podium, topScore: topScore),
                    SizedBox(height: AppConstants.height30(context)),
                    for (var i = 0; i < rest.length; i++) ...[
                      _RankedListItem(
                        customer: rest[i],
                        rank: i + 4,
                        score: _scorePercent(rest[i].orderCount, topScore),
                      ),
                      SizedBox(height: AppConstants.height15(context)),
                    ],
                    SizedBox(height: AppConstants.height10(context)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopUsersShimmer extends StatelessWidget {
  const _TopUsersShimmer();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return appShimmer(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.width20(context),
          vertical: AppConstants.height10(context),
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _podiumPlaceholder(context, avatarSize: width * .14, blockHeight: width * .28),
              _podiumPlaceholder(context, avatarSize: width * .18, blockHeight: width * .34),
              _podiumPlaceholder(context, avatarSize: width * .14, blockHeight: width * .24),
            ],
          ),
          SizedBox(height: AppConstants.height30(context)),
          for (var i = 0; i < 4; i++) ...[
            Container(
              padding: EdgeInsets.all(AppConstants.sp10(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
              ),
              child: Row(
                children: [
                  shimmerCircle(size: AppConstants.width20(context) * 1.6),
                  SizedBox(width: AppConstants.width15(context)),
                  Expanded(child: shimmerBox(context, width: double.infinity, height: AppConstants.height15(context))),
                  SizedBox(width: AppConstants.width10(context)),
                  shimmerCircle(size: AppConstants.width20(context)),
                ],
              ),
            ),
            SizedBox(height: AppConstants.height15(context)),
          ],
        ],
      ),
    );
  }

  Widget _podiumPlaceholder(BuildContext context, {required double avatarSize, required double blockHeight}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.width5(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            shimmerCircle(size: avatarSize),
            SizedBox(height: AppConstants.height10(context)),
            shimmerBox(context, width: double.infinity, height: blockHeight, radius: 12),
          ],
        ),
      ),
    );
  }
}

int _scorePercent(int? value, int topScore) {
  if (topScore <= 0) return 0;
  return (((value ?? 0) / topScore) * 100).round().clamp(0, 100);
}

String _initials(String? name) {
  final parts = (name ?? '').trim().split(RegExp(r'\s+'));
  return parts
      .take(2)
      .map((e) => e.isNotEmpty ? e[0] : '')
      .join()
      .toUpperCase();
}

class _RankStyle {
  const _RankStyle({required this.badgeColor, required this.avatarColor});
  final Color badgeColor;
  final Color avatarColor;
}

const _rankStyles = {
  1: _RankStyle(badgeColor: AppColors.primarySwatchColor, avatarColor: AppColors.primarySwatchColor),
  2: _RankStyle(badgeColor: AppColors.secondaryColor, avatarColor: AppColors.secondaryColor),
  3: _RankStyle(badgeColor: AppColors.redColor, avatarColor: AppColors.redColor),
};

/// Brand-tinted avatar color for ranks #4+ — alternates between our two
/// core brand colors instead of the random rainbow Material palette.
Color _avatarColorFor(int rank) =>
    rank.isEven ? AppColors.secondaryColor : AppColors.primarySwatchColor;

/// Top 3 as a podium — #1 in the middle and taller, #2/#3 flanking it,
/// mirrored for RTL so #2 sits on the right and #3 on the left.
class _Podium extends StatelessWidget {
  const _Podium({required this.customers, required this.topScore});

  final List<TopCustomers> customers;
  final int topScore;

  TopCustomers? _at(int rank) => customers.length >= rank ? customers[rank - 1] : null;

  @override
  Widget build(BuildContext context) {
    final second = _at(2);
    final first = _at(1);
    final third = _at(3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (second != null) Expanded(child: _PodiumCard(rank: 2, customer: second, height: .28)),
        if (first != null)
          Expanded(
            child: _PodiumCard(rank: 1, customer: first, height: .34, emphasized: true),
          ),
        if (third != null) Expanded(child: _PodiumCard(rank: 3, customer: third, height: .24)),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.rank,
    required this.customer,
    required this.height,
    this.emphasized = false,
  });

  final int rank;
  final TopCustomers customer;
  final double height;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = _rankStyles[rank]!;
    final avatarSize = MediaQuery.of(context).size.width * (emphasized ? .18 : .14);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width5(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                padding: EdgeInsets.all(AppConstants.width5(context) / 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: style.avatarColor, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 3),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: style.avatarColor.withOpacity(.15),
                  child: Text(
                    _initials(customer.fullName),
                    style: Styles.inter16500black(context).copyWith(color: style.avatarColor),
                  ),
                ),
              ),
              PositionedDirectional(
                top: -AppConstants.height10(context),
                end: -AppConstants.width5(context),
                child: Container(
                  padding: EdgeInsets.all(AppConstants.sp5(context)),
                  decoration: BoxDecoration(
                    color: style.badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    "#$rank",
                    style: Styles.inter12500Black(context).copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.height10(context)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.width5(context),
              vertical: AppConstants.height10(context),
            ),
            decoration: BoxDecoration(
              color: emphasized ? style.badgeColor.withOpacity(.08) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: style.badgeColor.withOpacity(.4)),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 1, blurRadius: 3),
              ],
            ),
            height: MediaQuery.of(context).size.height * height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  customer.fullName ?? '-',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.inter12500Black(context).copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  "${customer.orderCount ?? 0} طلب",
                  style: Styles.inter10400grey(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row for ranks #4 and below: score circle + name + avatar/rank badge.
class _RankedListItem extends StatelessWidget {
  const _RankedListItem({required this.customer, required this.rank, required this.score});

  final TopCustomers customer;
  final int rank;
  final int score;

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColorFor(rank);

    return Container(
      padding: EdgeInsets.all(AppConstants.sp10(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.sp10(context)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 3),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: AppConstants.width20(context),
                backgroundColor: avatarColor.withOpacity(.1),
                child: Text(
                  _initials(customer.fullName),
                  style: Styles.inter14600black(context).copyWith(color: avatarColor),
                ),
              ),
              PositionedDirectional(
                bottom: -4,
                end: -4,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.width5(context),
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    "#$rank",
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: AppConstants.width15(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  customer.fullName ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.inter14600black(context),
                ),
                SizedBox(height: AppConstants.height5(context) / 2),
                Text(
                  "${customer.orderCount ?? 0} طلب",
                  style: Styles.inter10400grey(context),
                ),
              ],
            ),
          ),
          SizedBox(width: AppConstants.width10(context)),
          Container(
            width: AppConstants.width20(context) * 1.6,
            height: AppConstants.width20(context) * 1.6,
            decoration: BoxDecoration(
              color: AppColors.primarySwatchColor.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$score%",
                style: Styles.inter12500Black(context).copyWith(
                  color: AppColors.primarySwatchColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
