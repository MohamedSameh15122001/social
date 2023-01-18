import 'package:flutter/material.dart';

import 'package:social_media_app/shared/constants.dart';

class MyPageView extends StatelessWidget {
  const MyPageView({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: mainColor[400],
            child: child,
          ),
        ),
      ),
    );
  }
}
