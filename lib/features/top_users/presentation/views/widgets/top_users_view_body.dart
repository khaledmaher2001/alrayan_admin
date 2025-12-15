import 'package:alrayan_admin/core/shared_widgets/custom_app_bar.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_loading_item.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/top_customer_item.dart';
import 'package:alrayan_admin/features/top_users/presentation/view_models/get_top_users_cubit/get_top_users_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/text_styles/styles.dart';
class TopUsersViewBody extends StatelessWidget {
  const TopUsersViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppConstants.height20(context),),
          CustomAppBar(title: "العملاء الاكثر طلبا",textColor: Colors.black,withNotifications: false,hasBack: true,),
          SizedBox(height: AppConstants.height20(context),),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
            child: Text(
              "حاول انشاء كوبونات خصم تشجيعا للعملاء الاكثر طلبا",
              style: Styles.inter14600gray(context),
            ),
          ),
          SizedBox(height: AppConstants.height10(context),),
          Expanded(
            child: BlocBuilder<GetTopUsersCubit,GetTopUsersState>(
              builder: (context,state) {
               if(state is GetTopUsersLoaded)
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
                           TopCustomerItem(instance: state.users[index],fromHome: false, index: index,),
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
