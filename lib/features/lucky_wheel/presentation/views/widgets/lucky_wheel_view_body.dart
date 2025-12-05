import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/views/widgets/lucky_wheel_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:alrayan_admin/core/utils/colors/colors.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:alrayan_admin/features/lucky_wheel/presentation/view_models/get_lucky_wheel_items/get_lucky_wheel_items_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_switch.dart';

class LuckyWheelViewBody extends StatelessWidget {
  const LuckyWheelViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: AppConstants.height20(context)),
          CustomAppBar(
            title: "عجلة الحظ",
            hasBack: true,
            textColor: Colors.black,
          ),
          SizedBox(height: AppConstants.height20(context)),
          Expanded(
            child: BlocBuilder<GetLuckyWheelItemsCubit, GetLuckyWheelItemsState>(
              builder: (context, state) {
                if (state is GetLuckyWheelItemsSuccessState) {
                  return ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return LuckyWheelItem(instance: state.model.data!.rewards![index], index: index);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: AppConstants.height20(context));
                    },
                    itemCount: state.model.data!.rewards!.length,
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
