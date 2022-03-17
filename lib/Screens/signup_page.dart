import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Providers/login_provider.dart';
import 'package:dox/Screens/login_screen.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';
import 'package:provider/provider.dart';
import 'package:dox/Services/notification_service.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
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
                                'Sign up',
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
                                      .replaceCurrentWith('loginPage'),
                                  child: Text(
                                    'Sign in instead',
                                    style: smallblacknormaltext,
                                  ),
                                )),
                          ),
                          SizedBox(height: screenHeight * .05),
                          GoogleSignInButton()
                        ],
                      ),
                    ),
                  ),
          ),
        ));
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
                  validator: (value) =>
                      value.length < 2 ? 'Name too small *.*' : null,
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Name'),
                ),
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
                TextFormField(
                  validator: (value) => value != passwordController.text
                      ? 'Passswords do not match'
                      : null,
                  decoration: InputDecoration(
                      hintText: 'Confirm password',
                      suffixIcon: IconButton(
                          icon: Icon(value.obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => value.setObscureText())),
                  //     controller: passwordController,
                  obscureText: value.obscure,
                ),
                Container(
                  width: screenWidth * .8,
                  color: primaryAppColor,
                  child: CupertinoButton(
                      child: Text(
                        'Create account',
                        style: smallwhitenormaltext,
                      ),
                      onPressed: () => signUp(value)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  signUp(LoginProvider value) async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var user = await value.createUser(
          emailController.text, passwordController.text, nameController.text);
      if (user['status']) {
        locator<NotificationService>().init();
        locator<NavigationService>().replaceCurrentWith('landingPage');
      } else {
        buildShowDialog(context, 'Oops!', user['error']);
      }
    }
  }
}
