import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';

class UserPage extends StatelessWidget {
  final UserModel userModel;

  const UserPage({
    Key key,
    this.userModel,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.black54,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          userModel?.photoURL != null
              ? CircleAvatar(
                  radius: screenHeight * .095,
                  backgroundColor: Colors.white,
                  child: CachedNetworkImage(
                    imageUrl: userModel.photoURL,
                    progressIndicatorBuilder: (context, url, progress) =>
                        ImageLoader(
                      screenWidth: screenWidth,
                      progress: progress,
                    ),
                    imageBuilder: (context, image) {
                      return CircleAvatar(
                        radius: screenHeight * .09,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              userModel?.name ?? '',
              style: bigblacknormaltext,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                UserTiles(
                    ontap: () => locator<NavigationService>()
                        .navigateTo('reviewUser', arguments: userModel),
                    icon: Icon(Icons.arrow_right),
                    title: 'See Reviews'),
                UserTiles(
                    ontap: () => locator<NavigationService>()
                        .navigateTo('submitReview', arguments: userModel),
                    icon: Icon(Icons.arrow_right),
                    title: 'Write a Review'),
                UserTiles(
                    ontap: () => locator<NavigationService>()
                        .navigateTo('itemsByUid', arguments: userModel),
                    icon: Icon(Icons.arrow_right),
                    title: 'See all ads by ${userModel.name ?? 'this user'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
