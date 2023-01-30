import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/shared/constants.dart';
import '../../models/user_model.dart';
import '../../shared/componant.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var usernameController = TextEditingController();
  var bioController = TextEditingController();
  var emailController = TextEditingController();

  dynamic imageUrl;
  File? imageFile;
  int counter = 0;
  var imagePath;

  //get counter
  getCounter() async {
    var ref = await SharedPreferences.getInstance();
    var c1 = ref.getInt('counter') ?? ref.setInt('counter', 0);
    c1 = counter;
    return counter;
  }

  @override
  void initState() {
    internetConection(context);
    getCounter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey[300],
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    getdata() => FirebaseFirestore.instance
        .collection('users')
        .where(
          'userId',
          isEqualTo: currentUserId,
        )
        .snapshots();

    model(List<QueryDocumentSnapshot<Map<String, dynamic>>>? data) {
      QueryDocumentSnapshot<Map<String, dynamic>>? datadata;
      UserModel? model;
      for (var i = 0; i < data!.length; i++) {
        datadata = data[i];
        model = UserModel.fromMap(datadata.data());
      }
      return [model, datadata!.id];
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getdata(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                snapshot.data?.docs;
            UserModel? userModel = model(data).first as UserModel?;
            // QueryDocumentSnapshot<Map<String, dynamic>>? datadata;
            // for (var i = 0; i < data!.length; i++) {
            //   datadata = data[i];
            // }
            //username controller

            if (usernameController.text.isEmpty ||
                bioController.text.isEmpty ||
                emailController.text.isEmpty) {
              usernameController.text = '${userModel?.userName}';
              bioController.text = userModel!.bio;
              emailController.text = userModel.email;
            }

            //edit image
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

            //update data
            updateData() async {
              if (imageFile != null) {
                var refShared = await SharedPreferences.getInstance();
                counter = refShared.getInt('counter')!;
                var ref = FirebaseStorage.instance.ref('images').child(
                      'personalImage/$counter${Uri.file(imageFile!.path).pathSegments.last}',
                    );
                imagePath =
                    'personalImage/$counter${Uri.file(imageFile!.path).pathSegments.last}';
                await ref.putFile(imageFile!);
                imageUrl = await ref.getDownloadURL();
                refShared.setInt('counter', counter + 1);
                counter = refShared.getInt('counter')!;

                if (userModel!.personalImagePath.isNotEmpty) {
                  await FirebaseStorage.instance
                      .ref('images')
                      .child(userModel.personalImagePath)
                      .delete();
                }
              }
              print(model(data).last.toString());
              print('==================================');
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(model(data).last as String)
                  .update({
                'userName': usernameController.text.toString(),
                'bio': bioController.text,
                'email': emailController.text,
                'personalImage':
                    (imageFile != null) ? imageUrl : userModel!.personalImage,
                'personalImagePath': imagePath ?? '',
              });

              Navigator.of(context).pop();
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //First section about information
                  Container(
                    height: 600,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 10,
                          blurRadius: 12,
                        )
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
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
                                  child: (imageFile != null)
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(imageFile!),
                                          radius: 60,
                                        )
                                      : CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              userModel!.personalImage),
                                          radius: 60,
                                        ),
                                ),

                                //username
                                TextField(
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepPurple.shade100),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurple),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    // border: InputBorder.none,
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                    hintText: 'username',
                                  ),
                                ),

                                //bio
                                TextField(
                                  controller: bioController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepPurple.shade100),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurple),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    // border: InputBorder.none,
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                    hintText: 'Bio',
                                  ),
                                ),

                                //email
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.deepPurple.shade100),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurple),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    // border: InputBorder.none,
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                    hintText: 'email',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: const Alignment(.2, -0.8),
                            child: GestureDetector(
                              onTap: () => editImage(ImageSource.gallery),
                              child: const CircleAvatar(
                                child: Icon(Icons.edit),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .06,
                  ),
                  //confirm edit
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: updateData,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Confirm Edit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .06,
                  ),
                  //Signout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: () => signOut(context),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
