import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';
import 'package:dox/Utils/locator.dart';

class OrderProvider with ChangeNotifier {
  QuerySnapshot _data;
  QuerySnapshot get data => _data;
  List<File> _images = [];
  List<File> get images => _images;
  String _size;
  String get size => _size;
  bool _canMessage = true;
  bool get canMessage => _canMessage;

  List<bool> _isSelected = [false, false, false, false, false];
  List<bool> get isSelected => _isSelected;

  pickImage(int index) async {
    final picker = ImagePicker();
    final XFile picked = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
    if (picked != null) {
      _images.insert(index, File(picked.path));
      print(_images.length);
    }
    notifyListeners();
  }

  removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  selectSize(String selectedSize) {
    if (_size == selectedSize) {
      _size = '';
    } else {
      _size = selectedSize;
    }
    notifyListeners();
  }

  Future<QuerySnapshot> getData(int limit) async {
    _data = await locator<FirebaseServices>().getTrending(limit);
    return _data;
  }

  Future<bool> refresh(int limit) async {
    _data = null;
    await getData(limit);
    return true;
  }

  changeRadioButtonState(bool value) {
    _canMessage = value;
    notifyListeners();
  }
}
