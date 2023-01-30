import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/modules/post/post_page.dart';
import 'package:social_media_app/modules/settings_page/settings_page.dart';
import 'package:social_media_app/shared/constants.dart';

import '../../shared/componant.dart';

class PersonalPage extends StatefulWidget {
  final userId;

  const PersonalPage({Key? key, this.userId}) : super(key: key);

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  List myPosts = [];
  List documentId = [];
  getMyPosts() async {
    myPosts = [];
    documentId = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId ?? currentUserId)
        .collection('posts')
        .get()
        .then((value) {
      for (var element in value.docs) {
        myPosts.add(element.data());
        documentId.add(element.id);
      }
    });
    setState(() {});
  }

  var myFollowing = [];
  getMyFollowing() async {
    setState(() {
      isLoading = true;
    });
    var ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((value) async {
      myFollowing = await value.data()!['following'];
    });
    setState(() {
      isLoading = false;
    });
  }

  var following = [];
  bool isLoading = false;
  getFollowing() async {
    setState(() {
      isLoading = true;
    });
    var ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId ?? currentUserId)
        .get()
        .then((value) async {
      following = await value.data()!['following'];
    });
    setState(() {
      isLoading = false;
    });
  }

  List allFollowingData = [];

  Future getAllFollowingData() async {
    await getFollowing();
    allFollowingData = [];

    for (var i = 0; i < following.length; i++) {
      var ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(following[i])
          .get()
          .then((value) {
        allFollowingData.add(value.data());
      }).catchError((e) {});
    }
    // print(allData[0]['userName']);
  }

  int changeView = 0;

  var myFollowers = [];
  getMyFollowers() async {
    setState(() {
      isLoading = true;
    });
    var ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((value) async {
      myFollowers = await value.data()!['followers'];
    });
    setState(() {
      isLoading = false;
    });
  }

  var followers = [];

  getFollowers() async {
    setState(() {
      isLoading = true;
    });
    var ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId ?? currentUserId)
        .get()
        .then((value) async {
      followers = await value.data()!['followers'];
    });
    setState(() {
      isLoading = false;
    });
  }

  List allFollowersData = [];

  Future getAllFollowersData() async {
    await getFollowers();
    allFollowersData = [];

    for (var i = 0; i < followers.length; i++) {
      var ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(followers[i])
          .get()
          .then((value) {
        allFollowersData.add(value.data());
      }).catchError((e) {});
    }
    // print(allData[0]['userName']);
  }

  @override
  void initState() {
    internetConection(context);
    getFollowing();
    getMyPosts();
    getMyFollowing();
    getAllFollowingData();
    getFollowers();
    getMyFollowers();
    getAllFollowersData();

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
              isEqualTo: widget.userId ?? currentUserId,
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
                          widget.userId == null
                              ? Align(
                                  alignment: const Alignment(.8, -.9),
                                  child: IconButton(
                                    onPressed: () {
                                      navigateTo(context, const SettingsPage());
                                    },
                                    icon: const Icon(Icons.settings_rounded),
                                  ),
                                )
                              : Container(),
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
                                widget.userId != null
                                    ? GestureDetector(
                                        onTap: () async {
                                          getMyFollowing();
                                          if (myFollowing
                                              .contains(widget.userId)) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUserId)
                                                .update({
                                              'following':
                                                  FieldValue.arrayRemove(
                                                      ["${widget.userId}"])
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(widget.userId)
                                                .update({
                                              'followers':
                                                  FieldValue.arrayRemove(
                                                      [(currentUserId)])
                                            });
                                          } else {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUserId)
                                                .update({
                                              'following':
                                                  FieldValue.arrayUnion(
                                                      ["${widget.userId}"])
                                              // [
                                              //   data[index].data()['userId']
                                              // ]
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(widget.userId)
                                                .update({
                                              'followers':
                                                  FieldValue.arrayUnion(
                                                      [(currentUserId)])
                                              // [
                                              //   data[index].data()['userId']
                                              // ]
                                            });
                                          }

                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              myFollowing
                                                      .contains(widget.userId)
                                                  ? 'Following'
                                                  : 'follow',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //post
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          changeView = 0;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            '${myPosts.length}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
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
                                    ),
                                    //followers
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          changeView = 1;
                                        });
                                      },
                                      child: Column(
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
                                    ),
                                    //following
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          changeView = 2;
                                        });
                                      },
                                      child: Column(
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
                isLoading
                    ? const Expanded(
                        child: Center(
                            child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      )))
                    :
                    //second section
                    changeView == 0
                        ? myPosts.isEmpty
                            ? const Expanded(
                                child: Center(
                                  child: Text('no posts'),
                                ),
                              )
                            : Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
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
                                      return GestureDetector(
                                        onTap: () {
                                          navigateTo(
                                              context,
                                              PostPage(
                                                postData: myPosts[index],
                                                postDocumentId:
                                                    documentId[index],
                                              ));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: myPosts[index]
                                                        ['postImage'] ==
                                                    ''
                                                ? Center(
                                                    child: Text(myPosts[index]
                                                        ['postDescription']))
                                                : Image.network(
                                                    '${myPosts[index]['postImage']}',
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                        : changeView == 1
                            ? followers.isEmpty
                                ? const Expanded(
                                    child: Center(
                                      child: Text('no followers'),
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                      // shrinkWrap: true,
                                      // physics: const NeverScrollableScrollPhysics(),
                                      itemCount: followers.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            left: 25.0,
                                            right: 25.0,
                                            top: 20,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                                GestureDetector(
                                                  onTap: () {
                                                    navigateTo(
                                                        context,
                                                        PersonalPage(
                                                          userId:
                                                              allFollowersData[
                                                                      index]
                                                                  ['userId'],
                                                        ));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            Colors.deepPurple,
                                                        radius: 34,
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  allFollowersData[
                                                                          index]
                                                                      [
                                                                      'personalImage']),
                                                          radius: 30,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 6,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            allFollowersData[
                                                                    index]
                                                                ['userName'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .deepPurple,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Text(
                                                            allFollowersData[
                                                                index]['bio'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                //confirm edit
                                                currentUserId ==
                                                        allFollowersData[index]
                                                            ['userId']
                                                    ? const Text('Me')
                                                    : GestureDetector(
                                                        onTap: () async {
                                                          getMyFollowing();
                                                          if (myFollowing.contains(
                                                              allFollowersData[
                                                                      index]
                                                                  ['userId'])) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(
                                                                    currentUserId)
                                                                .update({
                                                              'following':
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                "${allFollowersData[index]['userId']}"
                                                              ])
                                                            });
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(allFollowersData[
                                                                        index]
                                                                    ['userId'])
                                                                .update({
                                                              'followers':
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                (currentUserId)
                                                              ])
                                                            });
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(
                                                                    currentUserId)
                                                                .update({
                                                              'following':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                "${allFollowersData[index]['userId']}"
                                                              ])
                                                              // [
                                                              //   data[index].data()['userId']
                                                              // ]
                                                            });
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(allFollowersData[
                                                                        index]
                                                                    ['userId'])
                                                                .update({
                                                              'followers':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                (currentUserId)
                                                              ])
                                                              // [
                                                              //   data[index].data()['userId']
                                                              // ]
                                                            });
                                                          }

                                                          setState(() {});
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .deepPurple,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              myFollowing.contains(
                                                                      allFollowersData[
                                                                              index]
                                                                          [
                                                                          'userId'])
                                                                  ? 'Following'
                                                                  : 'follow',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                            : following.isEmpty
                                ? const Expanded(
                                    child: Center(
                                      child: Text('no following'),
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                      // shrinkWrap: true,
                                      // physics: const NeverScrollableScrollPhysics(),
                                      itemCount: following.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            left: 25.0,
                                            right: 25.0,
                                            top: 20,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                                GestureDetector(
                                                  onTap: () {
                                                    navigateTo(
                                                        context,
                                                        PersonalPage(
                                                          userId:
                                                              allFollowingData[
                                                                      index]
                                                                  ['userId'],
                                                        ));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            Colors.deepPurple,
                                                        radius: 34,
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  allFollowingData[
                                                                          index]
                                                                      [
                                                                      'personalImage']),
                                                          radius: 30,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 6,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            allFollowingData[
                                                                    index]
                                                                ['userName'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .deepPurple,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Text(
                                                            allFollowingData[
                                                                index]['bio'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                currentUserId ==
                                                        allFollowingData[index]
                                                            ['userId']
                                                    ? const Text('Me')
                                                    :
                                                    //confirm edit
                                                    GestureDetector(
                                                        onTap: () async {
                                                          getMyFollowing();
                                                          if (myFollowing.contains(
                                                              allFollowingData[
                                                                      index]
                                                                  ['userId'])) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(
                                                                    currentUserId)
                                                                .update({
                                                              'following':
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                "${allFollowingData[index]['userId']}"
                                                              ])
                                                            });
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(allFollowingData[
                                                                        index]
                                                                    ['userId'])
                                                                .update({
                                                              'followers':
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                (currentUserId)
                                                              ])
                                                            });
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(
                                                                    currentUserId)
                                                                .update({
                                                              'following':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                "${allFollowingData[index]['userId']}"
                                                              ])
                                                              // [
                                                              //   data[index].data()['userId']
                                                              // ]
                                                            });
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(allFollowingData[
                                                                        index]
                                                                    ['userId'])
                                                                .update({
                                                              'followers':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                (currentUserId)
                                                              ])
                                                              // [
                                                              //   data[index].data()['userId']
                                                              // ]
                                                            });
                                                          }

                                                          setState(() {});
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .deepPurple,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              myFollowing.contains(
                                                                      allFollowingData[
                                                                              index]
                                                                          [
                                                                          'userId'])
                                                                  ? 'Following'
                                                                  : 'follow',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
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
