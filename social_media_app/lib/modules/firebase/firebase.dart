import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/modules/get_data/get_user_data.dart';

class FireBase extends StatefulWidget {
  const FireBase({Key? key}) : super(key: key);

  @override
  State<FireBase> createState() => _FireBaseState();
}

class _FireBaseState extends State<FireBase> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.deepPurple,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    final user = FirebaseAuth.instance.currentUser;

    //document IDs
    List<String> docIDs = [];

    //get docIDs
    Future getDocID() async {
      await FirebaseFirestore.instance
          .collection('users')
          .orderBy('age', descending: true)
          .get()
          // ignore: avoid_function_literals_in_foreach_calls
          .then((snapshot) => snapshot.docs.forEach((document) {
                // print(document.reference);
                docIDs.add(document.reference.id);
              }));
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(
          user!.email!,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 25.0),
              child: Icon(Icons.logout_rounded),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FutureBuilder(
                  future: getDocID(),
                  builder: (context, index) {
                    return ListView.builder(
                        itemCount: docIDs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: GetUserData(documentId: docIDs[index]),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
