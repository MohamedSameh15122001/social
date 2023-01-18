import 'package:flutter/material.dart';

class MassagePage extends StatelessWidget {
  const MassagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          elevation: 0,
          title: const Text(
            'Inbox',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 20,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                right: 25.0,
                top: 20,
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
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
                    const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      radius: 34,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://www.diethelmtravel.com/wp-content/uploads/2016/04/bill-gates-wealthiest-person.jpg'),
                        radius: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Vernon Bradley',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Shall we meet today?',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: const [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            '1',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          '5 : 45 PM',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
