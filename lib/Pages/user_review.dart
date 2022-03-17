import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';

class ReviewUser extends StatelessWidget {
  final UserModel userModel;
  final UserModel reviewer;

  const ReviewUser({Key key, this.userModel, this.reviewer}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          userModel?.name ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
              height: screenHeight,
              width: screenWidth,
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: locator<FirebaseServices>().getReviews(userModel.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CupertinoActivityIndicator());
                    } else {
                      double avgRating;
                      final List values =
                          snapshot.data?.data()?.values?.toList();
                      if ((values?.length ?? 0) != 0) {
                        avgRating = values
                                .map((m) => m['rating'])
                                .reduce((a, b) => a + b) /
                            values.length;
                      }

                      return Column(
                        children: [
                          userModel.photoURL != null
                              ? CircleAvatar(
                                  radius: screenHeight * .065,
                                  backgroundColor: primaryAppColor,
                                  child: CachedNetworkImage(
                                    imageUrl: userModel.photoURL,
                                    progressIndicatorBuilder:
                                        (context, url, progress) => ImageLoader(
                                      screenWidth: screenWidth,
                                      progress: progress,
                                    ),
                                    imageBuilder: (context, image) {
                                      return CircleAvatar(
                                        radius: screenHeight * .06,
                                        backgroundColor: primaryAppColor,
                                        backgroundImage: image,
                                      );
                                    },
                                  ),
                                )
                              : CircleAvatar(
                                  radius: screenHeight * .095,
                                  child: Icon(
                                    Icons.person,
                                    size: screenHeight * .08,
                                  ),
                                ),
                          Text(
                            '${avgRating?.toStringAsFixed(1) ?? '0.0'}',
                            style: TextStyle(fontSize: 40),
                          ),
                          Container(
                            height: screenHeight * 0.04,
                            width: screenWidth,
                            child: Center(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return Icon(
                                      Icons.star,
                                      color: (avgRating?.floor() ?? 0) > index
                                          ? primaryAppColor
                                          : Colors.black26,
                                      size: screenWidth * 0.08,
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          values?.length == 1
                              ? Text(
                                  '${values?.length ?? 0} Review',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 18),
                                )
                              : Text(
                                  '${values?.length ?? 0} Reviews',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 18),
                                ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          ReviewBar(
                              title: 'Yeet!',
                              percentage: getRatingPercentage(5, values),
                              color: Colors.green),
                          ReviewBar(
                            title: 'Amazing',
                            percentage: getRatingPercentage(4, values),
                            color: Colors.lightGreen,
                          ),
                          ReviewBar(
                            title: 'Average',
                            percentage: getRatingPercentage(3, values),
                            color: Colors.yellow,
                          ),
                          ReviewBar(
                            title: 'Meh',
                            percentage: getRatingPercentage(2, values),
                            color: Colors.orange,
                          ),
                          ReviewBar(
                            title: 'Eeks',
                            percentage: getRatingPercentage(1, values),
                            color: Colors.red,
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Divider(
                            color: Colors.black54,
                          ),
                          Expanded(
                            child: (values?.length ?? 0) == 0
                                ? Center(child: Text('No Reviews yet (╯°□°)╯'))
                                : ListView.builder(
                                    itemCount: values?.length ?? 0,
                                    physics: ClampingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        height: screenHeight * 0.2,
                                        width: screenWidth,
                                        child: ReviewTile(
                                          userModel: UserModel.fromJson(
                                              values[index]['userModel']),
                                          screenWidth: screenWidth,
                                          screenHeight: screenHeight,
                                          rating: values[index]['rating'],
                                          review: values[index]['review'],
                                          timeStamp: values[index]['timeStamp'],
                                        ),
                                      );
                                    }),
                          )
                        ],
                      );
                    }
                  }))),
      bottomNavigationBar: userModel.uid == reviewer.uid
          ? Container(
              height: 0,
              width: 0,
            )
          : Container(
              height: screenHeight * 0.08,
              width: screenWidth,
              child: ElevatedButton(
                child: Text('Write a Review'),
                onPressed: () => locator<NavigationService>()
                    .navigateTo('submitReview', arguments: userModel),
              ),
            ),
    );
  }
}

double getRatingPercentage(int i, List values) {
  if ((values?.length ?? 0) != 0) {
    double val = values.where((element) => element['rating'] == i).length /
        values.length;
    if (val == 0.0) {
      val = 0.01;
    }
    return val;
  } else {
    return 0;
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({
    Key key,
    this.timeStamp,
    @required this.userModel,
    @required this.screenWidth,
    @required this.screenHeight,
    this.rating,
    this.review,
  }) : super(key: key);

  final UserModel userModel;
  final double screenWidth;
  final double screenHeight;
  final int timeStamp;
  final int rating;
  final String review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4),
          leading: SizedBox(
            height: screenHeight * .1,
            child: userModel.photoURL == null
                ? CircleAvatar(child: Icon(Icons.person))
                : CachedNetworkImage(
                    imageUrl: userModel.photoURL,
                    progressIndicatorBuilder: (context, url, progress) =>
                        ImageLoader(
                      screenWidth: screenWidth,
                      progress: progress,
                    ),
                    imageBuilder: (context, image) => CircleAvatar(
                      backgroundImage: image,
                    ),
                  ),
          ),
          title: Text(
            userModel?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Poppins-Medium'),
          ),
          subtitle: SizedBox(
            width: screenWidth * 0.4,
            height: screenHeight * 0.03,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: rating,
                itemBuilder: (context, index) {
                  return Icon(
                    Icons.star,
                    color: (rating ?? 0) > index
                        ? primaryAppColor
                        : Colors.black26,
                    size: screenWidth * 0.06,
                  );
                }),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                DateFormat('dd MMM, yyyy').format(
                  DateTime.fromMillisecondsSinceEpoch(timeStamp),
                ),
                style: TextStyle(fontFamily: 'Poppins-Medium'),
              ),
              Text(
                '${rating.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              )
            ],
          ),
        ),
        Text(
          '$review',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontFamily: 'Poppins-Medium'),
        ),
      ],
    );
  }
}

class ReviewBar extends StatelessWidget {
  final String title;
  final double percentage;
  final Color color;
  const ReviewBar({
    Key key,
    this.title,
    this.percentage,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double barWidth = screenWidth * 0.70;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
            width: screenWidth * 0.23,
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.black54, fontFamily: 'Poppins-Medium'),
            )),
        Container(
          height: screenHeight * 0.01,
          width: barWidth,
          color: Colors.black26,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              color: color,
              height: screenHeight * 0.01,
              width: barWidth * percentage,
            ),
          ),
        )
      ],
    );
  }
}
