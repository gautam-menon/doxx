import 'package:flutter/material.dart';

import 'constants.dart';

ThemeData get lightTheme => ThemeData(
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.android:
          //ZoomPageTransitionsBuilder()
          CupertinoPageTransitionsBuilder(),
    }),
    primaryColor: Colors.white,
    appBarTheme: AppBarTheme(color: primaryAppColor),
    // secondaryHeaderColor: secondaryAppColor,
    //primaryIconTheme: IconThemeData(color: blackColor),
    buttonTheme: ButtonThemeData(alignedDropdown: true),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(primary: primaryAppColor)),
    fontFamily: 'Poppins-Bold',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: primaryAppColor));
