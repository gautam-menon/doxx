import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';

import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';
import 'package:provider/provider.dart';

class ItemPage extends StatefulWidget {
  final UserModel user;
  final DocumentModel document;
  final String itemId;
  ItemPage({Key key, this.document, @required this.user, this.itemId})
      : super(key: key);

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text('Document Details'),
          elevation: 0,
          actions: [
            UserPopUpMenu(
              item: widget.document,
              isMe: widget.document.user.uid == widget.user.uid,
            )
          ],
        ),
        // see more in this category
        body: isLoading
            ? Container(
                height: screenHeight,
                width: screenWidth,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              )
            : Builder(
                builder: (BuildContext context) => SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            InkWell(
                              onTap: () => locator<NavigationService>()
                                  .navigateTo('fullscreenImage', arguments: [
                                widget.document.imageUrl,
                                null
                              ]),
                              child: Hero(
                                tag: widget.document.id,
                                child: ImageSlider(
                                    imageUrl: widget.document.imageUrl,
                                    screenHeight: screenHeight * 0.5,
                                    screenWidth: screenWidth),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: screenHeight * .06,
                                  width: screenHeight * .06,
                                  child: Consumer<
                                          DocumentSnapshot<
                                              Map<String, dynamic>>>(
                                      builder: (context, likes, child) {
                                    bool isLiked = likes?.data() == null
                                        ? false
                                        : likes
                                            .data()['itemId']
                                            .contains(widget.document.id);
                                    return CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: screenHeight * .06,
                                      child: LikeIcon(
                                          isLiked: isLiked,
                                          screenHeight: screenHeight * 1.2,
                                          item: widget.document),
                                    );
                                    //    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                        itemDetails(screenHeight, screenWidth),
                      ],
                    ),
                  ),
                ),
              ));
  }

  enableDialog(BuildContext context) async {
    bool result;
    bool isLoading = false;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
            child: StatefulBuilder(
                builder: (BuildContext context,
                        void Function(void Function()) setState) =>
                    Container(
                      height: MediaQuery.of(context).size.height * .4,
                      child: isLoading
                          ? Center(
                              child: CupertinoActivityIndicator(),
                            )
                          : result == null
                              ? Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                      ListTile(
                                        title: Text(
                                          'Enable Ad?',
                                        ),
                                        subtitle: Text(
                                          'Are you sure you want to enable this ad?',
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.grey,
                                                ),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text(
                                                  'Nope',
                                                  style: smallblacknormaltext,
                                                )),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  bool response = await locator<
                                                          FirebaseServices>()
                                                      .enableAd(
                                                          widget.document);
                                                  setState(() {
                                                    result = response;
                                                    isLoading = false;
                                                  });
                                                },
                                                child: Text(
                                                  'Yup ',
                                                  style: smallblacknormaltext,
                                                )),
                                          ],
                                        ),
                                      )
                                    ])
                              : result
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ListTile(
                                          title: Text('Ad enabled'),
                                          subtitle: Text(
                                              'Your ad has been successfully enabled.'),
                                        ),
                                        ElevatedButton(
                                            child: Text('Okay'),
                                            onPressed: () =>
                                                locator<NavigationService>()
                                                    .replaceCurrentWith(
                                                        'landingPage'))
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ListTile(
                                          title: Text('Oops'),
                                          subtitle: Text('Please try again.'),
                                        ),
                                        ElevatedButton(
                                          child: Text('Okay'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        )
                                      ],
                                    ),
                    ))));
  }

  Widget itemDetails(double screenHeight, double screenWidth) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.document.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.document.category}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('dd MMM, yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.document.dateSubmitted)),
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),
              if (widget.document.status == 'inactive') ...[
                IconButton(
                    icon: Icon(
                      Icons.done,
                      size: screenHeight * 0.05,
                      color: primaryAppColor,
                    ),
                    onPressed: () => enableDialog(context)),
                Text('Enable')
              ],
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (widget.document.description.isNotEmpty) ...[
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Description:",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                            ),
                          )),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${widget.document.description}',
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20,
                            ),
                          )),
                    ],
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Divider(
                color: Colors.black54,
              ),
              ListTile(
                title: Text(
                  "Posted by: ",
                  maxLines: 2,
                ),
                subtitle: Text(
                  "${widget.document.user.name}",
                  maxLines: 2,
                ),
                trailing: widget.document.user.uid == widget.user.uid
                    ? Container(
                        width: 0,
                        height: 0,
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.info,
                          color: primaryAppColor,
                        ),
                        onPressed: () =>
                            showUserDetails(widget.document.user, context)),
              ),
              Divider(
                color: Colors.black54,
              ),
            ],
          ))
    ]);
  }
}

class UserPopUpMenu extends StatelessWidget {
  final DocumentModel item;
  final bool isMe;
  const UserPopUpMenu({Key key, this.isMe, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Set<String> optionsMap = isMe
        ? {'Edit', 'Disable', 'View this category'}
        : {'Report Ad', 'View Profile', 'View this category'};
    return PopupMenuButton(
      icon: Icon(FontAwesomeIcons.ellipsisH),
      itemBuilder: (context) => optionsMap
          .map((e) => PopupMenuItem(child: Text(e), value: e))
          .toList(),
      onSelected: (choice) => isMe
          ? myOptions(choice, item, context)
          : userOptions(choice, item, context),
    );
  }

  userOptions(String choice, DocumentModel item, BuildContext context) {
    switch (choice) {
      case 'Report Ad':
        return locator<NavigationService>()
            .navigateTo('reportPage', arguments: item);
        break;
      case 'View Profile':
        return showUserDetails(item.user, context);
        break;
      case 'View this category':
        return locator<NavigationService>()
            .navigateTo('categoryPage', arguments: item.category);
        break;
      default:
    }
  }

  myOptions(String choice, DocumentModel item, BuildContext context) {
    switch (choice) {
      case 'Disable':
        disableDialog(context, item);
        break;
      case 'Edit':
        return locator<NavigationService>()
            .navigateTo('editItemPage', arguments: item);
        break;
      case 'View this category':
        return locator<NavigationService>()
            .navigateTo('categoryPage', arguments: item.category);
        break;
      default:
    }
  }
}
