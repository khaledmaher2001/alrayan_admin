import 'package:flutter/material.dart';

import '../../shared_widgets/default_cached_network_image.dart';
import '../../utils/colors/colors.dart';
import '../../utils/constants.dart';
import '../../utils/navigation_utility.dart';


class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const FullScreenImageViewer({required this.imageUrl, super.key});

  static Future<void> show(BuildContext context, String imageUrl) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.primaryColor.withAlpha(300),
          padding: EdgeInsets.all(AppConstants.width15(context)),
          child: InteractiveViewer(
            maxScale: 5,
            minScale: 0.5,
            child: Hero(
              tag: widget.imageUrl,
              child: DefaultCachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                imageHeight: double.infinity,
                imageWidth: double.infinity,
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top +
              AppConstants.height10(context),
          right: MediaQuery.paddingOf(context).right +
              AppConstants.width15(context),
          child: InkWell(
            onTap: (){
              NavigationUtils.navigateBack(context: context);
            },
            child: ClipOval(
              child: Material(
                color: AppColors.primarySwatchColor.withAlpha(200),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
