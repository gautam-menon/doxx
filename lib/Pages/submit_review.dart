import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/reusable_widgets.dart';

class SubmitReview extends StatefulWidget {
  final UserModel userModel;
  final UserModel reviewer;

  const SubmitReview(
      {Key key, @required this.userModel, @required this.reviewer})
      : super(key: key);

  @override
  _SubmitReviewState createState() => _SubmitReviewState();
}

class _SubmitReviewState extends State<SubmitReview> {
  int rating;
  TextEditingController reviewController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'Write a Review',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                height: screenHeight,
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      ListTile(
                        //       tileColor: Colors.white,
                        leading: widget.userModel.photoURL == null
                            ? CircleAvatar(child: Icon(Icons.person))
                            : CachedNetworkImage(
                                progressIndicatorBuilder:
                                    (context, url, progress) => ImageLoader(
                                  screenWidth: screenWidth,
                                  progress: progress,
                                ),
                                imageUrl: widget.userModel.photoURL,
                                imageBuilder: (context, image) => CircleAvatar(
                                  backgroundImage: image,
                                ),
                              ),
                        title: Text(
                          widget.userModel.name ?? '',
                          style: TextStyle(fontFamily: 'Poppins-Medium'),
                        ),
                        //add current rating and all maybe
                      ),
                      Divider(),
                      Text(
                        'Rate',
                        style: smallBlackText,
                      ),
                      Container(
                        height: screenHeight * 0.08,
                        width: screenWidth,
                        child: Center(
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return IconButton(
                                  onPressed: () => setState(() {
                                    rating = index + 1;
                                  }),
                                  icon: Icon(
                                    Icons.star,
                                    color: (rating ?? 0) > index
                                        ? primaryAppColor
                                        : Colors.black26,
                                    size: screenWidth * 0.13,
                                  ),
                                );
                              }),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      Text(
                        'Write your Review',
                        style: smallBlackText,
                      ),
                      TextFormField(
                        maxLines: 5,
                        maxLength: 300,
                        validator: (val) =>
                            val == '' ? "Review can't be empty lol" : null,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        controller: reviewController,
                        decoration: InputDecoration(
                          hintMaxLines: 4,
                          fillColor: backgroundColor,
                          hintText: "Review",
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(20.0),
                              ),
                              borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 40),
                          filled: true,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      Center(
                        child: Container(
                          width: screenWidth * .6,
                          child: FloatingActionButton(
                              heroTag: 'submitReview',
                              isExtended: true,
                              onPressed: () async {
                                if (rating != null) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  bool response =
                                      await locator<FirebaseServices>()
                                          .submitReview(
                                              widget.reviewer,
                                              widget.userModel.uid,
                                              rating,
                                              reviewController.text ?? '');
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (response) {
                                    buildShowDialog(context, 'Yaay!',
                                            "Your Review was submitted successfully")
                                        .then((value) =>
                                            Navigator.of(context).pop());
                                  } else {
                                    buildShowDialog(context, 'Oops!',
                                        "Something went wrong, please try again.");
                                  }
                                }
                              },
                              child: Text('Submit Review')),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
