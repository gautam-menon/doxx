import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';

import 'package:dox/Services/Firebase/chat_services.dart';
import 'package:dox/Services/Firebase/firebase_services.dart';

import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';
import 'package:provider/provider.dart';

class ItemPage extends StatefulWidget {
  final UserModel user;
  final DocumentModel item;
  final String itemId;
  ItemPage({Key key, this.item, @required this.user, this.itemId})
      : super(key: key);

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text('Ad Details'),
          elevation: 0,
          actions: [
            UserPopUpMenu(
              item: widget.item,
              isMe: widget.item.user.uid == widget.user.uid,
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
                                  .navigateTo('fullscreenImage',
                                      arguments: [widget.item.imageUrl, null]),
                              child: Hero(
                                tag: widget.item.id,
                                child: ImageSlider(
                                    imageUrl: widget.item.imageUrl,
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
                                            .contains(widget.item.id);
                                    return CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: screenHeight * .06,
                                      child: LikeIcon(
                                          isLiked: isLiked,
                                          screenHeight: screenHeight * 1.2,
                                          item: widget.item),
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
                                                      .enableAd(widget.item);
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
                widget.item.title,
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
                    '${widget.item.category}',
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
                          widget.item.dateSubmitted)),
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),
              widget.item.status == 'inactive'
                  ? Column(
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.done,
                              size: screenHeight * 0.05,
                              color: primaryAppColor,
                            ),
                            onPressed: () => enableDialog(context)),
                        Text('Enable')
                      ],
                    )
                  : Column(children: [
                      ElevatedButton(
                          onPressed: () =>
                              bookingsWidget(screenHeight, screenWidth),
                          child: Text('View bookings'))
                    ]),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream:
                      locator<FirebaseServices>().getBookings(widget.item.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CupertinoActivityIndicator();
                    }
                    Map<String, dynamic> data = snapshot.data.data();
                    bool isBooked =
                        data != null ? data[widget.user.uid] != null : false;
                    int count = snapshot?.data?.data()?.length ?? 0;
                    return Row(
                      children: [
                        Text(
                            (count == 0
                                ? 'Be the first one to book!'
                                : count == 1
                                    ? '$count booking'
                                    : '$count bookings'),
                            style: TextStyle(
                                color: primaryAppColor, fontSize: 15)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: Icon(
                                    isBooked
                                        ? FontAwesomeIcons.solidBookmark
                                        : FontAwesomeIcons.bookmark,
                                    size: screenHeight * 0.05,
                                    color: primaryAppColor),
                                onPressed: () => bookDialog(
                                    isBooked, screenHeight, screenWidth)),
                            Text(isBooked ? 'Unbook' : 'Book'),
                          ],
                        ),
                      ],
                    );
                  }),
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
                          '${widget.item.description}',
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                          ),
                        )),
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
                  "${widget.item.user.name}",
                  maxLines: 2,
                ),
                trailing: widget.item.user.uid == widget.user.uid
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
                            showUserDetails(widget.item.user, context)),
              ),
              Divider(
                color: Colors.black54,
              ),
            ],
          ))
    ]);
  }

  Future bookingsWidget(double screenHeight, double screenWidth) {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        context: context,
        builder: (context) => Container(
            height: screenHeight * .7,
            width: screenWidth,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: primaryAppColor,
                    ),
                    onPressed: () => Navigator.of(context).pop()),
              ),
              Text('Bookings',
                  style: TextStyle(color: Colors.black54, fontSize: 26)),
              Divider(
                color: Colors.black54,
              ),
              Expanded(
                child: StreamBuilder(
                    stream:
                        locator<FirebaseServices>().getBookings(widget.item.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CupertinoActivityIndicator());
                      }
                      if (snapshot.data.data() == null) {
                        return Center(child: Text('No bookings yet 0.0'));
                      }
                      List values = snapshot.data?.data()?.values?.toList();
                      return ListView.builder(
                          itemCount: values.length,
                          itemBuilder: (context, index) {
                            UserModel user = UserModel.fromJson(values[index]);
                            return ListTile(
                              leading: user.photoURL == null
                                  ? CircleAvatar(child: Icon(Icons.person))
                                  : SizedBox(
                                      height: screenHeight * .05,
                                      child: CachedNetworkImage(
                                        imageUrl: user.photoURL,
                                        progressIndicatorBuilder:
                                            (context, url, progress) =>
                                                ImageLoader(
                                          screenWidth: screenWidth,
                                          progress: progress,
                                        ),
                                        imageBuilder: (context, image) =>
                                            CircleAvatar(
                                          backgroundImage: image,
                                        ),
                                      ),
                                    ),
                              title: Text(user.name),
                              trailing: IconButton(
                                  icon: Icon(FontAwesomeIcons.envelope,
                                      size: screenHeight * 0.05,
                                      color: primaryAppColor),
                                  onPressed: () async {
                                    setState(() {
                                      Navigator.of(context).pop();
                                      isLoading = true;
                                    });
                                    bool response =
                                        await locator<ChatServices>().setChatId(
                                            widget.user,
                                            widget.item.user,
                                            widget.item);

                                    if (response) {
                                      locator<NavigationService>()
                                          .navigateTo('chatPage', arguments: [
                                        user.uid + widget.user.uid,
                                        widget.item,
                                        widget.item.user
                                      ]);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            'Error opening chat, please check your internet connection ;)'),
                                      ));
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }),
                            );
                          });
                    }),
              )
            ])));
  }

  Future bookDialog(bool isBooked, double screenHeight, double screenWidth) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
              child: Container(
                child: FutureBuilder(
                    future: isBooked
                        ? locator<FirebaseServices>()
                            .unBookItem(widget.item, widget.user)
                        : locator<FirebaseServices>()
                            .bookItem(widget.item, widget.user.name),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoaderWidget(
                            text: isBooked ? 'UnBooking item' : 'Booking item',
                            screenWidth: screenWidth,
                            screenHeight: screenHeight);
                      } else if (snapshot?.data ?? false) {
                        return SuccessDialog(
                          title: 'Success!',
                          subtitle: isBooked
                              ? '${widget.item.title}\n successfully unbooked!'
                              : '${widget.item.title}\n successfully booked!',
                          function: () {
                            Navigator.of(context).pop();
                          },
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        );
                      } else {
                        return ErrorDialog(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            error: snapshot?.data['error']);
                      }
                    }),
              ),
            ));
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
