import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/modules/personal_page/personal_page.dart';
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
  final ScrollController _scrollController = ScrollController();
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
    setState(() {});
    // print(userMassageData);
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    setState(() {});
  }

  //---------------------------------
  File? imageFile;
  bool isLoading = false;

  Future<void> editImage(ImageSource source) async {
    try {
      var pickedImage = await ImagePicker().pickImage(source: source);

      imageFile = File(pickedImage!.path);

      setState(() {});

      // imageFile = pickedImage;
      // var rand = Random().nextInt(100000);
      // var imageName = '${basename(pickedImage.path)}';
      // var ref =
      //     FirebaseStorage.instance.ref('images').child(imageName);
      // await ref.putFile(file);
      // imageUrl = ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
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
        title: InkWell(
          onTap: () {
            navigateTo(
                context,
                PersonalPage(
                  userId: userMassageData['userId'],
                ));
          },
          child: Row(
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
                    isLoading
                        ? Column(
                            children: const [
                              LinearProgressIndicator(
                                color: Colors.deepPurple,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          )
                        : Container(),
                    Expanded(
                      child: datadata.isEmpty
                          ? Text('Say hello to ${userMassageData['userName']}')
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: datadata.length,
                              itemBuilder: (context, index) {
                                DateTime firstDate =
                                    datadata[index]['dateTime'].toDate();
                                var format =
                                    DateFormat.yMMMMd().format(firstDate);
                                if (datadata[index]['senderId'] ==
                                    currentUserId) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(14),
                                                  topLeft: Radius.circular(14),
                                                  topRight: Radius.circular(10),
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(10),
                                              child: (datadata[index]
                                                          ['messageImage']
                                                      .isNotEmpty)
                                                  ? InstaImageViewer(
                                                      child: Image.network(
                                                          datadata[index]
                                                              ['messageImage']),
                                                    )
                                                  : Text(
                                                      datadata[index]['text'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    )),
                                          const SizedBox(height: 4),
                                          Text(
                                            format,
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 122, 143, 166),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.deepPurple,
                                              borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(14),
                                                topRight: Radius.circular(14),
                                                topLeft: Radius.circular(10),
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: (datadata[index]
                                                        ['messageImage']
                                                    .isNotEmpty)
                                                ? InstaImageViewer(
                                                    child: Image.network(
                                                        datadata[index]
                                                            ['messageImage']),
                                                  )
                                                : Text(
                                                    datadata[index]['text'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            format,
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 122, 143, 166),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
                    (imageFile != null)
                        ? Column(
                            children: [
                              const SizedBox(height: 10),
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .9,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .3,
                                      child: Image(
                                          fit: BoxFit.fill,
                                          image: FileImage(imageFile!)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.deepPurple,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              imageFile = null;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.exit_to_app,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Container(),
                    const SizedBox(height: 20),
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
                              prefixIcon: IconButton(
                                onPressed: () => editImage(ImageSource.gallery),
                                icon: const Icon(
                                  Icons.image,
                                  color: Colors.deepPurple,
                                  size: 30,
                                ),
                              ),
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
                              dynamic imageUrl;
                              int counter = 0;
                              String? imagePath;
                              if (massageCont.text == '' && imageFile == null) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.deepPurple[200],
                                        content: const Text(
                                          'your massage is empty!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    });
                              } else {
                                if (imageFile != null) {
                                  // setState(() {
                                  //   isLoading = true;
                                  // });
                                  var refShared =
                                      await SharedPreferences.getInstance();
                                  counter = refShared.getInt('counter')!;
                                  var ref = FirebaseStorage.instance
                                      .ref('images')
                                      .child(
                                        'messages/$counter${Uri.file(imageFile!.path).pathSegments.last}',
                                      );
                                  imagePath =
                                      'messages/$counter${Uri.file(imageFile!.path).pathSegments.last}';
                                  await ref.putFile(imageFile!);
                                  imageUrl = await ref.getDownloadURL();
                                  refShared.setInt('counter', counter + 1);
                                  counter = refShared.getInt('counter')!;
                                }
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
                                  'messageImage':
                                      (imageFile != null) ? imageUrl : '',
                                  'messageImagePath': imagePath ?? '',
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
                                  'messageImage':
                                      (imageFile != null) ? imageUrl : '',
                                  'messageImagePath': imagePath ?? '',
                                });
                                massageCont.clear();
                                // ignore: use_build_context_synchronously
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _scrollController.jumpTo(_scrollController
                                      .position.maxScrollExtent);
                                });
                              }
                              imageFile = null;
                              // setState(() {
                              //   isLoading = false;
                              // });
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
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            );
          }),
    );
  }
}
