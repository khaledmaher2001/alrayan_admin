import 'package:flutter/material.dart';

import '../../shared_widgets/default_cached_network_image.dart';
import '../../utils/colors/colors.dart';
import '../../utils/constants.dart';

class FullScreenImageGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageGalleryViewer({
    required this.imageUrls,
    this.initialIndex = 0,
    super.key,
  });

  static Future<void> show(
      BuildContext context, List<String> imageUrls, int initialIndex) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: FullScreenImageGalleryViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  State<FullScreenImageGalleryViewer> createState() =>
      _FullScreenImageGalleryViewerState();
}

class _FullScreenImageGalleryViewerState
    extends State<FullScreenImageGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.primaryColor.withAlpha(300),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) => InteractiveViewer(
              maxScale: 5,
              minScale: 0.5,
              child: Hero(
                tag: widget.imageUrls[index],
                child: DefaultCachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.contain,
                  imageHeight: double.infinity,
                  imageWidth: double.infinity,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top +
              AppConstants.height10(context),
          right: MediaQuery.paddingOf(context).right +
              AppConstants.width15(context),
          child: ClipOval(
            child: Material(
              color: AppColors.primarySwatchColor.withAlpha(200),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: AppConstants.height20(context),
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '${_currentIndex + 1} / ${widget.imageUrls.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
