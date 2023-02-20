import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/home_page.dart';
import 'package:social_media_app/modules/personal_page/personal_page.dart';
import 'package:social_media_app/shared/constants.dart';

import '../../shared/componant.dart';

class Comment extends StatefulWidget {
  final commentId;
  final postUserId;
  final commentDescription;
  final postId;
  final post;
  const Comment({
    Key? key,
    this.commentId,
    this.commentDescription,
    this.postUserId,
    this.postId,
    required this.post,
  }) : super(key: key);

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  var commentCont = TextEditingController();

  List comments = [];
  bool isLoading = true;

  getComments() async {
    isLoading = true;
    await getNewData();
    comments = [];
    if (newData != null) {
      for (var i = 0; i < newData!['commentId'].length; i++) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newData!['commentId'][i])
            .get()
            .then((value) {
          comments.add(value.data());
        });
      }
    } else {
      for (var i = 0; i < widget.commentId.length; i++) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.commentId[i])
            .get()
            .then((value) {
          comments.add(value.data());
        });
      }
    }
    commentCont.text = '';
    isLoading = false;
    setState(() {});
  }

  Map<String, dynamic>? newData = {};
  getNewData() async {
    newData = {};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.postUserId)
        .collection('posts')
        .doc(widget.postId)
        .get()
        .then((value) {
      newData = value.data();
    });
    setState(() {});
    print(newData);
  }

  @override
  void initState() {
    internetConection(context);
    getComments();
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
          'Comments',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ))
                : (newData == null
                        ? widget.commentDescription.isEmpty
                        : newData?['commentDescription'] == null)
                    ? const Center(
                        child: Text('No Comments'),
                      )
                    : Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: newData != null
                              ? newData!['commentDescription'].length
                              : widget.commentDescription.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      navigateTo(
                                          context,
                                          PersonalPage(
                                            userId: comments[index]['userId'],
                                          ));
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        comments[index]['personalImage'],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        newData != null
                                            ? newData!['commentDescription']
                                                [index]
                                            : widget.commentDescription[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      )),
                                  WillPopScope(
                                    child: Container(),
                                    onWillPop: () async {
                                      // Navigator.pushReplacement(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => PostPage(
                                      //       postDocumentId: widget.postId,
                                      //       postData: widget.post,
                                      //     ),
                                      //   ),
                                      // );

                                      return true;
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
            widget.commentDescription.isEmpty ? const Spacer() : Container(),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    onChanged: (value) {},
                    cursorColor: Colors.deepPurple,
                    keyboardType: TextInputType.emailAddress,
                    controller: commentCont,
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
                      hintText: 'Comment',
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (newData != null
                          ? newData!['commentId'].contains(currentUserId)
                          : widget.commentId.contains(currentUserId)) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.deepPurple[200],
                                content: const Text(
                                  'you already commnened',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            });
                      } else {
                        if (commentCont.text.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.deepPurple[200],
                                  content: const Text(
                                    'please write your comment',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              });
                        } else {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.postUserId)
                              .collection('posts')
                              .doc(widget.postId)
                              .update({
                            'commentId': FieldValue.arrayUnion([currentUserId]),
                            'commentDescription':
                                FieldValue.arrayUnion([commentCont.text]),
                          });
                          await getComments();
                          //notification
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.post['userId'])
                              .collection('notifications')
                              .add({
                            'title': widget.post['userName'],
                            'body': 'react in your post',
                            'notificationDate': DateTime.now(),
                            'personalImage': widget.post['personalImage'],
                            'postId': widget.postId,
                            'userId': widget.post['userId'],
                            'userName': widget.post['userName'],
                            'postData': widget.post,
                          });

                          await sendNotify(
                            title: widget.post['userName'],
                            body: 'react in your post',
                            postId: widget.postId,
                            postData: widget.post,
                            userId: widget.post['userId'],
                            token: widget.post['tokenNotification'],
                          );
                        }
                      }
                      // Navigator.pop(context);
                      await getComments();
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
      ),
    );
  }
}


