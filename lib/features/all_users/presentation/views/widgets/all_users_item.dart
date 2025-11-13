import 'package:alrayan_admin/features/all_users/data/models/all_users_model.dart';
import 'package:alrayan_admin/features/all_users/presentation/views/widgets/user_details_bottom_sheet.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/text_styles/styles.dart';
class AllUsersItem extends StatelessWidget {
  const AllUsersItem({super.key, required this.userData});
  final Items userData;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
      child: InkWell(
        onTap: (){
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            isDismissible: true,
            enableDrag: false,
            builder: (context) => UserDetailsBottomSheet(userData: userData,),
            isScrollControlled: true,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                AppConstants.sp5(context),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppConstants.sp10(context),
                ),
                color: AppColors.gray.withOpacity(.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppConstants.sp10(context),
                ),
                child: SizedBox(
                  height:
                  MediaQuery.of(context).size.width * .12,
                  width:
                  MediaQuery.of(context).size.width * .12,
                  child: Center(
                    child: Text(
                      userData.fullName!
                          .substring(0, 1)
                          .toUpperCase(),
                      style: Styles.inter18500Black(context),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppConstants.width10(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData.fullName!,
                    style: Styles.inter14500black(context),
                  ),
                  SizedBox(
                    height: AppConstants.height5(context),
                  ),
                  Text(
                    userData.email!,
                    style: Styles.inter10400grey(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
