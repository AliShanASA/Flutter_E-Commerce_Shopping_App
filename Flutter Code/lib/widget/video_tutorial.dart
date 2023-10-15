// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({Key? key}) : super(key: key);

  @override
  _TutorialDialogState createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Load the video from the assets folder
    _controller = VideoPlayerController.asset(
      'assets/videos/demovideo.mp4',
    );

    _controller.initialize().then((_) {
      print('Video initialization successful.');
      setState(() {
        _controller.play();
      });
    }).catchError((error) {
      print('Error initializing video: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('See The App Demo'),
      content: SizedBox(
        width: 300, // Set the width of the video container
        height: 550, // Set the height of the video container
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Skip Tutorial'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}