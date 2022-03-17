import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _obscure = true;
  bool get obscure => _obscure;
  setObscureText() {
    _obscure = !_obscure;
    notifyListeners();
  }

  login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;

      return {'status': true, 'user': userCredential.user};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': false, 'error': e.toString()};
    }
  }

  createUser(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user.updateDisplayName(name);
      FirebaseFirestore.instance
          .collection('userData')
          .doc(userCredential.user.uid)
          .set({'user': userCredential.user.displayName});
      _isLoading = false;

      return {'status': true, 'user': userCredential.user};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'status': false, 'error': e.toString()};
    }
  }
}
