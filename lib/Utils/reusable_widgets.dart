import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Pages/user_page.dart';
import 'package:dox/Providers/user_interaction_provider.dart';

import 'package:dox/Services/Firebase/firebase_services.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';

import 'package:shimmer/shimmer.dart';
import 'locator.dart';
import 'navigation.dart';

TextStyle get bigBlackText => TextStyle(fontSize: 22, color: Colors.black);
TextStyle get smallBlackText => TextStyle(fontSize: 18, color: Colors.black);

TextStyle get bigblacknormaltext =>
    TextStyle(fontSize: 20, fontFamily: 'Poppins-Medium', color: Colors.black);
TextStyle get smallblacknormaltext =>
    TextStyle(fontSize: 18, fontFamily: 'Poppins-Medium', color: Colors.black);
TextStyle get bigwhitenormaltext =>
    TextStyle(fontSize: 22, fontFamily: 'Poppins-Medium', color: Colors.white);
TextStyle get smallwhitenormaltext =>
    TextStyle(fontSize: 18, fontFamily: 'Poppins-Medium', color: Colors.white);
Future buildShowDialog(BuildContext context, title, content) {
  double screenHeight = MediaQuery.of(context).size.height;

  return showDialog(
      context: context,
      builder: (context) => Dialog(
            child: Container(
              height: screenHeight * .3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ListTile(
                    title: Text(
                      title,
                      // style: bigBlackText,
                    ),
                    subtitle: Text(
                      content,
                      // style: smallBlackText,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .5,
                    child: FloatingActionButton(
                        heroTag: 'pop',
                        isExtended: true,
                        child: Text('Okay'),
                        onPressed: () => Navigator.of(context).pop()),
                  )
                ],
              ),
            ),
          ));
}

Widget shimmerLoading(context) {
  return Container(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 6,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(children: [
              Container(
                width: 148.0,
                height: 220.0,
                color: Colors.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 148.0,
                      height: 8.0,
                      color: Colors.white,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.0),
                    ),
                    Container(
                      width: 40.0,
                      height: 8.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ]);
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
              crossAxisCount: 2),
        ),
      ),
    ),
  );
}

Widget shimmerItem(context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;
  return Container(
    child: Padding(
      padding: const EdgeInsets.all(1.0),
      child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Container(
            height: screenHeight * 0.35,
            width: screenWidth * 0.3,
            color: Colors.white,
          )),
    ),
  );
}

class ItemTile extends StatelessWidget {
  final UserModel user;
  final DocumentModel item;
  final BoxFit fit;

  const ItemTile({
    Key key,
    @required this.item,
    this.fit,
    @required this.user,
  }) : super(key: key);

