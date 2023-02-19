import 'dart:io';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

const MaterialColor mainColor = Colors.deepPurple;

void navigateTo(context, widget) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
  );
}

void navigateToWithAnimation(context, widget, PageTransitionType type) {
  Navigator.push(
    context,
    PageTransition(
      child: widget,
      type: type,
    ),
  );
}

void navigateAndFinish(context, widget) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
    (Route<dynamic> route) => false,
  );
}

void pop(context) {
  Navigator.pop(context);
}

bool isNetworkConnection = true;

Future<void> internetConection(context) async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      isNetworkConnection = true;
      // print('good');
      // showTopSnackBar(
      //   context,
      //   CustomSnackBar.success(
      //     backgroundColor: Colors.green,
      //     message: 'Good Internt',
      //     icon: Icon(null),
      //   ),
      // );
    }
  } on SocketException catch (_) {
    isNetworkConnection = false;
    showTopSnackBar(
      context,
      const CustomSnackBar.success(
        backgroundColor: Colors.red,
        message: 'Please Check Your Internet',
        icon: Icon(null),
      ),
    );
  }
}
