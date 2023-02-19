import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/comment/comment.dart';
import 'package:social_media_app/modules/personal_page/personal_page.dart';
import 'package:social_media_app/modules/post/post_page.dart';
import 'package:social_media_app/modules/search/search_page.dart';
import 'package:social_media_app/modules/story/add_story.dart';
import 'package:social_media_app/modules/story/story_viewer.dart';
import 'package:social_media_app/shared/componant.dart';
import 'package:social_media_app/shared/constants.dart';
import 'package:video_viewer/video_viewer.dart';

import 'modules/like/like.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List allStories = [];
  List documenStorytId = [];
  bool isStoryLoading = false;

  Future getAllStoriesData() async {
    setState(() {
      isStoryLoading = true;
    });

    await getFollowing();
    allStories = [];
    documenStorytId = [];
    for (var i = 0; i < following.length; i++) {
      var ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(following[i])
          .collection('stories')
          .get()
          .then((value) async {
        allStories.add([]);
        documenStorytId.add([]);
        for (var element in value.docs) {
          if (!element
              .data()['date']
              .toDate()
              .add(const Duration(days: 1))
              .isAfter(DateTime.now())) {
            if (element.data()['storyImagePath'].isNotEmpty) {
              await FirebaseStorage.instance
                  .ref('images/${element.data()['storyImagePath']}')
                  .delete();
            }
            await FirebaseFirestore.instance
                .collection('users')
                .doc(following[i])
                .collection('stories')
                .doc(element.id)
                .delete();
          }
          documenStorytId[i].add(element.id);
          allStories[i].add(element.data());
        }
      }).catchError((e) {});
    }
    print(documenStorytId);
    for (var i = 0; i < documenStorytId.length; i++) {
      print(i);
      if (documenStorytId[i].isEmpty) {
        documenStorytId.removeAt(i);
      }
    }
    print(documenStorytId);
    print('[[[[[[[[[[[[[[[[[[[[object]]]]]]]]]]]]]]]]]]]]');
    for (var i = 0; i < allStories.length; i++) {
      if (allStories[i].isEmpty) {
        allStories.removeAt(i);
      }
    }
    setState(() {
      isStoryLoading = false;
    });
  }

  var commentCont = TextEditingController();
  VideoViewerController videoViewerController = VideoViewerController();

  late List following;
  getFollowing() async {
    try {
      var ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get()
          .then((value) async {
        following = await value.data()!['following'];
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.deepPurple[200],
              content: Text(
                e.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          });
    }
  }

  List allData = [];
  List documentId = [];
  bool isLoading = false;
  Future getAllData() async {
    if (allData.isEmpty) {
      setState(() {
        isLoading = true;
      });
    }

    await getFollowing();
    allData = [];
    documentId = [];
    for (var i = 0; i < following.length; i++) {
      var ref = await FirebaseFirestore.instance
          .collection('users')
          .doc(following[i])
          .collection('posts')
          .get()
          .then((value) {
        allData.add([]);
        documentId.add([]);
        for (var element in value.docs) {
          allData[i].add(element.data());
          documentId[i].add(element.id);
        }
      }).catchError((e) {});
    }

    setState(() {
      isLoading = false;
    });
  }

  getdata() => FirebaseFirestore.instance
      .collection('users')
      .where(
        'userId',
        isEqualTo: currentUserId,
      )
      .get();

  model(List<QueryDocumentSnapshot<Map<String, dynamic>>>? data) {
    QueryDocumentSnapshot<Map<String, dynamic>>? datadata;
    UserModel? model;
    for (var i = 0; i < data!.length; i++) {
      datadata = data[i];
      model = UserModel.fromMap(datadata.data());
    }
    return model;
  }

  like(postIndex, documentId, index) async {
    if (postIndex['likes'].contains(currentUserId)) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(postIndex['userId'])
          .collection('posts')
          .doc(documentId[index])
          .update({
        'likes': FieldValue.arrayRemove([(currentUserId)])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(postIndex['userId'])
          .collection('posts')
          .doc(documentId[index])
          .update({
        'likes': FieldValue.arrayUnion([
          currentUserId,
        ]),
      });
    }
    await getAllData();
  }

  @override
  void initState() {
    internetConection(context);
    getAllStoriesData();
    // sendNotify(
    //     title: 'first',
    //     body: 'imports',
    //     postId: 'ads',
    //     userId: 'asfd',
    //     token: 'asf',
    //     postData: 'asd');
    //works when press on the notification when app in terminated(fully closed)
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value!.data['postId'].isEmpty) {
        navigateTo(
            context,
            PersonalPage(
              userId: value.data['userId'],
            ));
      } else {
        navigateTo(
          context,
          PostPage(
            postData: value.data['postData'],
            postDocumentId: value.data['postId'],
          ),
        );
      }
    });
    //works when press on the notification when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((value) {
      if (value.data['postId'].isEmpty) {
        navigateTo(
            context,
            PersonalPage(
              userId: value.data['userId'],
            ));
      } else {
        navigateTo(
          context,
          PostPage(
            postData: value.data['postData'],
            postDocumentId: value.data['postId'],
          ),
        );
      }
    });
    //to get the notification when app in forground (in use)
    FirebaseMessaging.onMessage.listen((event) {
      navigateTo(
        context,
        PostPage(
          postDocumentId: event.data['postId'],
          postData: event.data['postData'],
        ),
      );
      // print('[]]]]]]]]]]]]]]]]]]]]');
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.deepPurple[200],
              content: Text(
                event.notification!.body.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          });
    });
    getAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: appBar(),
      body: FutureBuilder(
        future: getdata(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                snapshot.data?.docs;
            QueryDocumentSnapshot<Map<String, dynamic>>? datadata;

            for (var i = 0; i < data!.length; i++) {
              datadata = data[i];
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  stories(),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 25.0,
                      right: 25.0,
                      bottom: 20,
                    ),
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                            color: Colors.deepPurple[300],
                          ))
                        : (allData.isEmpty)
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height * .5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Center(child: Text('NO POSTS!')),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: following.length,
                                itemBuilder: (context, userFollowingIndex) {
                                  return ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          allData[userFollowingIndex].length,
                                      itemBuilder: (context, postIndex) {
                                        var post = allData[userFollowingIndex]
                                            [postIndex];

                                        DateTime firstDate =
                                            post['postDate'].toDate();
                                        var format = DateFormat.yMMMMd()
                                            .format(firstDate);

                                        DateTime afterWeekFromFirstDate =
                                            firstDate
                                                .add(const Duration(days: 7));

                                        if (!afterWeekFromFirstDate
                                            .isAfter(DateTime.now())) {
                                          return Container();
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                  )
                                                ],
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      navigateTo(
                                                          context,
                                                          PersonalPage(
                                                            userId:
                                                                post['userId'],
                                                          ));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  '${post!['personalImage']}'),
                                                          radius: 24,
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '${post!['userName']}',
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              format,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontSize: 9,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const Spacer(),
                                                        const Icon(
                                                            Icons.list_rounded)
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                      '${post['postDescription']}'),
                                                  const SizedBox(height: 10),
                                                  post['postImagePath']
                                                          .endsWith('.mp4')
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          child: VideoViewer(
                                                              style:
                                                                  VideoViewerStyle(
                                                                      loading:
                                                                          const CircularProgressIndicator(
                                                                color: Colors
                                                                    .deepPurple,
                                                              )),
                                                              controller:
                                                                  VideoViewerController(),
                                                              source: {
                                                                "SubRip Text":
                                                                    VideoSource(
                                                                  video: VideoPlayerController
                                                                      .network(post[
                                                                          'postImage']),
                                                                )
                                                              }),
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(18),
                                                          child:
                                                              post['postImage'] !=
                                                                      ''
                                                                  ? SizedBox(
                                                                      // height: 500,
                                                                      // width:
                                                                      //     double.infinity,
                                                                      child:
                                                                          InstaImageViewer(
                                                                        child: Image.network(
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            '${post['postImage']}'),
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                        ),
                                                  const SizedBox(height: 20),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 14.0),
                                                    child: Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await like(
                                                                post,
                                                                documentId[
                                                                    userFollowingIndex],
                                                                postIndex);
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(post[
                                                                    'userId'])
                                                                .collection(
                                                                    'notifications')
                                                                .add({
                                                              'title': datadata![
                                                                  'userName'],
                                                              'body':
                                                                  'react in your post',
                                                              'notificationDate':
                                                                  DateTime
                                                                      .now(),
                                                              'personalImage':
                                                                  datadata[
                                                                      'personalImage'],
                                                              'postId': documentId[
                                                                      userFollowingIndex]
                                                                  [postIndex],
                                                              'userId':
                                                                  datadata[
                                                                      'userId'],
                                                              'userName':
                                                                  datadata[
                                                                      'userName'],
                                                              'postData': post,
                                                            });

                                                            await sendNotify(
                                                              title: datadata[
                                                                  'userName'],
                                                              body:
                                                                  'react in your post',
                                                              postId: documentId[
                                                                      userFollowingIndex]
                                                                  [postIndex],
                                                              postData: post,
                                                              userId: datadata[
                                                                  'userId'],
                                                              token: post[
                                                                  'tokenNotification'],
                                                            );
                                                          },
                                                          child: Icon(
                                                            Icons.favorite,
                                                            color: post['likes']
                                                                    .contains(
                                                                        currentUserId)
                                                                ? Colors.red
                                                                : const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    122,
                                                                    143,
                                                                    166),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          '${post['likes'].length}',
                                                          style: const TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      122,
                                                                      143,
                                                                      166),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                            width: 40),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            try {
                                                              getAllData();
                                                              navigateTo(
                                                                context,
                                                                Comment(
                                                                  commentId: post[
                                                                      'commentId'],
                                                                  commentDescription:
                                                                      post[
                                                                          'commentDescription'],
                                                                  postUserId: post[
                                                                      'userId'],
                                                                  postId: documentId[
                                                                          userFollowingIndex]
                                                                      [
                                                                      postIndex],
                                                                  post: post,
                                                                ),
                                                              );
                                                            } catch (e) {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .deepPurple[200],
                                                                      content:
                                                                          Text(
                                                                        e.toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                            }
                                                          },
                                                          child: const Icon(
                                                            Icons
                                                                .comment_rounded,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    122,
                                                                    143,
                                                                    166),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          '${post['commentId'].length}',
                                                          style: const TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      122,
                                                                      143,
                                                                      166),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const Spacer(),
                                                        InkWell(
                                                          onTap: () {
                                                            // navigateTo(
                                                            //     context,
                                                            // Like(
                                                            //   likesId: post[
                                                            //       'likes'],
                                                            //     ));
                                                            //--------------------
                                                            Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  child: Like(
                                                                      likesId: post[
                                                                          'likes']),
                                                                  childCurrent:
                                                                      const HomePage(),
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  type: PageTransitionType
                                                                      .rightToLeftJoined),
                                                            );
                                                            //---------------------------
                                                            // navigateToWithAnimation(
                                                            //     context,
                                                            //     Like(
                                                            //         likesId: post[
                                                            //             'likes']),
                                                            //     PageTransitionType
                                                            //         .rightToLeft);
                                                          },
                                                          child: const Icon(
                                                            Icons.details,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    122,
                                                                    143,
                                                                    166),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                },
                              ),
                  )
                ],
              ),
            );
          }

          return Center(
              child: CircularProgressIndicator(
            color: Colors.deepPurple[300],
          ));
        },
      ),
    );
  }

  stories() => Container(
        height: 140,
        padding: const EdgeInsets.only(left: 25),
        child: Expanded(
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  navigateTo(context, const addStory());
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 38,
                    child: isNetworkConnection
                        ? CircleAvatar(
                            backgroundColor: Colors.deepPurple[300],
                            radius: 34,
                            child: const Icon(
                              Icons.add,
                              size: 50,
                              color: Colors.white,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 34,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.deepPurple[300],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              isStoryLoading
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Center(
                          child: CircularProgressIndicator(
                        color: Colors.deepPurple[300],
                      )),
                    )
                  : allStories.isEmpty
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * .5,
                          child: const Center(child: Text('No Stroies!')),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: allStories.length,
                          itemBuilder: (context, storyIndex) {
                            // print(allStories[0]);
                            // print(documenStorytId);
                            // print(']]]]]]]]]]]]]]]]]]]]]]]]]');
                            return InkWell(
                              onTap: () {
                                navigateTo(
                                    context,
                                    StoryViewer(
                                      storyData: allStories[storyIndex],
                                      lengthOfData: allStories.length,
                                      allStories: allStories,
                                      currentIndex: storyIndex,
                                    ));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  radius: 38,
                                  child: isNetworkConnection
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              allStories[storyIndex][0]
                                                  ['personalImage']),
                                          radius: 34,
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 34,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.deepPurple[300],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      );

  appBar() => AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Image.asset(
            'lib/assets/images/communication.png',
            scale: 10,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Social Media',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: IconButton(
                onPressed: () => signOut(context),
                icon: const Icon(Icons.logout),
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: IconButton(
                onPressed: () => navigateTo(context, const Search()),
                icon: const Icon(Icons.search_rounded),
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
}

//to send notification to someone
sendNotify({
  required String title,
  required String body,
  required String postId,
  required var postData,
  required String userId,
  required String token,
}) async {
  String serverToken =
      'AAAAZ1a27yQ:APA91bEI6z7oJ_P-ss_jtK64tJfuBk9Iszjb55Ap2bpAo-fCN9ysGmL6klL6w6mnDW94KUOfEhuQEkWJScvlJzzY1GSC-o7Ti-UR3SWP6lGOCzlmH_D6vX03pjrWphI8EWuaFbeI2Gvw';
  await post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': {
          'body': body.toString(),
          'title': title.toString(),
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'userId': userId.toString(),
          'postId': postId.toString(),
          'postData': postData.toString(),
          //  'id': '1',
        },
        'to': token,
      },
    ),
  );
}
