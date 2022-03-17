import 'package:dox/Pages/explore_page.dart';
import 'package:flutter/material.dart';
import 'package:dox/Helpers/constants.dart';
import 'package:dox/Pages/profile_page.dart';
import 'package:dox/Pages/search_page.dart';
import 'package:dox/Pages/submit_item.dart';

class HomePage extends StatefulWidget {
  final int index;

  const HomePage({
    Key key,
    this.index = 0,
  }) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  void initState() {
    index = widget?.index ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> pages = [ExplorePage(),
      SearchPage(),
      OrderPage(),
      ProfilePage()
    ];
    return WillPopScope(
      onWillPop: () async {
        if (index == 0) {
          return true;
        } else {
          setState(() {
            index = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: IndexedStack(
          index: index,
          children: pages,
        ),
        bottomNavigationBar: bottomNavBar(screenHeight),
      ),
    );
  }

  Container bottomNavBar(double screenHeight) {
    return Container(
      color: Colors.white,
      height: screenHeight * .08,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home,
                size: 30, color: index == 0 ? primaryAppColor : blackColor),
            onPressed: () => setState(() {
              index = 0;
            }),
          ),
          IconButton(
            icon: Icon(Icons.search,
                size: 30, color: index == 1 ? primaryAppColor : blackColor),
            onPressed: () => setState(() {
              index = 1;
            }),
          ),
          IconButton(
            onPressed: () => setState(() {
              index = 2;
            }),
            icon: Icon(Icons.add,
                size: 30, color: index == 2 ? primaryAppColor : blackColor),
          ),
          IconButton(
            onPressed: () => setState(() {
              index = 3;
            }),
            icon: Icon(Icons.person,
                size: 30, color: index == 3 ? primaryAppColor : blackColor),
          )
        ],
      ),
    );
  }
}
