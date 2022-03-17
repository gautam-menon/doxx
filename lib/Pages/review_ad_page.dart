import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Services/Firebase/order_services.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';

class ReviewPage extends StatelessWidget {
  final DocumentModel document;

  const ReviewPage({Key key, this.document}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => locator<NavigationService>().navigateTo(
                      'fullscreenImage',
                      arguments: [document.imageUrl, document.tempImages]),
                  child: ImageSlider(
                      imageUrl: document.imageUrl,
                      imageFiles: document.tempImages,
                      screenHeight: screenHeight * 0.6,
                      screenWidth: screenWidth),
                ),
                Container(height: screenHeight * 0.55, child: itemDetails()),
                termsAndConditions()
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              heroTag: 'submitAd',
              isExtended: true,
              child: Text('Submit Ad'),
              onPressed: () => submitOrder(document, document.tempImages,
                  screenHeight, screenWidth, context),
            )),
      ),
    );
  }

  Column itemDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Title:",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            document.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        if (document.description.isNotEmpty) ...[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Description:",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ),
              )),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${document.description}',
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              )),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Category",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18,
              ),
            ),
            Text(
              '${document.category}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  termsAndConditions() {
    return RichText(
        text: TextSpan(children: [
      TextSpan(
          text: 'By clicking on Submit ad, I agree with ',
          style: TextStyle(fontSize: 16, color: Colors.black)),
      TextSpan(
        text: '$appName Terms And Conditions ',
        style: TextStyle(fontSize: 16, color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () => launch('https://google.com'),
      ),
    ]));
  }

  submitOrder(DocumentModel item, List<File> images, double screenHeight,
      double screenWidth, BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
              child: Container(
                child: FutureBuilder(
                    future: locator<OrderServices>().uploadItem(item, images),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoaderWidget(
                            text: 'Uploading ad',
                            screenWidth: screenWidth,
                            screenHeight: screenHeight);
                      } else if (snapshot?.data ?? false) {
                        return SuccessDialog(
                          title: 'Your ad was successfully submitted!',
                          subtitle: 'Thank you for choosing $appName :)',
                          function: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            locator<NavigationService>()
                                .replaceCurrentWith('landingPage');
                          },
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        );
                      } else {
                        return ErrorDialog(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            error: snapshot?.data['error']);
                      }
                    }),
              ),
            ));
  }
}
