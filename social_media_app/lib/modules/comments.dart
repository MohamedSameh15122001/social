// var test =
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser?.uid)
//         .get();

// void printWrapped(String text) {
//     final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
//     pattern.allMatches(text).forEach((match) => print(match.group(0)));
//   }

// Map<String, dynamic>? allData = {};

// QueryDocumentSnapshot<Map<String, dynamic>> realData;

            // data!.map((e) => model = UserModel.fromMap(e.data()));
            // print(model!.age);
            // print('======================================');






//[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[
    //works when press on the notification when app in terminated(fully closed)
    // FirebaseMessaging.instance.getInitialMessage().then((value) {
    //   navigateTo(context, const NotificationPage());
    // });

    // //works when press on the notification when app in background
    // FirebaseMessaging.onMessageOpenedApp.listen((event) {
    //   navigateTo(context, const NotificationPage());
    // });

    // //works when the app in background or terminated(fully closed)
    // FirebaseMessaging.onBackgroundMessage((message) async {});

    // //to get the notification when app in forground (in use)
    // FirebaseMessaging.onMessage.listen((event) {
    //   print('${event.notification}');
    //   print('${event.senderId}');
    //   print('${event.data}');
    //   print('${event.notification}');
    //   print('${event.notification!.title}');
    //   print('${event.notification!.body}');
    //   print('\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\');
    //   navigateTo(context, const NotificationPage());
    // });

    // //to get the token to send notification from the firebase website
    // FirebaseMessaging.instance.getToken().then((value) {
    //   print(value);
    //   print('\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\');
    // });
    
//]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]