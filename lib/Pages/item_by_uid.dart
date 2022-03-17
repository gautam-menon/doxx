import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';
import 'package:dox/Services/auth_service.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/reusable_widgets.dart';

class ItemsByUid extends StatefulWidget {
  final UserModel userModel;

  const ItemsByUid({Key key, this.userModel}) : super(key: key);

  @override
  _ItemsByUidState createState() => _ItemsByUidState();
}

class _ItemsByUidState extends State<ItemsByUid> {
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Ads by ${widget.userModel.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: locator<FirebaseServices>()
            .getItemsByUid(widget.userModel.uid, limit),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              (snapshot.data?.docs?.length ?? 0) == 0) {
            Center(
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: CupertinoActivityIndicator()),
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
    );
  }
}