  String url() {
    if (item?.imageUrl == null || item.imageUrl.length < 1) {
      return 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Fsymbol-blue-set-3%2F100%2FUntitled-1-94-512.png&f=1&nofb=1';
    } else {
      return item?.imageUrl?.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Consumer<DocumentSnapshot<Map<String, dynamic>>>(
        builder: (context, likes, child) {
      final bool isLiked = likes?.data() == null
          ? false
          : likes.data()['itemId'].contains(item.id);
      return Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onLongPress: () =>
              item.user.uid == user.uid ? {} : onLongPressFunction(context),
          onTap: () => locator<NavigationService>()
              .navigateTo('itemPage', arguments: item),
          child: Container(
            height: screenHeight * .36,
            width: screenWidth * .5,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Stack(
                children: [
                  imageWidget(screenWidth),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: screenHeight * .1,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              item?.title ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Lato-Bold',
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              item?.category ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black54,
                                fontFamily: 'Lato-Bold',
                                fontSize: 12,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: inActiveIndicator(
                                  user, isLiked, screenHeight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future onLongPressFunction(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChatOptions(
                title: 'View profile',
                function: () => showUserDetails(item.user, context),
              ),
              ChatOptions(
                title: 'View this category',
                function: () => locator<NavigationService>()
                    .navigateTo('categoryPage', arguments: item.category),
              ),
              ChatOptions(
                title: 'Report',
                function: () => locator<NavigationService>()
                    .navigateTo('reportPage', arguments: item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding inActiveIndicator(UserModel user, bool isLiked, double screenHeight) {
    const String inactive = 'inactive';
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: item.status == inactive
            ? Text(
                '${inactive.toUpperCase()}',
                style: TextStyle(color: primaryAppColor),
              )
            : LikeIcon(
                isLiked: isLiked, screenHeight: screenHeight, item: item));
  }

  imageWidget(double screenWidth) {
    return Align(
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: SizedBox.expand(
          child: CachedNetworkImage(
            progressIndicatorBuilder: (context, url, progress) => ImageLoader(
              screenWidth: screenWidth,
              progress: progress,
            ),
            fit: fit ?? BoxFit.fitHeight,
            imageUrl: url(),
          ),
        ),
      ),
    );
  }
}

class ImageLoader extends StatelessWidget {
  const ImageLoader({
    Key key,
    @required this.screenWidth,
    this.progress,
  }) : super(key: key);

  final double screenWidth;
  final DownloadProgress progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: screenWidth * .12,
          height: screenWidth * .12,
          child: CircularProgressIndicator(
            value: progress?.progress ?? 0,
            backgroundColor: backgroundColor,
          ),
        ),
      ),
    );
  }
}

class ChatOptions extends StatelessWidget {
  final Function function;
  final String title;
  const ChatOptions({
    Key key,
    this.function,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: function,
        child: ListTile(
          title: Text(title),
        ));
  }
}

class LikeIcon extends StatelessWidget {
  const LikeIcon({
    Key key,
    @required this.isLiked,
    @required this.screenHeight,
    @required this.item,
  }) : super(key: key);

  final bool isLiked;
  final double screenHeight;
  final DocumentModel item;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserInteractionProvider>.value(
      //initialData: false,
      value: UserInteractionProvider(),
      child: Consumer<UserInteractionProvider>(
        builder: (context, value, child) {
          return LikeButton(
            size: screenHeight * .036,
            isLiked: value.tempLike ?? isLiked,
            onTap: (val) async {
              if (isLiked) {
                value.setTempLike(true);
                locator<FirebaseServices>().removeFavorite(item);
              } else {
                value.setTempLike(false);
                locator<FirebaseServices>().setFavorite(item);
              }
              return !isLiked;
            },
          );
        },
      ),
    );
  }
}

class ImageSlider extends StatelessWidget {
  final List<dynamic> imageUrl;
  final List<File> imageFiles;
  final double screenHeight;
  final double screenWidth;

  const ImageSlider(
      {Key key,
      this.imageUrl,
      this.screenHeight,
      this.screenWidth,
      this.imageFiles})
      : super(key: key);

  Widget imageWidget() {
    if (imageFiles != null && imageFiles.length > 0) {
      return Carousel(
        dotColor: Colors.black54,
        dotSize: 5,
        autoplayDuration: Duration(seconds: 5),
        boxFit: BoxFit.fill,
        images: imageFiles.map((item) => Image.file(item)).toList(),
      );
    } else if (imageUrl == null || imageUrl.length == 0) {
      return Center(
        child: Text(
          'No images found',
          style: smallBlackText,
        ),
      );
    }
    return Carousel(
      dotColor: backgroundColor,
      radius: Radius.circular(10),
      dotSize: 5,
      dotBgColor: Colors.black12,
      autoplayDuration: Duration(seconds: 5),
      boxFit: BoxFit.fill,
      images: imageUrl
          .map((item) => CachedNetworkImage(
                placeholder: (s, n) => CupertinoActivityIndicator(),
                imageUrl: item,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: screenHeight,
      width: screenWidth,
      child: imageWidget(),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function ontap;
  const DrawerTile({
    Key key,
    @required this.screenHeight,
    this.title,
    this.icon,
    this.ontap,
  }) : super(key: key);

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: ontap,
        title: Text(title,
            style: TextStyle(
                // fontSize: 22,
                // fontFamily: 'Roboto',
                color: primaryAppColor)),
        leading: Icon(icon, color: primaryAppColor)
        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(title,
        //         style: TextStyle(
        //           fontSize: 22,
        //           fontFamily: 'Roboto',
        //         )
        //         //style: smallblacknormaltext,
        //         ),
        //     Icon(icon)
        //   ],
        // ),
        );
  }
}

class SizeCircle extends StatelessWidget {
  const SizeCircle({
    Key key,
    this.size,
    this.isSelected,
    this.sizeOfCircle,
  }) : super(key: key);

  final bool isSelected;
  final String size;
  final double sizeOfCircle;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return CircleAvatar(
      radius: screenWidth * .01 * sizeOfCircle + 2,
      backgroundColor: primaryAppColor,
      child: CircleAvatar(
        radius: screenWidth * .01 * sizeOfCircle,
        backgroundColor: isSelected ? primaryAppColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : primaryAppColor,
        child: Center(
            child: Text(
          size,
          //  style: TextStyle(color: primaryAppColor),
        )),
      ),
    );
  }
}

class UserTiles extends StatelessWidget {
  final Function ontap;
  final String title;
  final Icon icon;

  const UserTiles({Key key, this.ontap, this.title, this.icon})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Card(
        child: ListTile(title: Text(title), trailing: icon),
      ),
    );
  }
}

Future showUserDetails(UserModel user, BuildContext context) {
  return showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: UserPage(
              userModel: user,
            ),
          ));
}

class LoaderWidget extends StatelessWidget {
  final String text;
  final double screenHeight;
  final double screenWidth;
  const LoaderWidget({
    Key key,
    this.text,
    this.screenHeight,
    this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: screenWidth * .9,
        height: screenHeight * .5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CupertinoActivityIndicator(), Text('$text ༼ つ ◕_◕ ༽つ')],
        ));
  }
}

