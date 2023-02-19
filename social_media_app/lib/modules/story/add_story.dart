import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_app/shared/constants.dart';
import 'package:video_viewer/video_viewer.dart';

import '../../shared/componant.dart';

class addStory extends StatefulWidget {
  const addStory({Key? key}) : super(key: key);

  @override
  State<addStory> createState() => _addStoryState();
}

class _addStoryState extends State<addStory> {
  VideoPlayerController? _controller;
  VideoViewerController videoViewerController = VideoViewerController();
  dynamic imageUrl;

  bool showGallaryOrCamera = false;
  bool showGallaryOrVideo = false;

  File? imageFile;

  var storyCaptionCont = TextEditingController();

  int counter = 0;

  var imagePath;

  Future<void> editVideo(ImageSource source) async {
    try {
      var pickedImage = await ImagePicker().pickVideo(source: source);

      imageFile = File(pickedImage!.path);

      _controller = VideoPlayerController.file(imageFile!)
        ..initialize().then((_) {
          setState(() {});
        });

      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> editImage(ImageSource source) async {
    try {
      var pickedImage = await ImagePicker().pickImage(source: source);

      imageFile = File(pickedImage!.path);
      _controller = null;
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
    if (storyCaptionCont.text.isEmpty && imageFile == null) {
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
              'stories/$counter${Uri.file(imageFile!.path).pathSegments.last}',
            );
        imagePath =
            'stories/$counter${Uri.file(imageFile!.path).pathSegments.last}';
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
            .collection('stories')
            .add({
          // 'commentId': [],
          // 'commentDescription': [],
          // 'likes': [],
          'userName': value.data()!['userName'],
          'personalImage': value.data()!['personalImage'],
          'userId': value.data()!['userId'],
          'caption': storyCaptionCont.text.isEmpty ? '' : storyCaptionCont.text,
          'storyImage': (imageFile != null) ? imageUrl : '',
          // 'storyText':
          //     storyCaptionCont.text.isEmpty ? '' : storyCaptionCont.text,
          'date': DateTime.now(),
          'storyImagePath': imagePath ?? '',
          'tokenNotification': value.data()!['tokenNotification'],
        });
      });

      // Navigator.pop;
    }
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple[200],
            content: const Text(
              'your story uploaded succecfully',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
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
    internetConection(context);
    getCounter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: Row(
          children: [
            // GestureDetector(
            //   onTap: () {
            //     navigateAndFinish(context, const Layout());
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.all(10),
            //     decoration: BoxDecoration(
            //       color: Colors.deepPurple,
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: const Center(
            //       child: Text(
            //         'cancel post',
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //           fontSize: 12,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const Text(
              'Add Story',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
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
                    'add now',
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
                      controller: storyCaptionCont,
                      minLines: 1,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'write your caption on story',
                      ),
                      cursorColor: Colors.deepPurple,
                    ),

                    _controller != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Center(
                              child: _controller!.value.isInitialized
                                  ? AspectRatio(
                                      aspectRatio:
                                          _controller!.value.aspectRatio,
                                      child: VideoPlayer(_controller!),
                                    )
                                  : Container(),
                            ),
                          )
                        // ClipRRect(
                        //     borderRadius: BorderRadius.circular(30),
                        //     child: VideoViewer(
                        //         style: VideoViewerStyle(
                        //             loading: const CircularProgressIndicator(
                        //           color: Colors.deepPurple,
                        //         )),
                        //         controller: videoViewerController,
                        //         source: {
                        //           "SubRip Text": VideoSource(
                        //             video: _controller!,
                        //             // subtitle: {
                        //             //   "English": VideoViewerSubtitle.network(
                        //             //     "https://felipemurguia.com/assets/txt/WEBVTT_English.txt",
                        //             //     type: SubtitleType.webvtt,
                        //             //   ),
                        //             // },
                        //           )
                        //         }),
                        //   )
                        : Container(),

                    _controller != null
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _controller!.value.isPlaying
                                    ? _controller!.pause()
                                    : _controller!.play();
                              });
                            },
                            icon: Icon(_controller!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow))
                        : Container(),
                    //image
                    const SizedBox(height: 30),
                    _controller == null
                        ? (imageFile != null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * .9,
                                  height:
                                      MediaQuery.of(context).size.height * .4,
                                  child: Image(
                                      fit: BoxFit.fill,
                                      image: FileImage(imageFile!)),
                                ),
                              )
                            : Container()
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                  visible: showGallaryOrVideo,
                  child: InkWell(
                    onTap: () {
                      editVideo(ImageSource.gallery);
                    },
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.indigo,
                      child: Icon(
                        size: 24,
                        Icons.photo,
                        color: Colors.white,
                      ),
                    ),
                  )),
              const SizedBox(
                width: 8,
              ),
              Visibility(
                visible: showGallaryOrVideo,
                child: InkWell(
                  onTap: () {
                    editVideo(ImageSource.camera);
                  },
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.indigo,
                    child:
                        Icon(size: 24, Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              FloatingActionButton(
                onPressed: () {
                  showGallaryOrVideo = !showGallaryOrVideo;
                  showGallaryOrCamera = false;
                  setState(() {});
                },
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.video_call),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                  visible: showGallaryOrCamera,
                  child: InkWell(
                    onTap: () {
                      editImage(ImageSource.gallery);
                    },
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.indigo,
                      child: Icon(
                        size: 24,
                        Icons.photo,
                        color: Colors.white,
                      ),
                    ),
                  )),
              const SizedBox(
                width: 8,
              ),
              Visibility(
                visible: showGallaryOrCamera,
                child: InkWell(
                  onTap: () {
                    editImage(ImageSource.camera);
                  },
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.indigo,
                    child:
                        Icon(size: 24, Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              FloatingActionButton(
                onPressed: () {
                  showGallaryOrCamera = !showGallaryOrCamera;
                  showGallaryOrVideo = false;
                  setState(() {});
                },
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.image),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
