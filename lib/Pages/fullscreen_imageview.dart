import 'package:flutter/material.dart';
import 'package:dox/Utils/reusable_widgets.dart';

class FullScreenImageView extends StatelessWidget {
  final List<dynamic> imageUrls;
  final List imageFiles;

  const FullScreenImageView({Key key, this.imageUrls, this.imageFiles})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Images'),
      ),
      body: InteractiveViewer(
        child: ImageSlider(
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          imageUrl: imageUrls,
          imageFiles: imageFiles,
        ),
      ),
    );
  }
}
