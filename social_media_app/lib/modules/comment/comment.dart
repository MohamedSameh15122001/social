import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  final commentId;
  final postUserId;
  final commentDescription;
  final postId;
  const Comment(
      {Key? key,
      this.commentId,
      this.commentDescription,
      this.postUserId,
      this.postId})
      : super(key: key);

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  var commentCont = TextEditingController();

  List comments = [];

  getComments() async {
    comments = [];
    for (var i = 0; i < widget.commentId.length; i++) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.commentId[i])
          .get()
          .then((value) {
        comments.add(value.data());
      });
    }
    // print(widget.commentId.length);
    // print('=======================');
    // print(widget.commentDescription);
    // print('=======================');
    // print(widget.postId);
    // print('=======================');
    // print(widget.postUserId);
    // print('=======================');
    // print(comments);
    // print('=======================');
    setState(() {});
  }

  @override
  void initState() {
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
            widget.commentDescription.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: widget.commentDescription.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                comments[index]['personalImage'],
                              ),
                            ),
                            Text(widget.commentDescription[index]),
                          ],
                        );
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
                      if (widget.commentId
                          .contains(FirebaseAuth.instance.currentUser!.uid)) {
                      } else {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.postUserId)
                            .collection('posts')
                            .doc(widget.postId)
                            .update({
                          'commentId': FieldValue.arrayUnion(
                              [FirebaseAuth.instance.currentUser!.uid]),
                          'commentDescription':
                              FieldValue.arrayUnion([commentCont.text]),
                        });
                      }
                      Navigator.pop(context);
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
//                                                                           'commentId': FirebaseAuth
//                                                                               .instance
//                                                                               .currentUser!
//                                                                               .uid,
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