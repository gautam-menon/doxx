import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Helpers/constants.dart';
import 'Helpers/routes.dart';
import 'Helpers/themes.dart';
import 'Providers/user_interaction_provider.dart';
import 'Services/auth_service.dart';
import 'Services/notification_service.dart';
import 'Utils/locator.dart';
import 'Utils/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  setupLocator();
  locator<AuthService>().init();
  locator<NotificationService>().init();
  User user = locator<AuthService>().checkIfLoggedIn();
  String path = 'loginPage';
  if (user != null) {
    path = 'landingPage';
  }
  runApp(StreamProvider<DocumentSnapshot<Map<String, dynamic>>>(
      initialData: null,
      create: (_) => UserInteractionProvider().getLikes(user.uid),
      child: MyApp(path)));
}

class MyApp extends StatelessWidget {
  MyApp(this.initialPath);
  final String initialPath;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: lightTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: initialPath,
      navigatorKey: locator<NavigationService>().navigatorKey,
    );
  }
}
