import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Services/auth_service.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user = locator<AuthService>().getCurrentUser();
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryAppColor,
        elevation: 0,
      ),
      drawer: DrawerItems(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  color: primaryAppColor,
                  width: double.infinity,
                  height: screenHeight * 0.35,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: user?.photoURL != null
                              ? CircleAvatar(
                                  radius: screenHeight * .075,
                                  backgroundColor: Colors.white,
                                  child: CachedNetworkImage(
                                    imageUrl: user.photoURL,
                                    progressIndicatorBuilder:
                                        (context, url, progress) => ImageLoader(
                                      screenWidth: screenWidth,
                                      progress: progress,
                                    ),
                                    imageBuilder: (context, image) {
                                      return CircleAvatar(
                                        radius: screenHeight * .07,
                                        backgroundColor: primaryAppColor,
                                        backgroundImage: image,
                                      );
                                    },
                                  ),
                                )
                              : CircleAvatar(
                                  radius: screenHeight * .07,
                                  child: Icon(
                                    Icons.person,
                                    size: screenHeight * .06,
                                  ),
                                ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          user?.name?.toUpperCase() ?? '',
                          style: bigblacknormaltext,
                        ),
                        Text(
                          user?.email?.toLowerCase() ?? '',
                          style: smallblacknormaltext,
                        ),
                      ])),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                height: screenHeight * 0.45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RewardButton(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      function: () => locator<NavigationService>()
                          .navigateTo('favoritesPage'),
                      title: 'Favorites',
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                    ),
                    RewardButton(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      function: () => locator<NavigationService>()
                          .navigateTo('reviewUser', arguments: user),
                      title: 'Your\n Reviews',
                      child: Icon(
                        Icons.star,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
                height: screenHeight * .3,
                width: double.infinity,
                color: primaryAppColor,
                child: Center(
                    child: Icon(
                  Icons.document_scanner_outlined,
                  size: screenHeight * .2,
                ))),
            DrawerTile(
                screenHeight: screenHeight,
                title: 'Report a bug',
                icon: Icons.bug_report,
                ontap: () {
                  locator<NavigationService>().navigateTo('bugReport');
                }),
            DrawerTile(
                screenHeight: screenHeight,
                title: 'Terms and Conditions',
                icon: Icons.text_format_rounded,
                ontap: () => launch(termsAndConditionsUrl)),
            DrawerTile(
                screenHeight: screenHeight,
                title: 'Sign out',
                icon: Icons.logout,
                ontap: () async {
                  await locator<AuthService>().logOut();
                  locator<NavigationService>().replaceCurrentWith('loginPage');
                }),
          ],
        ),
      ),
    );
  }
}

class RewardButton extends StatelessWidget {
  const RewardButton({
    Key key,
    @required this.screenHeight,
    @required this.screenWidth,
    this.child,
    this.title,
    this.function,
    this.color,
  }) : super(key: key);

  final double screenHeight;
  final double screenWidth;
  final Widget child;
  final String title;
  final Function function;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * .22,
      width: screenWidth * .33,
      child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: function,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: screenWidth * .11,
                  backgroundColor: primaryAppColor,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    radius: screenWidth * .1,
                    child: child,
                  ),
                ),
                SizedBox(
                  height: screenHeight * .06,
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
