// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../data/implements/config_implementation.dart';
import '../../data/providers.dart';
import '../../domain/config_model/config_model.dart';

class NewContentPlayer extends ConsumerStatefulWidget {
  final List contentForDisplay;
  const NewContentPlayer({super.key, required this.contentForDisplay});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewContentPlayerState();
}

class _NewContentPlayerState extends ConsumerState<NewContentPlayer> {

  Directory? directory;
  VideoPlayerController? controller1;
  VideoPlayerController? controller2;
  Timer? timer;
  Map? imagePlayList;
  Map? playList;

  late String controllerName1;
  late String controllerName2;



  @override
  void initState() {
    controllerName1 = 'controller1';
    controllerName2 = 'controller2';
    initPlayList();
    super.initState();
  }

  @override
  void dispose() async {
    controller1?.dispose();
    controller2?.dispose();
    timer?.cancel();
    imageCache.clear();
    imageCache.clearLiveImages();
    disposeControllers();
    super.dispose();
  }

  Future initPlayList() async {
    directory = await getExternalStorageDirectory();
    Map indexingPlayList = {};

    // final screenWidth = MediaQuery.of(context).size.width.toInt();
    // final screenHeight = MediaQuery.of(context).size.height.toInt();

    for (var content in widget.contentForDisplay) {
      String path = '${directory!.path}/${content['name']}';
      String mimeType = lookupMimeType(path).toString();
      if (mimeType == 'image/jpeg'){
        // предварительная загрузка изображения
        await precacheImage(FileImage(File(path)), context);
        indexingPlayList[content['name']] = Image.file(
          File(path), 
          fit: BoxFit.fill, 
          gaplessPlayback: true,
          // cacheWidth: screenWidth.toInt(),
          // cacheHeight: screenHeight.toInt(),
          // filterQuality: FilterQuality.high,
        );
        
        
      } else {
        VideoPlayerController controller = VideoPlayerController.file(File(path));
        await controller.initialize().then((value){
          controller.setVolume(0);
          controller.pause();
        });
        indexingPlayList[content['name']] = controller;
      }
    }

    if(mounted){
      setState(() {
        playList = indexingPlayList;
      });
    }
  }

  void disposeControllers(){
    if (playList!.isNotEmpty){
      for (var entry in playList!.entries) {
        String path = '${directory!.path}/${entry.key}';
        String mimeType = lookupMimeType(path).toString();
        if (mimeType == 'image/jpeg'){
          continue;
        } else {
          entry.value.dispose();
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: directory == null || playList == null ?
      const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) :
      content(widget.contentForDisplay),
    );
  }


  Widget content(List contents){

    return Consumer(
      builder: (context, ref, child) {
        if (timer != null) { timer!.cancel();}
        int currentIndex = ref.watch(contentIndexProvider);
        ConfigImpl configImpl = ConfigImpl();
        ConfigModel cnf = ConfigModel(configModel:  Map<String, dynamic>.from(contents[currentIndex]));
        int nextIndex = configImpl.getNextIndex(currentIndex, contents.length);
        bool isImage = configImpl.isImage('${directory!.path}/${cnf.name}');
        int duration;
        var controller = playList![cnf.name];

        if (contents.length == 1) {
          if(!isImage){
            controller.setLooping(true); 
            controller.play();
          }
          return isImage ? _imageContent(playList![cnf.name]) : _videoContent(controller);
        } else {
          if(isImage){
            duration = cnf.duration * 1000;
          } else {
            duration = controller.value.duration.inMilliseconds;
            controller.play();
          }
          timer = Timer(Duration(milliseconds: duration), () {
            isImage ? null : {controller.seekTo(Duration.zero), controller.pause()};
            if(!isImage){
              controller.seekTo(Duration.zero); 
              controller.pause();
            }
            nextIndex == currentIndex ? null : ref.read(contentIndexProvider.notifier).state = nextIndex;
          });
          return isImage ? _imageContent(playList![cnf.name]) : _videoContent(controller);
        }
      },
    );
  }

  Widget _imageContent(Image image){
    return SizedBox(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      child: image
    );
  }

  Widget _videoContent(VideoPlayerController controller){
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayer(controller),
    );
  }



}