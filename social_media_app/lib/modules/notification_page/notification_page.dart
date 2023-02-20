import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/componant.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);
  check() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .id;
  }

  @override
  Widget build(BuildContext context) {
    return check() == null || !check().isEmpty
        ? Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              backgroundColor: Colors.grey[300],
              elevation: 0,
              title: const Text(
                'Notifications',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
            ),
            body: const Center(child: Text('No Notifications!')),
          )
        : FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('notifications')
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.hasData) {
                List<QueryDocumentSnapshot<Map<String, dynamic>>>? data =
                    snapshot.data?.docs;

                QueryDocumentSnapshot<Map<String, dynamic>>? datadata;

                for (var i = 0; i < data!.length; i++) {
                  datadata = data[i];
                }
                String? format;
                if (datadata!.data().isNotEmpty) {
                  DateTime firstDate =
                      datadata.data()['notificationDate'].toDate();
                  format = DateFormat.yMMMMd().format(firstDate);
                }

                return Scaffold(
                    backgroundColor: Colors.grey[300],
                    appBar: AppBar(
                      backgroundColor: Colors.grey[300],
                      elevation: 0,
                      title: const Text(
                        'Notifications',
                        style: TextStyle(color: Colors.black),
                      ),
                      centerTitle: true,
                    ),
                    body: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // navigateTo(
                            //     context,
                            //     PostPage(
                            //       postData: datadata!.data()['personalImage'],
                            //       postDocumentId: datadata.data()['personalImage'],
                            //     ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 12,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.deepPurple,
                                    radius: 30,
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          '${datadata!.data()['personalImage']}'),
                                      radius: 26,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${datadata.data()['userName']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${datadata.data()['body']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          const Icon(
                                            Icons.circle_rounded,
                                            size: 10,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            format ?? 'no data',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.list)
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ));
              }
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No Notifications'),
                  );
                }
              }

              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ));
            });
  }
}
