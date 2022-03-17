import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Helpers/constants.dart';
import '../Models/item_model.dart';
import '../Providers/order_provider.dart';
import '../Services/Firebase/order_services.dart';
import '../Utils/locator.dart';
import '../Utils/navigation.dart';
import '../Utils/reusable_widgets.dart';

class EditPage extends StatefulWidget {
  final DocumentModel item;

  const EditPage({Key key, this.item}) : super(key: key);
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String category;
  bool tempCanMessage;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    titleController.text = widget.item?.title ?? '';
    descriptionController.text = widget.item?.description ?? '';
    category = widget.item?.category ?? categories.first;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (BuildContext context) => OrderProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Ad',
            style: bigBlackText,
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: screenWidth,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Existing images cannot be removed.',
                            style: smallblacknormaltext,
                          )),
                      buildImages(screenWidth, screenHeight,
                          imageList: widget.item.imageUrl),
                      SizedBox(
                        height: screenHeight * .05,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Title',
                          style: smallblacknormaltext,
                        ),
                      ),
                      TextFormField(
                        validator: (val) {
                          String res;
                          if (val == '') {
                            res = 'Please provide a title';
                          } else {
                            res = val.length < 2 ? 'Title too short' : null;
                          }
                          return res;
                        },
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        controller: titleController,
                        maxLines: 2,
                        maxLength: 30,
                        decoration: InputDecoration(
                          hintMaxLines: 2,
                          fillColor: backgroundColor,
                          hintText: "Title",
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(20.0),
                              ),
                              borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 20),
                          filled: true,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * .05,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Description',
                          style: smallblacknormaltext,
                        ),
                      ),
                      TextFormField(
                        maxLines: 5,
                        maxLength: 400,
                        
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintMaxLines: 4,
                          fillColor: backgroundColor,
                          hintText: "Description",
                          border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(20.0),
                              ),
                              borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 40),
                          filled: true,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * .05,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Category',
                          style: smallblacknormaltext,
                        ),
                      ),
                      categorySelector(screenHeight),
                      SizedBox(
                        height: screenHeight * .05,
                      ),
                      submitButton(screenHeight, screenWidth)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Consumer<OrderProvider> submitButton(
      double screenHeight, double screenWidth) {
    return Consumer<OrderProvider>(
        builder: (context, value, child) => Container(
              width: screenWidth * .5,
              child: FloatingActionButton(
                  heroTag: 'submitEdit',
                  isExtended: true,
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      int price = int.tryParse(priceController.text);
                      if (titleController.text != '' ||
                          descriptionController.text != '' ||
                          price != null) {
                        
                        DocumentModel newItem = widget.item;
                        newItem
                          ..category = category.toUpperCase()
                          ..title = titleController.text.trim().toUpperCase()
                          ..description = descriptionController.text;
                        
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => Dialog(
                                  child: Container(
                                    child: FutureBuilder(
                                        future: locator<OrderServices>()
                                            .uploadEditedItem(
                                                newItem),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return LoaderWidget(
                                                text: 'Making changes',
                                                screenWidth: screenWidth,
                                                screenHeight: screenHeight);
                                          } else if (snapshot?.data ?? false) {
                                            return Container(
                                                width: screenWidth * .9,
                                                height: screenHeight * .5,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      CircleAvatar(
                                                        radius:
                                                            screenHeight * .06,
                                                        backgroundColor:
                                                            primaryAppColor,
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size:
                                                              screenHeight * .1,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Your ad was successfully edited!',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Container(
                                                        width: screenWidth * .5,
                                                        child:
                                                            FloatingActionButton(
                                                                heroTag:
                                                                    'submitEditPop',
                                                                isExtended:
                                                                    true,
                                                                child: Text(
                                                                    'Okay'),
                                                                onPressed: () {
                                                                  locator<NavigationService>()
                                                                      .goBack();
                                                                  locator<NavigationService>()
                                                                      .replaceCurrentWith(
                                                                          'userItems');
                                                                }),
                                                      )
                                                    ]));
                                          } else {
                                            return ErrorDialog(
                                                screenWidth: screenWidth,
                                                screenHeight: screenHeight,
                                                error: snapshot?.data['error']);
                                          }
                                        }),
                                  ),
                                ));
                      } else {
                        buildShowDialog(
                            context, 'Oops!', 'Please enter all details');
                      }
                    }
                  },
                  child: Text('Done')),
            ));
  }

  Container categorySelector(
    double screenHeight,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      height: screenHeight * .08,
      child: DropdownButton<String>(
          underline: Container(),
          isExpanded: true,
          value: category[0] +
              category.substring(1, category.length).toLowerCase(),
          items: categories
              .map((e) => DropdownMenuItem<String>(
                    child: Text(e),
                    value: e,
                  ))
              .toList(),
          onChanged: (cat) {
            setState(() {
              category = cat;
            });
          }),
    );
  }

  buildImages(double screenWidth, double screenHeight,
      {List<dynamic> imageList}) {
    return Container(
      height: screenHeight * .18,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: screenWidth * 0.3,
              width: screenWidth * 0.3,
              color: backgroundColor,
              child: imageList[index] != null
                  ? CachedNetworkImage(imageUrl: imageList[index])
                  : Center(
                      child: Icon(Icons.add),
                    ),
            ),
          ),
        ),
        itemCount: imageList.length,
      ),
    );
  }
}
