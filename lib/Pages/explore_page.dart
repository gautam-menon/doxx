import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Helpers/constants.dart';
import '../Models/item_model.dart';
import '../Models/user_model.dart';
import '../Services/Firebase/firebase_services.dart';
import '../Services/auth_service.dart';
import '../Utils/locator.dart';
import '../Utils/reusable_widgets.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  final ScrollController scrollController = ScrollController();
  final UserModel user = locator<AuthService>().getCurrentUser();
  Future<QuerySnapshot> getData;
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => scrollController.animateTo(0,
              duration: Duration(milliseconds: 500), curve: Curves.easeOut),
          child: SizedBox(
            width: 250,
            height: 50,
            child: Center(
              child: Text(
                appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24, fontFamily: 'Roboto', color: Colors.black),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(Duration(seconds: 2));
          return null;
        },
        child: SafeArea(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TrendingItems(
                  user: user, limit: limit, scrollController: scrollController),
            ),
          ),
        ),
      ),
    );
  }
}

class TrendingItems extends StatelessWidget {
  const TrendingItems({
    Key key,
    @required this.limit,
    @required this.scrollController,
    @required this.user,
  }) : super(key: key);
  final UserModel user;
  final int limit;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: locator<FirebaseServices>().getTrending(limit),
        builder: (context, snapshot) {
          if (snapshot?.data?.docs == null) {
            return shimmerLoading(context);
          } else if (snapshot.data.docs.length == 0) {
            return Center(child: Text('No items :('));
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.7,
                        crossAxisCount: 2),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      DocumentModel item =
                          DocumentModel.fromJson(snapshot.data.docs[index].data());
                      return Hero(
                        tag: item.id,
                        child: ItemTile(
                          user: user,
                          item: item,
                        ),
                      );
                    }, childCount: snapshot.data.docs.length),
                  ),
                  if (!(snapshot.connectionState == ConnectionState.done))
                    BottomLoader()
                ],
              ),
            );
          }
        });
  }
}

int getNumberOfDms(List<QueryDocumentSnapshot<Map<String, dynamic>>> data) {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
      data?.where((element) => element.data()['read'] == true)?.toList();
  return docs?.length ?? 0;
}
