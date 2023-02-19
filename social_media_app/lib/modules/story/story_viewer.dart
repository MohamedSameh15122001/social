import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:story_view/story_view.dart';

class StoryViewer extends StatefulWidget {
  final storyData;
  final documenStorytId;
  final lengthOfData;
  final allStories;
  final currentIndex;
  const StoryViewer(
      {super.key,
      this.storyData,
      this.documenStorytId,
      this.lengthOfData,
      this.allStories,
      this.currentIndex});

  @override
  _StoryViewerState createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  final storyController = StoryController();

  List<StoryItem> stories = [];
  List colors = [
    Colors.red,
    Colors.blue,
    Colors.black,
    Colors.deepPurple,
    Colors.amber,
    Colors.grey,
    Colors.deepOrange,
    Colors.indigo,
    Colors.cyanAccent,
    Colors.pinkAccent,
  ];
  Random random = Random();

  var randomNumber;

  addItems() {
    randomNumber = random.nextInt(10);

    stories = [];
    for (var i = 0; i < widget.storyData.length; i++) {
      if (widget.storyData[i]['storyImagePath'].isEmpty) {
        stories.add(
          StoryItem.text(
            title: widget.storyData[i]['caption'],
            backgroundColor: colors[randomNumber],
          ),
        );
      } else if (widget.storyData[i]['storyImagePath'].isNotEmpty) {
        if (widget.storyData[i]['storyImagePath'].endsWith('.mp4')) {
          stories.add(
            StoryItem.pageVideo(
              widget.storyData[i]['storyImage'],
              controller: storyController,
              caption: widget.storyData[i]['caption'].isNotEmpty
                  ? widget.storyData[i]['caption']
                  : '',
            ),
          );
        } else {
          stories.add(
            StoryItem.pageImage(
              controller: storyController,
              url: widget.storyData[i]['storyImage'],
              caption: widget.storyData[i]['caption'].isNotEmpty
                  ? widget.storyData[i]['caption']
                  : '',
            ),
          );
        }
      }
    }
    // setState(() {});
  }

  @override
  void initState() {
    addItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime firstDate = widget.storyData[0]['date'].toDate();
    var format = DateFormat.yMMMMd().format(firstDate);
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            storyItems: stories,
            onStoryShow: (storyItem) {
              print('Showing a story item');
            },
            onVerticalSwipeComplete: (p0) {},
            onComplete: () {
              if (widget.lengthOfData - 1 > widget.currentIndex) {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                      child: StoryViewer(
                        storyData: widget.allStories[widget.currentIndex + 1],
                        allStories: widget.allStories,
                        currentIndex: widget.currentIndex + 1,
                        lengthOfData: widget.lengthOfData,
                      ),
                      childCurrent: Container(),
                      duration: const Duration(milliseconds: 400),
                      type: PageTransitionType.rightToLeftJoined),
                );

                // Navigator.pushReplacement(context, MaterialPageRoute(
                //   builder: (context) {
                //     return StoryViewer(
                //       storyData: widget.allStories[widget.currentIndex + 1],
                //       allStories: widget.allStories,
                //       currentIndex: widget.currentIndex + 1,
                //       lengthOfData: widget.lengthOfData,
                //     );
                //   },
                // ));
              } else {
                Navigator.pop(context);
              }
            },
            controller: storyController,
            repeat: false,
            inline: true,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      widget.storyData[0]['personalImage'],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.storyData[0]['userName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
