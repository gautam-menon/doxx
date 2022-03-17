import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Helpers/constants.dart';
import '../Models/user_model.dart';
import '../Services/Firebase/firebase_services.dart';
import '../Utils/locator.dart';
import '../Utils/reusable_widgets.dart';

class BugReportPage extends StatefulWidget {
  final UserModel user;

  BugReportPage({Key key, this.user}) : super(key: key);

  @override
  _BugReportPageState createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  TextEditingController bugText = TextEditingController();
  bool done = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report a bug'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Text(
                  'Describe the bug',
                  style: bigBlackText,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  controller: bugText,
                  decoration: InputDecoration(
                    hintMaxLines: 4,
                    fillColor: backgroundColor,
                    hintText: "Description",
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 150),
                    filled: true,
                  ),
                ),
              ),
              done
                  ? Text("Thank you for reporting the bug, you're a gem :)")
                  : isLoading
                      ? CupertinoActivityIndicator()
                      : Container(
                          width: MediaQuery.of(context).size.width * .5,
                          child: FloatingActionButton(
                            heroTag: 'bug',
                            isExtended: true,
                            backgroundColor: primaryAppColor,
                            onPressed: () async {
                              bool result;
                              if (bugText.text != '') {
                                setState(() {
                                  isLoading = true;
                                });
                                result = await locator<FirebaseServices>()
                                    .submitBug(widget.user, bugText.text);
                                if (result) {
                                  setState(() {
                                    done = true;
                                  });
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  failPopUp(context);
                                }
                              }
                            },
                            child: Text('Submit'),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Future failPopUp(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Something went wrong'),
              actions: [
                Center(
                    child: Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: FloatingActionButton(
                      heroTag: 'fail',
                      isExtended: true,
                      child: Text('Okay'),
                      onPressed: () => Navigator.of(context).pop()),
                ))
              ],
            ));
  }
}
