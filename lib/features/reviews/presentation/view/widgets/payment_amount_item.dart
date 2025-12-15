import 'package:flutter/material.dart';

import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class PaymentAmountItem extends StatelessWidget {
  const PaymentAmountItem({super.key, required this.title, required this.amount,this.isTotal=false,this.padding});

  final String title,amount;
  final bool isTotal;
 final  double? padding;

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal:padding?? AppConstants.width20(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(title,style: isTotal?Styles.inter14600black(context):Styles.inter12600Black(context)),
          ),
          Text("$amount ج.م",style:isTotal?Styles.inter14600black(context).copyWith(color: AppColors.primaryColor): Styles.inter12600Black(context)),

        ],
      ),
    );
  }
}
