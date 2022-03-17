import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dox/Models/item_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/user_model.dart';
import '../Services/Firebase/firebase_services.dart';
import '../Services/auth_service.dart';
import '../Utils/locator.dart';
import '../Utils/navigation.dart';
import '../Utils/reusable_widgets.dart';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({Key key, this.category}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.category),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: locator<FirebaseServices>()
            .getitemsByCategory(widget.category, limit),
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
                    'No items in ${widget.category.toLowerCase()} yet :(',
                    style: bigBlackText,
                  ),
                  ElevatedButton(
                      onPressed: () => locator<NavigationService>()
                          .replaceCurrentWith('landingPage', arguments: 2),
                      child: Text("Place an ad!"))
                ],
              ),
            );
          } else {
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
          }
        },
      ),
    );
  }
}
