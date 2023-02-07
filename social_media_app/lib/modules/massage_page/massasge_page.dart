import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/shared/constants.dart';

import '../../shared/componant.dart';
import '../massage_details/massage_details.dart';

class MassagePage extends StatefulWidget {
  const MassagePage({Key? key}) : super(key: key);

  @override
  State<MassagePage> createState() => _MassagePageState();
}

class _MassagePageState extends State<MassagePage> {
  List chats = [];
  Future getChats() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .get()
        .then((value) {
      for (var element in value.docs) {
        chats.add(element.id);
      }
    });
  }

  List following = [];

  getFollowing() async {
    var ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((value) async {
      following = await value.data()!['following'];
    });
    // for (var element in chats) {
    //   if (!following.contains(element)) {
    //     following.add(element);
    //   }
    // }
  }

  List followingData = [];
  bool isLoading = false;

  Future getFollowingData() async {
    setState(() {
      isLoading = true;
    });

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

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    internetConection(context);

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
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ))
            : followingData.isEmpty
                ? const Center(child: Text('No Friends'))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: following.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          navigateTo(
                              context,
                              MassageDetails(
                                userId: followingData[index]['userId'],
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