// List comments = [];
//              for (var i = 0;
//               i <
//               allData[thebig]![
//                                                                           index]
//                                                                       [
//                                                                       'commentId']
//                                                                   .length;
//                                                           i++) {
//                                                         await FirebaseFirestore
//                                                             .instance
//                                                             .collection('users')
//                                                             .doc(allData[
//                                                                         thebig]![
//                                                                     index][
//                                                                 'commentId'][i])
//                                                             .get()
//                                                             .then((value) {
//                                                           comments.add(
//                                                               value.data());
//                                                         });
//                                                       }
//                                                       print(comments);
//                                                       showModalBottomSheet(
//                                                         isScrollControlled =
//                                                             true,
//                                                         context = context,
//                                                         shape =
//                                                             const RoundedRectangleBorder(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .vertical(
//                                                             top:
//                                                                 Radius.circular(
//                                                                     30),
//                                                           ),
//                                                         ),
//                                                         builder = (context) {
//                                                           return Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: Column(
//                                                               children: [
//                                                                 SizedBox(
//                                                                   height: MediaQuery.of(
//                                                                               context)
//                                                                           .size
//                                                                           .height *
//                                                                       .9,
//                                                                   child: (comments
//                                                                           .isEmpty)
//                                                                       ? Container()
//                                                                       : ListView
//                                                                           .builder(
//                                                                           physics:
//                                                                               const NeverScrollableScrollPhysics(),
//                                                                           shrinkWrap:
//                                                                               true,
//                                                                           itemCount:
//                                                                               allData[thebig]![index]['commentId'].length,
//                                                                           itemBuilder:
//                                                                               (context, index) {
//                                                                             return Row(
//                                                                               children: [
//                                                                                 CircleAvatar(
//                                                                                   backgroundImage: NetworkImage(
//                                                                                     comments[index]['personalImage'],
//                                                                                   ),
//                                                                                 ),
//                                                                                 Text(allData[thebig]![index]['commentDescription'][index]),
//                                                                               ],
//                                                                             );
//                                                                           },
//                                                                         ),
//                                                                 ),
//                                                                 Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .spaceAround,
//                                                                   children: [
//                                                                     SizedBox(
//                                                                       width: MediaQuery.of(context)
//                                                                               .size
//                                                                               .width *
//                                                                           .7,
//                                                                       child:
//                                                                           TextField(
//                                                                         onChanged:
//                                                                             (value) {},
//                                                                         cursorColor:
//                                                                             Colors.deepPurple,
//                                                                         keyboardType:
//                                                                             TextInputType.emailAddress,
//                                                                         controller:
//                                                                             commentCont,
//                                                                         decoration:
//                                                                             InputDecoration(
//                                                                           enabledBorder:
//                                                                               OutlineInputBorder(
//                                                                             borderSide:
//                                                                                 const BorderSide(color: Colors.white),
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(12),
//                                                                           ),
//                                                                           focusedBorder:
//                                                                               OutlineInputBorder(
//                                                                             borderSide:
//                                                                                 const BorderSide(color: Colors.deepPurple),
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(12),
//                                                                           ),
//                                                                           // border: InputBorder.none,
//                                                                           fillColor:
//                                                                               Colors.grey[200],
//                                                                           filled:
//                                                                               true,
//                                                                           hintText:
//                                                                               'Comment',
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                     GestureDetector(
//                                                                       onTap:
//                                                                           () async {
//                                                                         await FirebaseFirestore
//                                                                             .instance
//                                                                             .collection('users')
//                                                                             .doc(allData[thebig]![index]['userId'])
//                                                                             .collection('posts')
//                                                                             .doc(documentId[index])
//                                                                             .update({
//                                                                           'commentId': currentUserId,
//                                                                           'commentDescription':
//                                                                               commentCont.text,
//                                                                         });
//                                                                       },
//                                                                       child:
//                                                                           Container(
//                                                                         width: MediaQuery.of(context).size.width *
//                                                                             .2,
//                                                                         height: MediaQuery.of(context).size.width *
//                                                                             .14,
//                                                                         padding:
//                                                                             const EdgeInsets.all(10),
//                                                                         decoration:
//                                                                             BoxDecoration(
//                                                                           color:
//                                                                               Colors.deepPurple,
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(12),
//                                                                         ),
//                                                                         child:
//                                                                             const Center(
//                                                                           child:
//                                                                               Icon(
//                                                                             Icons.send,
//                                                                             color:
//                                                                                 Colors.white,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           );
//                                                         },
//                                                       );