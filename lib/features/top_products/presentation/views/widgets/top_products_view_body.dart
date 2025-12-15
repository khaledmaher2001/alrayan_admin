import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/most_ordered_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/text_styles/styles.dart';
import '../../view_models/get_top_products_cubit/get_top_products_cubit.dart';
class TopProductsViewBody extends StatelessWidget {
  const TopProductsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.height20(context),),
          CustomAppBar(title: "المنتجات الاكثر طلبا",textColor: Colors.black,withNotifications: false,hasBack: true,),
          SizedBox(height: AppConstants.height20(context),),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Text(
              "حاول توفير المنتجات الاكثر طلبا باستمرار",
              style: Styles.inter14600gray(context),
            ),
          ),
          SizedBox(height: AppConstants.height10(context),),
          Expanded(
            child: BlocBuilder<GetTopProductsCubit,GetTopProductsState>(
              builder: (context,state) {
               if(state is GetTopProductsLoaded)
                 {
                   return ListView.separated(
                     padding: EdgeInsets.zero,
                     itemBuilder: (BuildContext context, int index) {
                     return Padding(
                       padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
                       child: Column(
                         children: [
                           if(index==0)
                             SizedBox(height: AppConstants.height10(context),),
                           MostOrderedItem(instance: state.users[index], fromHome: false,),
                           if(index==state.users.length-1)
                             SizedBox(height: AppConstants.height20(context),),
                         ],
                       ),
                     );
                   }, separatorBuilder: (BuildContext context, int index) {
                     return SizedBox(height: AppConstants.height20(context),);
                   }, itemCount: state.users.length,);
                 }else{
                 return CustomLoadingItem();
               }
              }
            ),
          ),
      
        ],
      ),
    );
  }
}
