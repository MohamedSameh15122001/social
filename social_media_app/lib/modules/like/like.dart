// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Like extends StatefulWidget {
  var likesId;
  Like({
    super.key,
    this.likesId,
  });

  @override
  State<Like> createState() => _LikeState();
}

class _LikeState extends State<Like> {
  List usersDataLikes = [];
  bool isLoading = false;

  getUserDataLikes() async {
    setState(() {
      isLoading = true;
    });
    usersDataLikes = [];
    for (var i = 0; i < widget.likesId.length; i++) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.likesId[i])
          .get()
          .then((value) {
        usersDataLikes.add(value.data());
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getUserDataLikes();
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
          'Likes',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            )
          : usersDataLikes.isEmpty
              ? const Center(
                  child: Text(
                    'NO LIKES!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(
                    itemCount: widget.likesId.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                usersDataLikes[index]['personalImage'],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              usersDataLikes[index]['userName'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
