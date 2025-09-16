import 'package:go_router/go_router.dart';
import 'package:alrayan_admin/core/utils/assets/assets.dart';
import 'package:flutter/material.dart';
import 'package:alrayan_admin/core/utils/constants.dart';
import 'package:alrayan_admin/core/utils/services/local_services/cache_keys.dart';
import '../../../../../core/utils/text_styles/styles.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

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
    navigate();

    // Start the animation
    _controller.repeat(reverse: true);

    // Delay navigation logic
  }

  void navigate({int seconds = 2}) {
    Future.delayed(Duration(seconds: seconds), () async {
      if (CacheKeysManger.tokenStatus() != "") {
        GoRouter.of(context).pushReplacement("/mainLayoutView");
      } else {
        // GoRouter.of(context).pushReplacement("/mainLayoutView");

        GoRouter.of(context).pushReplacement("/loginView");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.width20(context)),
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
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value, // Apply scaling animation
                            child: Image.asset(
                              AssetData.logo,
                              width: MediaQuery.of(context).size.width * .8,
                              color: Colors.white,
                            ),
                          );
                        },
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
                            style: Styles.DIN18500(context).copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: AppConstants.width5(context)),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.sp30(context)),
                            child: Image.asset(
                              AssetData.five,
                              width: MediaQuery.of(context).size.width * .08,
                              height: MediaQuery.of(context).size.width * .08,
                            ),
                          ),
                          SizedBox(width: AppConstants.width5(context)),
                          InkWell(
                            onTap: () async {
                              // await launchUrlString("http://dgytos.com/");
                            },
                            child: Text(
                              "FIVE",
                              style: Styles.DIN18500(
                                context,
                              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
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
