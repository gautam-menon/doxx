import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';
import 'package:dox/Utils/locator.dart';

class UserInteractionProvider with ChangeNotifier {
  bool _tempLike;
  bool get tempLike => _tempLike;

  setTempLike(bool isLiked) async {
    _tempLike = !isLiked;
    notifyListeners();
    Future.delayed(Duration(seconds: 5), () {
      _tempLike = null;
      notifyListeners();
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getLikes(String uid) {
    return locator<FirebaseServices>().getLikes(uid);
  }
}
