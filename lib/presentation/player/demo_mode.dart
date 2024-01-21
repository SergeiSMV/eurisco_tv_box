import 'dart:io';

import 'package:eurisco_tv_box/colors.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class DemoMode extends StatefulWidget {
  final String? title;
  const DemoMode({super.key, this.title});

  @override
  State<DemoMode> createState() => _DemoModeState();
}

class _DemoModeState extends State<DemoMode> {

  VideoPlayerController? _controller;
  late final Directory? directory;


  @override
  void initState() {
    initialization();
    super.initState();
  }

  @override
  void dispose() async {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> initialization() async {
    directory = await getExternalStorageDirectory();
    String path = '${directory!.path}/bg.mp4';
    _controller = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        setState(() {
          _controller?.setLooping(true);
          _controller?.setVolume(0);
          _controller?.play();
        });
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller == null || !_controller!.value.isInitialized ? 
      Center(child: Text('загрузка...', style: white18,)) : 
      Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayer(_controller!),
          ),
          Center(child: Text(widget.title ?? '', style: white18,),)
        ],
      ),
    );
  }
}