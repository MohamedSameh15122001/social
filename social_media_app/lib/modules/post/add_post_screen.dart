import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/modules/layout/layout.dart';
import 'package:social_media_app/shared/constants.dart';

import '../../shared/componant.dart';

class Post extends StatefulWidget {
  const Post({Key? key}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  var emailController = TextEditingController();

  dynamic imageUrl;

  File? imageFile;

  var postCont = TextEditingController();

  int counter = 0;

  var imagePath;

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

  bool isLoading = false;
  //update data
  updateData() async {
    setState(() {
      isLoading = true;
    });
    if (postCont.text.isEmpty && imageFile == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple[200],
            content: const Text(
              'you should fill description or add photo or both!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      );
    } else {
      if (imageFile != null) {
        var refShared = await SharedPreferences.getInstance();
        counter = refShared.getInt('counter')!;
        var ref = FirebaseStorage.instance.ref('images').child(
              'posts/$counter${Uri.file(imageFile!.path).pathSegments.last}',
            );
        imagePath =
            'posts/$counter${Uri.file(imageFile!.path).pathSegments.last}';
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL();
        refShared.setInt('counter', counter + 1);
        counter = refShared.getInt('counter')!;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get()
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('posts')
            .add({
          'commentId': [],
          'commentDescription': [],
          'likes': [],
          'userName': value.data()!['userName'],
          'personalImage': value.data()!['personalImage'],
          'userId': value.data()!['userId'],
          'postDescription': postCont.text.isEmpty ? '' : postCont.text,
          'postImage': (imageFile != null) ? imageUrl : '',
          'postDate': DateTime.now(),
          'postImagePath': imagePath ?? '',
        });
      });

      // Navigator.pop;
    }
    setState(() {
      isLoading = false;
    });
  }

  getCounter() async {
    var ref = await SharedPreferences.getInstance();
    var c1 = ref.getInt('counter') ?? ref.setInt('counter', 0);
    c1 = counter;
    return counter;
  }

  @override
  void initState() {
    getCounter();
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                navigateAndFinish(context, const Layout());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'cancel post',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const Text(
              'Add Post',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: updateData,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'post now',
                    style: TextStyle(
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(
              'userId',
              isEqualTo: currentUserId,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                snapshot.data?.docs;
            QueryDocumentSnapshot<Map<String, dynamic>>? datadata;

            for (var i = 0; i < data!.length; i++) {
              datadata = data[i];
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    isLoading
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: LinearProgressIndicator(
                              color: Colors.deepPurple,
                            ),
                          )
                        : Container(),

                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          radius: 34,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(datadata?.data()['personalImage']),
                            radius: 30,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              datadata?.data()['userName'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: postCont,
                      minLines: 1,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'write your post',
                      ),
                      cursorColor: Colors.deepPurple,
                    ), //image
                    const SizedBox(height: 30),
                    (imageFile != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * .9,
                              height: MediaQuery.of(context).size.height * .4,
                              child: Image(
                                  fit: BoxFit.fill,
                                  image: FileImage(imageFile!)),
                            ),
                          )
                        : Container()
                    // ClipRRect(
                    //     borderRadius: BorderRadius.circular(30),
                    //     child: SizedBox(
                    //       width: MediaQuery.of(context).size.width * .9,
                    //       height: MediaQuery.of(context).size.height * .4,
                    //       child: Image(
                    //         fit: BoxFit.fill,
                    //         image: NetworkImage(
                    //           datadata?.data()['personalImage'],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editImage(ImageSource.gallery),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.image),
      ),
    );
  }
}
