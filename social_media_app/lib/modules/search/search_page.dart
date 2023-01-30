import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/personal_page/personal_page.dart';
import 'package:social_media_app/shared/constants.dart';

import '../../shared/componant.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var searchCont = TextEditingController();
  late var following;
  bool isLoading = false;
  getFollowing() async {
    setState(() {
      isLoading = true;
    });
    var ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get()
        .then((value) async {
      following = await value.data()!['following'];
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    internetConection(context);
    getFollowing();
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    getData() => FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: searchCont.text)
        .snapshots();

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
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('userNameArray',
                arrayContains: searchCont.text.toLowerCase())
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                snapshot.data?.docs;
            QueryDocumentSnapshot<Map<String, dynamic>>? datadata;
            getFollowing();
            // for (var i = 0; i < data!.length; i++) {
            //   datadata = data[i];
            // }
            // List<UserModel>? allSearchUsers = [];
            // for (var i = 0; i < data!.length; i++) {
            //   UserModel? userModel = model(data);
            //   allSearchUsers.add(userModel!);
            // }
            // UserModel? userModel = model(data);
            print(data!.length);

            // print(userModel!.userName);
            print('=================================');
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  //email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      cursorColor: Colors.deepPurple,
                      keyboardType: TextInputType.emailAddress,
                      controller: searchCont,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // border: InputBorder.none,
                        fillColor: Colors.grey[200],
                        filled: true,
                        hintText: 'Search',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      // shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        // print(following);
                        // print('========================');
                        return (currentUserId == data[index].data()['userId'])
                            ? Container()
                            : Padding(
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
                                      GestureDetector(
                                        onTap: () {
                                          navigateTo(
                                              context,
                                              PersonalPage(
                                                userId: data[index]
                                                    .data()['userId'],
                                              ));
                                        },
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.deepPurple,
                                              radius: 34,
                                              child: !isLoading
                                                  ? const CircularProgressIndicator()
                                                  : CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(data[
                                                                      index]
                                                                  .data()[
                                                              'personalImage']),
                                                      radius: 30,
                                                    ),
                                            ),
                                            const SizedBox(
                                              width: 6,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data[index]
                                                      .data()['userName'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepPurple,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 6,
                                                ),
                                                Text(
                                                  data[index].data()['bio'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      //confirm edit
                                      GestureDetector(
                                        onTap: () async {
                                          getFollowing();
                                          if (following.contains(
                                              data[index].data()['userId'])) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUserId)
                                                .update({
                                              'following':
                                                  FieldValue.arrayRemove([
                                                "${data[index].data()['userId']}"
                                              ])
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(data[index]
                                                    .data()['userId'])
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
                                                  FieldValue.arrayUnion([
                                                "${data[index].data()['userId']}"
                                              ])
                                              // [
                                              //   data[index].data()['userId']
                                              // ]
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(data[index]
                                                    .data()['userId'])
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
                                              following.contains(data[index]
                                                      .data()['userId'])
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
                                      ),
                                    ],
                                  ),
                                ),
                              );
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
