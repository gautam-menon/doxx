import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Providers/login_provider.dart';
import 'package:dox/Services/auth_service.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';
import 'package:provider/provider.dart';
import 'package:dox/Services/notification_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => LoginProvider(),
      child: Consumer<LoginProvider>(
        builder: (BuildContext context, value, Widget child) => Scaffold(
          backgroundColor: backgroundColor,
          body: value.isLoading
              ? Center(
                  child: CupertinoActivityIndicator(),
                )
              : SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          child: Center(
                            child: Text(
                              'Sign in',
                              style: bigBlackText,
                            ),
                          ),
                          height: screenHeight * .16,
                        ),
                        form(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () => locator<NavigationService>()
                                    .replaceCurrentWith('signUpPage'),
                                child: Text(
                                  'Create an account',
                                  style: smallblacknormaltext,
                                ),
                              )),
                        ),
                        SizedBox(height: screenHeight * .05),
                        GoogleSignInButton(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Form form() {
    return Form(
      key: formKey,
      child: Consumer<LoginProvider>(
        builder: (context, value, child) => Container(
          height: screenHeight * .5,
          width: screenWidth * .9,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextFormField(
                  validator: (value) => !value.contains('@')
                      ? 'Please enter a valid email address'
                      : null,
                  controller: emailController,
                  decoration: InputDecoration(hintText: 'Email'),
                ),
                TextFormField(
                  validator: (value) => value.length < 8
                      ? 'Passwords require atleast 8 characters'
                      : null,
                  decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                          icon: Icon(value.obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => value.setObscureText())),
                  controller: passwordController,
                  obscureText: value.obscure,
                ),
                Container(
                  width: screenWidth * .8,
                  color: primaryAppColor,
                  child: CupertinoButton(
                      child: Text(
                        'Sign in',
                        style: smallwhitenormaltext,
                      ),
                      onPressed: () => signInCheck(value)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  signInCheck(LoginProvider value) async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var user =
          await value.login(emailController.text, passwordController.text);
      if (user['status']) {
        locator<NavigationService>().replaceCurrentWith('landingPage');
      } else {
        buildShowDialog(context, 'Oops!', user['error']);
      }
    }
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        //isExtended: true,

        style: ElevatedButton.styleFrom(
          primary: Colors.white,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 220,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: 13,
                  ),
                  child: Image.asset('images/google_light.png'),
                ),
                Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Colors.black54,
                    // fontSize: fontSize,
                    //backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
        ),
        onPressed: () async {
          try {
            var user = await locator<AuthService>().googleLogin();
            if (user != null) {
              locator<NotificationService>().init();
              locator<NavigationService>().replaceCurrentWith('landingPage');
            } else {
              buildShowDialog(context, 'Oops!', 'Could not log you in :(');
            }
          } catch (e) {
            buildShowDialog(context, 'Oops!', 'Something went wrong. $e');
          }
        });
  }
}
