import 'package:dox/Pages/review_ad_page.dart';
import 'package:flutter/material.dart';

import '../Models/user_model.dart';
import '../Pages/bug_report_page.dart';
import '../Pages/edit_item_page.dart';
import '../Pages/favorites_page.dart';
import '../Pages/fullscreen_imageview.dart';
import '../Pages/item_by_uid.dart';
import '../Pages/item_page.dart';
import '../Pages/submit_review.dart';
import '../Pages/user_items.dart';
import '../Pages/user_review.dart';
import '../Screens/home_screen.dart';
import '../Screens/login_screen.dart';
import '../Screens/signup_page.dart';
import '../Services/auth_service.dart';
import '../Utils/locator.dart';

MaterialPageRoute generateRoute(RouteSettings settings) {
  UserModel user = locator<AuthService>().getCurrentUser();
  switch (settings.name) {
    case 'loginPage':
      return MaterialPageRoute(builder: (context) => LoginPage());
      break;
    case 'landingPage':
      return MaterialPageRoute(
          builder: (context) => HomePage(index: settings.arguments));
      break;
    case 'favoritesPage':
      return MaterialPageRoute(builder: (context) => FavoritesPage());
      break;
    case 'userItems':
      return MaterialPageRoute(builder: (context) => UserItems(user: user));
      break;
    case 'bugReport':
      return MaterialPageRoute(builder: (context) => BugReportPage(user: user));
      break;

    // case 'categoryPage':
    //   return MaterialPageRoute(
    //       builder: (context) => CategoryPage(
    //             category: settings.arguments,
    //           ));
    //   break;
    case 'fullscreenImage':
      List args = settings.arguments;
      return MaterialPageRoute(
          builder: (context) => FullScreenImageView(
                imageUrls: args[0],
                imageFiles: args[1],
              ));
      break;

    case 'signUpPage':
      return MaterialPageRoute(builder: (context) => SignUp());
      break;
    case 'itemsByUid':
      return MaterialPageRoute(
          builder: (context) => ItemsByUid(
                userModel: settings.arguments,
              ));
      break;
    case 'editItemPage':
      return MaterialPageRoute(
          builder: (context) => EditPage(item: settings.arguments));
      break;

    case 'reviewUser':
      return MaterialPageRoute(
          maintainState: false,
          builder: (context) =>
              ReviewUser(userModel: settings.arguments, reviewer: user));
    case 'submitReview':
      return MaterialPageRoute(
          builder: (context) =>
              SubmitReview(userModel: settings.arguments, reviewer: user));
    case 'itemPage':
      return MaterialPageRoute(
        builder: (context) => ItemPage(
          user: user,
          item: settings.arguments,
        ),
      );
      break;
    case 'reviewPage':
      return MaterialPageRoute(
          builder: (context) => ReviewPage(
                item: settings.arguments,
              ));
    default:
      return MaterialPageRoute(
          builder: (context) => Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Text(
                    'No path for ${settings.name}',
                  ),
                ),
              ));
      break;
  }
}
