import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/core/shared_widgets/custom_back_button.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/text_styles/styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Page shown while a screen opened by id (e.g. from a push notification)
/// fetches its data: back button + title on top, [body] below.
class DetailsLoaderScaffold extends StatelessWidget {
  const DetailsLoaderScaffold({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppConstants.height10(context)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.width15(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBackButton(),
                  Flexible(
                    child: Text(title, textAlign: TextAlign.center, style: Styles.inter18500Black(context)),
                  ),
                  SizedBox(width: AppConstants.width30(context)),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// Error message with a retry button.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.width20(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: DsColor.danger, size: 48),
            SizedBox(height: AppConstants.height10(context)),
            Text(message, textAlign: TextAlign.center, style: Styles.inter14500black(context)),
            SizedBox(height: AppConstants.height15(context)),
            ElevatedButton(onPressed: onRetry, child: Text("retry".tr())),
          ],
        ),
      ),
    );
  }
}
