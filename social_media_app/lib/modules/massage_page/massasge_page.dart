import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../massage_details/massage_details.dart';

class MassagePage extends StatefulWidget {
  const MassagePage({Key? key}) : super(key: key);

  @override
  State<MassagePage> createState() => _MassagePageState();
}

class _MassagePageState extends State<MassagePage> {
  late List following;

  getFollowing() async {
    var ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      following = await value.data()!['following'];
      print(following);
      print('=========================');
    });
  }

  List followingData = [];

  Future getFollowingData() async {
    await getFollowing();
    followingData = [];
    for (var i = 0; i < following.length; i++) {
      var ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(following[i])
          .get()
          .then((value) {
        followingData.add(value.data());
      });
    }
    print(followingData);
    print('[[[[[[[[[[[[[[[[[[[followingData]]]]]]]]]]]]]]]]]]]');
    setState(() {});
  }

  @override
  void initState() {
    getFollowingData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          elevation: 0,
          title: const Text(
            'Inbox',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: followingData.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ))
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: following.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return MassageDetails(
                            userId: followingData[index]['userId'],
                          );
                        },
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 25.0,
                        right: 25.0,
                        top: 20,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1,
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              radius: 34,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    followingData[index]['personalImage']),
                                radius: 30,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  followingData[index]['userName'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                const Text(
                                  'Shall we meet today?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              children: const [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  '5 : 45 PM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ));
  }
}