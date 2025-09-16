import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/navigation_utility.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (){
        NavigationUtils.navigateBack(context: context);
      },
      child: Container(
        padding: EdgeInsetsDirectional.all(AppConstants.sp10(context)),
        decoration: BoxDecoration(
            color: Color(0x14111111),
           shape: BoxShape.circle
        ),
        child: const Icon(Icons.arrow_back,color: Colors.black,),
      ),
    );
  }
}
