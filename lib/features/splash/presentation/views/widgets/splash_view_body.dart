import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/assets/assets.dart';
import '../../../../../core/utils/colors/colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/services/local_services/cache_keys.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    navigate();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duration of the animation
      vsync: this,
    );

    // Define the animation (scaling)
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Animation curve
      ),
    );

    // Start the animation
    _controller.repeat(reverse: true);

    // Delay navigation logic
  }

  void navigate({int seconds = 2}) {
    Future.delayed(Duration(seconds: seconds), () async {
      if (CacheKeysManger.tokenStatus() != "") {
        GoRouter.of(context).pushReplacement("/mainLayoutView");
      } else {
        GoRouter.of(context).pushReplacement("/loginView");
      }
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.width20(context),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetData.logoBackWhite,
                        width:
                        MediaQuery.of(context).size.width * .4,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.width20(context),
                      vertical: AppConstants.height20(context),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Made with love by",
                            style: Styles.DIN18500(context)
                                .copyWith(
                              color: Colors.black,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: AppConstants.width5(context),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppConstants.sp30(context),
                            ),
                            child: Image.asset(
                              AssetData.acwad,
                              width:
                              MediaQuery.of(
                                context,
                              ).size.width *
                                  .11,
                              height:
                              MediaQuery.of(
                                context,
                              ).size.width *
                                  .11,
                            ),
                          ),
                          SizedBox(
                            width: AppConstants.width5(context),
                          ),
                          InkWell(
                            onTap: () async {
                              // await launchUrlString("http://dgytos.com/");
                            },
                            child: Text(
                              "أكواد ACWAD",
                              style: Styles.DIN18500(context)
                                  .copyWith(
                                color: Colors.black,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
