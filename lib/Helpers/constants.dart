import 'package:flutter/material.dart';

const String appName = 'Dox';
const String rupeeSign = '₹';

const String userData = 'userData';
const String allItems = 'AllItems';
const String favIds = 'FavIds';
const String favorites = 'Favorites';
const String fcmToken = 'FCMtoken';
const String items = 'Items';
const String reviews = 'Reviews';

const Color primaryAppColor = Color(0xffFFCB37);
const Color secondaryAppColor = Color(0xffffffff);
const Color backgroundColor = Color(0xffE0E7EF);
const Color blackColor = Colors.black;
const String storageUrl = 'gs://dox-37b27.appspot.com';
const String termsAndConditionsUrl = '';

List<String> sizeList = ['XS', 'S', 'M', 'L', 'XL'];
List<String> categories = [
  'Office', 'Personal', 'Property', 'College'
];
List<Color> colors = [
  Color(0xffffd644),
  Color(0xff067EED),
  Color(0xffFF7C1F),
  Color(0xff6730ec),
  Color(0xffDB1D4B),
  Color(0xffFF6187)
];

enum AdStatus { active, inactive, sold, deleted }
