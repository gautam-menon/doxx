import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';
import 'package:dox/Services/auth_service.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';

class UserItems extends StatefulWidget {
  final UserModel user;

  const UserItems({Key key, @required this.user}) : super(key: key);
  @override
  _UserItemsState createState() => _UserItemsState();
}

class _UserItemsState extends State<UserItems> {
  final UserModel user = locator<AuthService>().getCurrentUser();
  final ScrollController scrollController = ScrollController();
  int initLimit = 10;
  int limit;
  scrollListener() {
    if (scrollController.offset >=
            (scrollController.position.maxScrollExtent - 10) &&
        !scrollController.position.outOfRange) {
      setState(() {
        limit += initLimit;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    limit = initLimit;
    scrollController.addListener(() => scrollListener());
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          locator<NavigationService>().navigateTo('landingPage', arguments: 3);
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text('Your Documents'),
          elevation: 0,
        ),
        body: FutureBuilder<QuerySnapshot>(
          future:
              locator<FirebaseServices>().getUserItems(widget.user.uid, limit),
          builder: (context, snapshot) {
            if (snapshot.data?.docs == null) {
              return Center(
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: CupertinoActivityIndicator()),
              );
            } else if (snapshot.data.docs.length == 0) {
              return Container(
                height: screenHeight,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No Documents yet :(',
                      style: bigBlackText,
                    ),
                    ElevatedButton(
                        onPressed: () => locator<NavigationService>()
                            .replaceCurrentWith('landingPage', arguments: 2),
                        child: Text("Place an ad!"))
                  ],
                ),
              );
            }
            return (snapshot.connectionState == ConnectionState.waiting &&
                    (snapshot.data?.docs?.length ?? 0) == 0)
                ? Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: CupertinoActivityIndicator()),
                  )
                : CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ItemTile(
                                      user: user,
                                      fit: BoxFit.fitWidth,
                                      item: DocumentModel.fromJson(
                                          snapshot.data.docs[index].data()),
                                    ),
                                  ),
                              childCount: snapshot.data.docs.length)),
                      if (!(snapshot.connectionState == ConnectionState.done))
                        BottomLoader()
                    ],
                  );
          },
        ),
      ),
    );
  }
}
