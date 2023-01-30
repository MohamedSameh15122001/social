import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/shared/componant.dart';
import 'package:social_media_app/shared/constants.dart';

class MassageDetails extends StatefulWidget {
  final userId;
  const MassageDetails({Key? key, this.userId}) : super(key: key);

  @override
  State<MassageDetails> createState() => _MassageDetailsState();
}

class _MassageDetailsState extends State<MassageDetails> {
  var massageCont = TextEditingController();
  Map userMassageData = {};
  getUserMassageData() async {
    userMassageData = {};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get()
        .then((value) {
      userMassageData = value.data()!;
      // print(value.data());
    });
    // print(userMassageData);
    setState(() {});
  }

  @override
  void initState() {
    internetConection(context);
    getUserMassageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: Row(
          children: [
            userMassageData.isEmpty
                ? Container()
                : CircleAvatar(
                    backgroundImage:
                        NetworkImage(userMassageData['personalImage']),
                  ),
            const SizedBox(width: 12),
            Text(
              userMassageData.isEmpty
                  ? 'loading...'
                  : userMassageData['userName'],
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('chats')
              .doc(widget.userId)
              .collection('massages')
              .orderBy('dateTime')
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                  snapshot.data?.docs;
              List datadata = [];

              for (var i = 0; i < data!.length; i++) {
                datadata.add(data[i].data());
              }

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: datadata.isEmpty
                          ? Text('Say hello to ${userMassageData['userName']}')
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: datadata.length,
                              itemBuilder: (context, index) {
                                if (datadata[index]['senderId'] ==
                                    currentUserId) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            datadata[index]['text'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          )),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            datadata[index]['text'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          )),
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextField(
                            onChanged: (value) {},
                            cursorColor: Colors.deepPurple,
                            keyboardType: TextInputType.emailAddress,
                            controller: massageCont,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12)),
                              ),
                              // border: InputBorder.none,
                              fillColor: Colors.grey[200],
                              filled: true,
                              hintText: 'write your massage',
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserId)
                                  .collection('chats')
                                  .doc(widget.userId)
                                  .collection('massages')
                                  .add({
                                'dateTime': DateTime.now(),
                                'receiverId': widget.userId,
                                'senderId': currentUserId,
                                'text': massageCont.text,
                              });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.userId)
                                  .collection('chats')
                                  .doc(currentUserId)
                                  .collection('massages')
                                  .add({
                                'dateTime': DateTime.now(),
                                'receiverId': widget.userId,
                                'senderId': currentUserId,
                                'text': massageCont.text,
                              });
                            },
                            child: Container(
                              height: 64,
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
