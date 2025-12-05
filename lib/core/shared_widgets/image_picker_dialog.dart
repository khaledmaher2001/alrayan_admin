import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/colors/colors.dart';
import '../utils/constants.dart';
import '../utils/text_styles/styles.dart';

Future<ImageSource?> showImageSourceSelector(BuildContext context) async {
  return showModalBottomSheet<ImageSource>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.width20(context))),
    ),
    showDragHandle: false,
    builder: (context) => SafeArea(
      child: Container(
        color: Color(0xffE9F1FF),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: AppConstants.height10(context),
              horizontal: AppConstants.width20(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: AppConstants.height5(context),
                width: MediaQuery.sizeOf(context).width * .45,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppConstants.width20(context)),
                    color: Colors.grey,),
              ),
              SizedBox(height: AppConstants.height20(context)),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.width10(context),
                    horizontal: AppConstants.width10(context),
                  ),
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppConstants.sp10(context)),
                      border: Border.all(color: AppColors.gray)),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.camera),
                      SizedBox(width: AppConstants.width10(context)),
                      Text(
                        'فتح الكاميرا',
                        style: Styles.inter18500Black(context).copyWith(
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppConstants.height10(context)),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.width10(context),
                    horizontal: AppConstants.width10(context),
                  ),
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppConstants.sp10(context)),
                      border: Border.all(color: AppColors.gray)),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.photo_on_rectangle),
                      SizedBox(width: AppConstants.width10(context)),
                      Text(
                        'فتح المعرض',
                        style: Styles.inter18500Black(context).copyWith(
                            color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppConstants.height10(context)),
              ListTile(
                leading: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                title: Text(
                  'اغلاق',
                  style: Styles.inter16500black(context).copyWith(
                      color: Colors.black
                  ),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
