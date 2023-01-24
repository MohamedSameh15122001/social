import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MassageDetails extends StatefulWidget {
  final userId;
  const MassageDetails({Key? key, this.userId}) : super(key: key);

  @override
  State<MassageDetails> createState() => _MassageDetailsState();
}

class _MassageDetailsState extends State<MassageDetails> {
  var massageCont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: const Text(
          'massage',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('chats')
              .doc(widget.userId)
              .collection('massages')
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                snapshot.data?.docs;
            List datadata = [];

            for (var i = 0; i < data!.length; i++) {
              datadata.add(data[i].data());
            }
            print(datadata);
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: datadata.length,
                      itemBuilder: (context, index) {
                        if (datadata[index]['senderId'] ==
                            FirebaseAuth.instance.currentUser!.uid) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(datadata[index]['text']),
                            ),
                          );
                        } else {
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(datadata[index]['text']),
                            ),
                          );
                        }
                        return const Text('No Data');
                      },
                    ),
                  ),
                  const Spacer(),
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
                              borderSide: BorderSide(color: Colors.deepPurple),
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
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('chats')
                                .doc(widget.userId)
                                .collection('massages')
                                .add({
                              'dateTime': DateTime.now(),
                              'receiverId': widget.userId,
                              'senderId':
                                  FirebaseAuth.instance.currentUser!.uid,
                              'text': massageCont.text,
                            });
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.userId)
                                .collection('chats')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('massages')
                                .add({
                              'dateTime': DateTime.now(),
                              'receiverId': widget.userId,
                              'senderId':
                                  FirebaseAuth.instance.currentUser!.uid,
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
          }),
    );
  }
}
