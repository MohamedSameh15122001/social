import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/modules/settings_page/settings_page.dart';
import 'package:social_media_app/shared/constants.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({Key? key}) : super(key: key);

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  List myPosts = [];
  getMyPosts() async {
    myPosts = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('posts')
        .get()
        .then((value) {
      for (var element in value.docs) {
        myPosts.add(element.data());
      }
    });
    setState(() {});
    // print(myPosts);
    // print(myPosts.length);
    // print(']]]]]]]]]]]]]]]]]]]]]]]]]]]');
  }

  @override
  void initState() {
    getMyPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(
              'userId',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
            )
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                snapshot.data?.docs;

            QueryDocumentSnapshot<Map<String, dynamic>>? datadata;

            for (var i = 0; i < data!.length; i++) {
              datadata = data[i];
            }

            return Column(
              children: [
                //First section about information
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 10,
                          blurRadius: 12,
                        )
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(40),
                        left: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
                      child: Stack(
                        children: [
                          Align(
                            alignment: const Alignment(.8, -.9),
                            child: IconButton(
                              onPressed: () {
                                navigateTo(context, const SettingsPage());
                              },
                              icon: const Icon(Icons.settings_rounded),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 60.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                //image
                                CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  radius: 64,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        '${datadata?['personalImage']}'),
                                    radius: 60,
                                  ),
                                ),

                                //name
                                Text(
                                  '${datadata?['userName']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                ),
                                //bio
                                Text(
                                  '${datadata?['bio']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //post
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {});
                                          },
                                          child: Text(
                                            '${myPosts.length}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Post',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    //followers
                                    Column(
                                      children: [
                                        Text(
                                          '${datadata?.data()['followers'].length}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    //following
                                    Column(
                                      children: [
                                        Text(
                                          '${datadata?.data()['following'].length}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          'Following',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //second section
                myPosts.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text('no posts'),
                        ),
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: myPosts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemBuilder: (context, index) {
                              // print(datadata?.data()['posts'][0]['postImage']);
                              // print(index.toString());
                              // print('===================================');
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: myPosts[index]['postImage'] == ''
                                      ? Center(
                                          child: Text(myPosts[index]
                                              ['postDescription']))
                                      : Image.network(
                                          '${myPosts[index]['postImage']}',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            );
          }
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ));
        },
      ),
    );
  }
}
