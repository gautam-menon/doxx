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

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final UserModel user = locator<AuthService>().getCurrentUser();
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<String> suggestions;

  double get screenHeight => MediaQuery.of(context).size.height;
  double get screenWidth => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        searchBar(),
        Container(
          width: screenWidth,
          height: screenHeight * .07,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () => locator<NavigationService>()
                      .navigateTo('categoryPage', arguments: categories[index]),
                  child: Chip(
                    label: Text(categories[index]),
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            },
            itemCount: categories.length,
          ),
        ),
        if (searchController.text.isNotEmpty)
          if (!focusNode.hasFocus)
            Expanded(
              child: FutureBuilder<
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                  future: locator<FirebaseServices>()
                      .searchResults(searchController.text.toUpperCase()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CupertinoActivityIndicator(),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            return ItemTile(
                              user: user,
                              item: DocumentModel.fromJson(
                                  snapshot.data[index].data()),
                            );
                          }),
                    );
                  }),
            ),
      ],
    ));
  }

  Container searchBar() {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        focusNode: focusNode,
        controller: searchController,
        keyboardType: TextInputType.text,
        style: TextStyle(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          suffixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: 'search',
                backgroundColor: primaryAppColor,
                child: Icon(Icons.search, color: Colors.white),
                onPressed: () => focusNode.unfocus(),
              )),
          fillColor: Colors.white,
          hintText: "Search",
          border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(50.0),
              ),
              borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          filled: true,
        ),
      ),
    ));
  }
}
