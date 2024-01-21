import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class PreviewPlayer extends StatefulWidget {
  final Map content;
  const PreviewPlayer({super.key, required this.content});

  @override
  State<PreviewPlayer> createState() => _PreviewPlayerState();
}

class _PreviewPlayerState extends State<PreviewPlayer> {



  late VideoPlayerController _controller;
  late final Directory? directory;
  late bool isImage;
  late String contentPath;

  @override
  void initState() {
    initialization();
    super.initState();
  }

  @override
  void dispose() async {
    isImage ? null : _controller.dispose();
    super.dispose();
  }

  Future initialization() async {
    directory = await getExternalStorageDirectory();
    String path = '${directory!.path}/${widget.content['name']}';
    String mimeType = lookupMimeType(path).toString();
    mimeType == 'image/jpeg' ? isImage = true : isImage = false;
    setState(() {

      contentPath = path;
      mimeType == 'image/jpeg' ? null : {
        _controller = VideoPlayerController.file(File(path)),
        _controller.initialize().then((_) {
          _controller.setLooping(true);
          _controller.setVolume(0);
          _controller.play();
        }),
      };
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isImage ? 
        SizedBox(
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          child: Image.file(File(contentPath), fit: BoxFit.fill,)
        ) :
        AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayer(_controller),
        )
    );
  }
}