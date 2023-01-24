import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/comment/comment.dart';
import 'package:social_media_app/modules/search/search_page.dart';
import 'package:social_media_app/modules/settings_page/settings_page.dart';
import 'package:social_media_app/shared/constants.dart';

// var test =
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser?.uid)
//         .get();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var commentCont = TextEditingController();
  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

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

  List allData = [];
  List documentId = [];
  // Map<String, dynamic>? allData = {};
  Future getAllData() async {
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
        // allData.add(value.data());
        // print(value.data());
        // print('===================');
      }).catchError((e) {
        print(e.toString());
      });
    }
    // print(allData);
    // print(documentId);
    // print(allData[0]!['posts'].length);
    print('===================');
    setState(() {});
  }

  @override
  void initState() {
    // getFollowing();
    getAllData();

    internetConection(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // getFollowing();
    // print(following);
    // print('=========================');
    getdata() => FirebaseFirestore.instance
        .collection('users')
        .where(
          // 'following', arrayContainsAny: following,
          //FirebaseAuth.instance.currentUser!.uid
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
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

    return Scaffold(
      appBar: AppBar(
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
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Search(),
                    )),
                icon: const Icon(Icons.search_rounded),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: FutureBuilder(
        future: getdata(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          // getAllData();

          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                snapshot.data?.docs;
            QueryDocumentSnapshot<Map<String, dynamic>>? datadata;
            // getAllData();
            for (var i = 0; i < data!.length; i++) {
              datadata = data[i];
            }

            // print(datadata!.data());
            // print('=====================');

            // QueryDocumentSnapshot<Map<String, dynamic>> realData;

            // data!.map((e) => model = UserModel.fromMap(e.data()));
            // print(model!.age);
            // print('======================================');

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    padding: const EdgeInsets.only(left: 25),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: 20,
                      itemBuilder: (context, index) {
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 25.0,
                      right: 25.0,
                      bottom: 20,
                    ),
                    child: (allData.isEmpty)
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: following.length,
                            itemBuilder: (context, thebig) {
                              // print(allData[thebig]!['posts'].length);
                              // print(
                              //     '================================================');
                              return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: allData[thebig].length,
                                  itemBuilder: (context, index) {
                                    // print(allData[thebig]['userName']);
                                    // print(']]]]]]]]]]]]]]]]]]]]]]]]]]]]');
                                    // print(allData[thebig]!['personalImage']);
                                    // print(
                                    //     '=======================================');
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20.0),
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
                                                      '${allData[thebig][index]!['personalImage']}'),
                                                  radius: 24,
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${allData[thebig][index]!['userName']}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      '12/12/2012',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                const Icon(Icons.list_rounded)
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                                '${allData[thebig]![index]['postDescription']}'),
                                            const SizedBox(height: 10),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              child: allData[thebig]![index]
                                                          ['postImage']
                                                      .isNotEmpty
                                                  ? Image.network(
                                                      '${allData[thebig][index]['postImage']}')
                                                  : Container(),
                                            ),
                                            const SizedBox(height: 20),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 14.0),
                                              child: Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (allData[thebig]![
                                                              index]['likes']
                                                          .contains(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(
                                                                allData[thebig]![
                                                                        index]
                                                                    ['userId'])
                                                            .collection('posts')
                                                            .doc(documentId[
                                                                thebig][index])
                                                            .update({
                                                          'likes': FieldValue
                                                              .arrayRemove([
                                                            (FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid)
                                                          ])
                                                        });
                                                      } else {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(
                                                                allData[thebig]![
                                                                        index]
                                                                    ['userId'])
                                                            .collection('posts')
                                                            .doc(documentId[
                                                                thebig][index])
                                                            .update({
                                                          'likes': FieldValue
                                                              .arrayUnion([
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                          ]),
                                                        });
                                                      }
                                                      getAllData();
                                                      // setState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.favorite,
                                                      color: allData[thebig]![
                                                                      index]
                                                                  ['likes']
                                                              .contains(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                          ? Colors.red
                                                          : const Color
                                                                  .fromARGB(255,
                                                              122, 143, 166),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${allData[thebig]![index]['likes'].length}',
                                                    style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 122, 143, 166),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 40),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      getAllData();
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                        builder: (context) {
                                                          return Comment(
                                                            commentId: allData[
                                                                        thebig]![
                                                                    index]
                                                                ['commentId'],
                                                            commentDescription:
                                                                allData[thebig]![
                                                                        index][
                                                                    'commentDescription'],
                                                            postUserId:
                                                                allData[thebig]![
                                                                        index]
                                                                    ['userId'],
                                                            postId: documentId[
                                                                thebig][index],
                                                          );
                                                        },
                                                      ));
                                                    },
                                                    child: const Icon(
                                                      Icons.comment_rounded,
                                                      color: Color.fromARGB(
                                                          255, 122, 143, 166),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${allData[thebig]![index]['commentId'].length}',
                                                    style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 122, 143, 166),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  // const SizedBox(width: 40),
                                                  // const Icon(
                                                  //   Icons.heart_broken,
                                                  //   color: Color.fromARGB(
                                                  //       255, 122, 143, 166),
                                                  // ),
                                                  // const SizedBox(width: 4),
                                                  // const Text(
                                                  //   '12',
                                                  //   style: TextStyle(
                                                  //       color: Color.fromARGB(
                                                  //           255, 122, 143, 166),
                                                  //       fontWeight: FontWeight.bold),
                                                  // ),
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

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
