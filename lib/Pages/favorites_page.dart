import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';
import 'package:dox/Services/auth_service.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int limit = 4;
  final ScrollController scrollController = ScrollController();
  final UserModel user = locator<AuthService>().getCurrentUser();
  scrollListener() {
    if (scrollController.offset >=
            (scrollController.position.maxScrollExtent - 10) &&
        !scrollController.position.outOfRange) {
      setState(() {
        limit += 2;
      });
    }
  }

  @override
  void initState() {
    scrollController.addListener(() => scrollListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        elevation: 0,
      ),
      body: Container(child: Consumer<DocumentSnapshot<Map<String, dynamic>>>(
          builder: (context, likes, child) {
        return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
          future: locator<FirebaseServices>().getFavorites(limit, likes.data()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                limit == 4) {
              return Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasError) {
              Center(
                  child: Text(
                'Something went wrong.',
                style: bigBlackText,
              ));
            } else if (snapshot.data.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No favorites yet :(',
                      style: bigBlackText,
                    ),
                    ElevatedButton(
                      child: Text(
                        'Checkout your documents!',
                      ),
                      onPressed: () => locator<NavigationService>()
                          .replaceCurrentWith('landingPage', arguments: 0),
                    ),
                  ],
                ),
              );
            } else {
              return (snapshot.connectionState == ConnectionState.waiting &&
                      (snapshot.data?.length ?? 0) == 0)
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
                                            snapshot.data[index].data()),
                                      ),
                                    ),
                                childCount: snapshot.data.length)),
                        if (!(snapshot.connectionState == ConnectionState.done))
                          BottomLoader()
                      ],
                    );
            }
            return Container();
          },
        );
      })),
    );
  }
}
