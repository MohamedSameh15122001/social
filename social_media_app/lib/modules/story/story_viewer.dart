import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:story_view/story_view.dart';

class StoryViewer extends StatefulWidget {
  final stroyData;
  final documenStorytId;
  const StoryViewer({super.key, this.stroyData, this.documenStorytId});

  @override
  _StoryViewerState createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  final storyController = StoryController();

  List<StoryItem> stories = [];
  addItems() {
    stories = [];
    for (var i = 0; i < widget.stroyData.length; i++) {
      if (widget.stroyData[i]['storyText'].isNotEmpty) {
        stories.add(
          StoryItem.text(
            title: widget.stroyData[i]['storyText'],
            backgroundColor: Colors.red,
          ),
        );
      } else if (widget.stroyData[i]['storyVideo'].isNotEmpty) {
        stories.add(
          StoryItem.pageVideo(
            widget.stroyData[i]['storyVideo'],
            controller: storyController,
            caption: widget.stroyData[i]['caption'].isNotEmpty
                ? widget.stroyData[i]['caption']
                : '',
          ),
        );
      } else {
        stories.add(
          StoryItem.pageImage(
            controller: storyController,
            url: widget.stroyData[i]['storyImage'],
            caption: widget.stroyData[i]['caption'].isNotEmpty
                ? widget.stroyData[i]['caption']
                : '',
          ),
        );
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
    DateTime firstDate = widget.stroyData[0]['date'].toDate();
    var format = DateFormat.yMMMMd().format(firstDate);
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            storyItems: stories,
            onStoryShow: (storyItem) {
              print('Showing a story item');
            },
            onComplete: () {
              Navigator.pop(context);
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
                      widget.stroyData[0]['personalImage'],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.stroyData[0]['userName'],
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
