import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/assets/assets.dart';
import '../utils/constants.dart';
import '../utils/text_styles/styles.dart';
import 'overlay_controller.dart';

class NoInternetOverlay extends StatelessWidget {
  const NoInternetOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InternetOverlayController.isOffline,
      builder: (context, offline, child) {
        if (!offline) return const SizedBox.shrink();

        return Material(
          color: Colors.black54,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppConstants.sp20(context)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AssetData.noInternet,
                      width: MediaQuery.of(context).size.width * .3,
                    ),
                    SizedBox(height: AppConstants.height10(context)),
                    Text(
                      "s_no_internet_connection".tr(),
                      style: Styles.inter18500Black(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "s_you_seem_to_be_offline_please_check_".tr(),
                      style: Styles.inter14600gray(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}