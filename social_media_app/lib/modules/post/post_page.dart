import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/componant.dart';
import 'package:social_media_app/shared/constants.dart';
import 'package:video_viewer/video_viewer.dart';

import '../comment/comment.dart';
import '../personal_page/personal_page.dart';

class PostPage extends StatefulWidget {
  final postData;
  final postDocumentId;
  const PostPage({super.key, this.postData, this.postDocumentId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  VideoViewerController videoViewerController = VideoViewerController();
  Map<String, dynamic>? newData = {};
  var format;
  bool isLoading = false;
  getNewData() async {
    setState(() {
      isLoading = true;
    });
    DateTime firstDate = await widget.postData['postDate'].toDate();
    format = DateFormat.yMMMMd().format(firstDate);
    newData = {};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.postData['userId'])
        .collection('posts')
        .doc(widget.postDocumentId)
        .get()
        .then((value) {
      newData = value.data();
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    internetConection(context);
    getNewData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: const Text(
          'post',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.deepPurple,
            ))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                // height: min(700, 700),
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 4,
                    )
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        navigateTo(context, const PersonalPage());
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                '${widget.postData!['personalImage']}'),
                            radius: 24,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.postData!['userName']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                format,
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
                    ),
                    const SizedBox(height: 10),
                    Text('${widget.postData['postDescription']}'),
                    const SizedBox(height: 10),
                    widget.postData['postImagePath'].endsWith('.mp4')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: VideoViewer(
                                style: VideoViewerStyle(
                                    loading: const CircularProgressIndicator(
                                  color: Colors.deepPurple,
                                )),
                                controller: videoViewerController,
                                source: {
                                  "SubRip Text": VideoSource(
                                    video: VideoPlayerController.network(
                                        widget.postData['postImage']),
                                  )
                                }),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: widget.postData['postImage'] != ''
                                ? SizedBox(
                                    height: 500,
                                    width: double.infinity,
                                    child: InstaImageViewer(
                                      child: Image.network(
                                        '${widget.postData['postImage']}',
                                        fit: BoxFit.cover,
                                      ),
                                    ))
                                : Container(),
                          ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (newData != null) {
                                if (newData!['likes'].contains(currentUserId)) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(newData!['userId'])
                                      .collection('posts')
                                      .doc(widget.postDocumentId)
                                      .update({
                                    'likes': FieldValue.arrayRemove(
                                        [(currentUserId)])
                                  });
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(newData!['userId'])
                                      .collection('posts')
                                      .doc(widget.postDocumentId)
                                      .update({
                                    'likes': FieldValue.arrayUnion([
                                      currentUserId,
                                    ]),
                                  });
                                }
                              } else {
                                if (widget.postData['likes']
                                    .contains(currentUserId)) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.postData['userId'])
                                      .collection('posts')
                                      .doc(widget.postDocumentId)
                                      .update({
                                    'likes': FieldValue.arrayRemove(
                                        [(currentUserId)])
                                  });
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.postData['userId'])
                                      .collection('posts')
                                      .doc(widget.postDocumentId)
                                      .update({
                                    'likes': FieldValue.arrayUnion([
                                      currentUserId,
                                    ]),
                                  });
                                }
                              }

                              await getNewData();
                              // setState(() {});
                              // await getAllData();
                            },
                            child: newData!.isNotEmpty
                                ? Icon(
                                    Icons.favorite,
                                    color: newData!['likes']
                                            .contains(currentUserId)
                                        ? Colors.red
                                        : const Color.fromARGB(
                                            255, 122, 143, 166),
                                  )
                                : Icon(
                                    Icons.favorite,
                                    color: widget.postData['likes']
                                            .contains(currentUserId)
                                        ? Colors.red
                                        : const Color.fromARGB(
                                            255, 122, 143, 166),
                                  ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            newData!.isNotEmpty
                                ? '${newData!['likes'].length}'
                                : '${widget.postData['likes'].length}',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 122, 143, 166),
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 40),
                          GestureDetector(
                            onTap: () async {
                              // getAllData();
                              print(widget.postDocumentId);
                              navigateTo(
                                context,
                                Comment(
                                  commentId: widget.postData['commentId'],
                                  commentDescription:
                                      widget.postData['commentDescription'],
                                  postUserId: widget.postData['userId'],
                                  postId: widget.postDocumentId,
                                  post: widget.postData,
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.comment_rounded,
                              color: Color.fromARGB(255, 122, 143, 166),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            newData!.isNotEmpty
                                ? '${newData!['commentId'].length}'
                                : '${widget.postData['commentId'].length}',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 122, 143, 166),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
