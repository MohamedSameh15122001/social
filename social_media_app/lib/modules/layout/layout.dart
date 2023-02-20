import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/home_page.dart';
import 'package:social_media_app/modules/massage_page/massasge_page.dart';
import 'package:social_media_app/modules/notification_page/notification_page.dart';
import 'package:social_media_app/modules/personal_page/personal_page.dart';

import '../post/add_post_screen.dart';

class Layout extends StatefulWidget {
  final index;
  const Layout({Key? key, this.index}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  //nav bar

  int currentIndex = 0;
  List<Widget> bottomNav = [
    const HomePage(),
    const MassagePage(),
    const Post(),
    const NotificationPage(),
    const PersonalPage()
  ];
  @override
  void initState() {
    if (widget.index != null) {
      currentIndex = widget.index;
      widget.index == null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey[300],
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: bottomNav[currentIndex],
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: CurvedNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        index: currentIndex,
        backgroundColor: Colors.grey.shade300,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeOut,
        color: Colors.deepPurple,
        items: const [
          Icon(
            Icons.home_rounded,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.topic_sharp,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.add_rounded,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.notifications,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
