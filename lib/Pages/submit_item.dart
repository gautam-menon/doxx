import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Models/item_model.dart';
import 'package:dox/Models/user_model.dart';
import 'package:dox/Providers/order_provider.dart';
import 'package:dox/Services/auth_service.dart';
import 'package:dox/Utils/locator.dart';
import 'package:dox/Utils/navigation.dart';
import 'package:dox/Utils/reusable_widgets.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String category = categories.first;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (BuildContext context) => OrderProvider(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Upload A Document',
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
                      Text(
                        'Add atleast 1 document file. Long press to delete.',
                        style: smallblacknormaltext,
                      ),
                      BuildImages(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(
                        height: screenHeight * .05,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Add a title for the document',
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
                          'Add a description for the document (Optional)',
                          style: smallblacknormaltext,
                        ),
                      ),
                      TextFormField(
                        maxLines: 5,
                        maxLength: 400,
                        validator: (val) =>
                            val == '' ? 'Please provide a description' : null,
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
                          'Select a category for your item',
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
                  heroTag: 'submitButton',
                  isExtended: true,
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      if (titleController.text.isNotEmpty) {
                        if (value.images.length >= 1) {
                         final UserModel user =
                              locator<AuthService>().getCurrentUser();
                         final DocumentModel item = DocumentModel();
                          item
                            ..category = category.toUpperCase()
                            ..title = titleController.text.trim().toUpperCase()
                            ..dateSubmitted =
                                DateTime.now().millisecondsSinceEpoch
                            ..user = user
                            ..tempImages = value.images
                            ..description = descriptionController.text;
                          locator<NavigationService>()
                              .navigateTo('reviewPage', arguments: item);
                        } else {
                          buildShowDialog(
                              context, 'Oops!', 'Please add an image');
                        }
                      } else {
                        buildShowDialog(
                            context, 'Oops!', 'Please enter all details');
                      }
                    }
                  },
                  child: Text('Review')),
            ));
  }

  Container categorySelector(double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      // width: screenWidth,
      height: screenHeight * .08,
      child: DropdownButton<String>(
          underline: Container(),
          isExpanded: true,
          value: category,
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
}

class BuildImages extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  const BuildImages({
    Key key,
    this.screenHeight,
    this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
        builder: (BuildContext context, value, Widget child) => Container(
              height: screenHeight * .18,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => InkWell(
                  onTap: () => value.pickImage(index),
                  onLongPress: () {
                    if (value.images.length > index) {
                      value.removeImage(index);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: screenWidth * 0.3,
                      width: screenWidth * 0.3,
                      color: backgroundColor,
                      child: value.images.length >= index + 1
                          ? Image.file(value.images[index])
                          : Center(
                              child: Icon(Icons.add),
                            ),
                    ),
                  ),
                ),
                itemCount: 3,
              ),
            ));
  }
}