class ErrorDialog extends StatelessWidget {
  final String error;
  final double screenHeight;
  final double screenWidth;
  const ErrorDialog({
    Key key,
    this.error,
    this.screenHeight,
    this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * .9,
      height: screenHeight * .5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(
            radius: screenHeight * .06,
            backgroundColor: primaryAppColor,
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: screenHeight * .1,
            ),
          ), //bookings, delete, disable, in options
          Text(
            'Oops!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Something went wrong. Please try again. Code: $error',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .5,
            child: FloatingActionButton(
                heroTag: 'error',
                isExtended: true,
                child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop()),
          )
        ],
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function function;
  final double screenHeight;
  final double screenWidth;

  const SuccessDialog({
    Key key,
    this.title,
    this.subtitle,
    this.function,
    this.screenHeight,
    this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * .9,
      height: screenHeight * .5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(
            radius: screenHeight * .06,
            backgroundColor: primaryAppColor,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: screenHeight * .1,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .5,
            child: FloatingActionButton(
              heroTag: 'submitSuccess',
              isExtended: true,
              child: Text('Okay'),
              onPressed: function,
            ),
          )
        ],
      ),
    );
  }
}

disableDialog(BuildContext context, DocumentModel item) async {
  bool result;
  bool isLoading = false;
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
          child: StatefulBuilder(
              builder: (BuildContext context,
                      void Function(void Function()) setState) =>
                  Container(
                    height: MediaQuery.of(context).size.height * .4,
                    child: isLoading
                        ? Center(
                            child: CupertinoActivityIndicator(),
                          )
                        : result == null
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                    ListTile(
                                      title: Text(
                                        'Disable Ad?',
                                      ),
                                      subtitle: Text(
                                        'Are you sure you want to disable this ad?',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.grey,
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                'Nope',
                                                style: smallblacknormaltext,
                                              )),
                                          ElevatedButton(
                                              onPressed: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                bool response = await locator<
                                                        FirebaseServices>()
                                                    .disableAd(item);
                                                setState(() {
                                                  result = response;
                                                  isLoading = false;
                                                });
                                              },
                                              child: Text(
                                                'Yup ',
                                                style: smallblacknormaltext,
                                              )),
                                        ],
                                      ),
                                    )
                                  ])
                            : result
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ListTile(
                                        title: Text('Ad disbaled'),
                                        subtitle: Text(
                                            'Your ad has been successfully disabled.'),
                                      ),
                                      ElevatedButton(
                                          child: Text('Okay'),
                                          onPressed: () =>
                                              locator<NavigationService>()
                                                  .replaceCurrentWith(
                                                      'landingPage'))
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ListTile(
                                        title: Text('Oops'),
                                        subtitle: Text('Please try again.'),
                                      ),
                                      ElevatedButton(
                                        child: Text('Okay'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      )
                                    ],
                                  ),
                  ))));
}

class BottomLoader extends StatelessWidget {
  const BottomLoader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CupertinoActivityIndicator(),
          );
        },
        childCount: 1,
      ),
    );
  }
}
