import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/comment/comment.dart';
import 'package:social_media_app/modules/search/search_page.dart';
import 'package:social_media_app/shared/componant.dart';
import 'package:social_media_app/shared/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var commentCont = TextEditingController();

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
    if (allData.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
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
                            ? const Center(child: Text('NO POSTS!'))
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
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundImage: NetworkImage(
                                                          '${post!['personalImage']}'),
                                                      radius: 24,
                                                    ),
                                                    const SizedBox(width: 10),
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
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          '12/12/2012',
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
                                                const SizedBox(height: 10),
                                                Text(
                                                    '${post['postDescription']}'),
                                                const SizedBox(height: 10),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  child: post['postImage'] != ''
                                                      ? Image.network(
                                                          '${post['postImage']}')
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
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${post['likes'].length}',
                                                        style: const TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    122,
                                                                    143,
                                                                    166),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const SizedBox(width: 40),
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
                                                                    [postIndex],
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
                                                                        Colors.deepPurple[
                                                                            200],
                                                                    content:
                                                                        Text(
                                                                      e.toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                          }
                                                        },
                                                        child: const Icon(
                                                          Icons.comment_rounded,
                                                          color: Color.fromARGB(
                                                              255,
                                                              122,
                                                              143,
                                                              166),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${post['commentId'].length}',
                                                        style: const TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    122,
                                                                    143,
                                                                    166),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
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
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (context, storyIndex) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 38,
                child: isNetworkConnection
                    ? const CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://www.diethelmtravel.com/wp-content/uploads/2016/04/bill-gates-wealthiest-person.jpg'),
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
            );
          },
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
