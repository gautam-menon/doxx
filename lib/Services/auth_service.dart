import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dox/Models/user_model.dart';

class AuthService {
  GoogleSignIn _google;
  FirebaseAuth _auth;
  void init() {
    _google = GoogleSignIn(scopes: ['email']);
    _auth = FirebaseAuth.instance;
  }

  User checkIfLoggedIn() {
    User user = _auth.currentUser;
    return user;
  }

  Future<User> googleLogin() async {
    final GoogleSignInAccount googleSignInAccount = await _google.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    User currentUser = FirebaseAuth.instance.currentUser;
    return currentUser;
  }

  UserModel getCurrentUser() {
    UserModel userModel;
    User user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userModel = UserModel(user?.displayName, user.uid, user.email,
          photoURL: user.photoURL);
    }
    return userModel;
  }

  Future logOut() async {
    await _auth.signOut();
    await _google.signOut();
  }
}
