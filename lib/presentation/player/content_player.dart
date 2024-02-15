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

class ContentPlayer extends ConsumerStatefulWidget {
  final List contentForDisplay;
  const ContentPlayer({super.key, required this.contentForDisplay});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentPlayerState();
}

class _ContentPlayerState extends ConsumerState<ContentPlayer> {

  Directory? directory;
  VideoPlayerController? controller1;
  VideoPlayerController? controller2;
  Timer? timer;
  Map? imagePlayList;

  late String controllerName1;
  late String controllerName2;



  @override
  void initState() {
    controllerName1 = 'controller1';
    controllerName2 = 'controller2';
    initPlayer();
    super.initState();
  }

  @override
  void dispose() async {
    controller1?.dispose();
    controller2?.dispose();
    timer?.cancel();
    imageCache.clear();
    imageCache.clearLiveImages();
    super.dispose();
  }

  Future initPlayer() async {
    await getExternalStorageDirectory().then((value) {
      directory = value;
      imagePlayList = {};
      for (var content in widget.contentForDisplay) {
        String path = '${directory!.path}/${content['name']}';
        String mimeType = lookupMimeType(path).toString();
        if (mimeType == 'image/jpeg'){
          File(path).create(recursive: true);
          imagePlayList?[content['name']] = SizedBox(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Image.file(
              File(path), 
              fit: BoxFit.fill, 
              gaplessPlayback: true,
              cacheWidth: MediaQuery.of(context).size.width.toInt(),
              filterQuality: FilterQuality.high,),
          );
          // предварительная загрузка изображения
          // precacheImage(FileImage(File(path)), context);
        } else {
          null;
        }
      }
    });
    
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: directory == null || imagePlayList == null ?
      const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) :
      content(widget.contentForDisplay, context),
    );
  }


  Widget content(List contents, BuildContext context){

    return Consumer(
      builder: (context, ref, child) {
        
        int currentIndex = ref.watch(contentIndexProvider);
        ConfigImpl configImpl = ConfigImpl();
        ConfigModel cnf = ConfigModel(configModel:  Map<String, dynamic>.from(contents[currentIndex]));

        String path = '${directory!.path}/${cnf.name}';
        bool isImage = configImpl.isImage(path);

        int nextIndex = configImpl.getNextIndex(currentIndex, contents.length);
        ConfigModel nextContent = ConfigModel(configModel: Map<String, dynamic>.from(contents[nextIndex]));
        String nextPath = configImpl.getNextPath(contents, nextIndex, directory!);
        bool nextIsImage = configImpl.isImage(nextPath);

        if (contents.length == 1) {

          if (isImage){
            // return _imageContent(path, context);
            return imagePlayList![cnf.name];
            // return _imageContent(imagePlayList![cnf.name]);
          } else {
            controller1 = VideoPlayerController.file(File(path));
            controller1?.initialize();
            controller1?.setLooping(true);
            controller1?.setVolume(0);
            controller1?.play();
            return _videoContent(controller1!);
          }

        } else {

          if (isImage) {

            timer = Timer(const Duration(seconds: 2), () { 
              nextIndex == currentIndex ? null :
              {
                nextIsImage ? null : {
                  controller1 = VideoPlayerController.file(File(nextPath)),
                  controller1?.initialize().then((value){
                    controller1?.setVolume(0);
                    controller1?.pause();
                    controllerName1 = nextContent.name;
                  })
                }
              };
            });
            timer = Timer(Duration(seconds: cnf.duration), () { 
              nextIndex == currentIndex ? null : ref.read(contentIndexProvider.notifier).state = nextIndex;
            });
            // return _imageContent(path, context);
            return imagePlayList![cnf.name];
            // return _imageContent(imagePlayList![cnf.name]);
          } else {

            if (controllerName1 == cnf.name){

              int duration = controller1!.value.duration.inMilliseconds;
              timer = Timer(const Duration(seconds: 2), () { 
                nextIndex == currentIndex ? null :
                {
                  nextIsImage ? null : {
                    controller2 = VideoPlayerController.file(File(nextPath)),
                    controller2?.initialize(),
                    controller2?.setVolume(0),
                    controller2?.pause(),
                    controllerName2 = nextContent.name,
                  }
                };
              });
              timer = Timer(Duration(milliseconds: duration), () {
                controllerName1 = 'BigBuckBunny.mp4';
                nextIndex == currentIndex ? null : 
                {
                  ref.read(contentIndexProvider.notifier).state = nextIndex,
                  controller1?.dispose()
                };
              });
              nextIndex == currentIndex ? controller1?.setLooping(true) : null;
              controller1?.setVolume(0);
              controller1?.play();
              return _videoContent(controller1!);

            } else if (controllerName2 == cnf.name) {

              int duration = controller2!.value.duration.inMilliseconds;

              timer = Timer(const Duration(seconds: 2), () { 
                nextIndex == currentIndex ? null :
                {
                  nextIsImage ? null : {
                    controller1 = VideoPlayerController.file(File(nextPath)),
                    controller1?.initialize(),
                    controller1?.setVolume(0),
                    controller1?.pause(),
                    controllerName1 = nextContent.name,
                  }
                };
              });

              timer = Timer(Duration(milliseconds: duration), () {
                controllerName2 = 'BigBuckBunny.mp4';
                nextIndex == currentIndex ? null :
                {
                  ref.read(contentIndexProvider.notifier).state = nextIndex,
                  controller2?.dispose()
                };
              });
              nextIndex == currentIndex ? controller1?.setLooping(true) : null;
              controller2?.setVolume(0);
              controller2?.play();
              return _videoContent(controller2!);

            } else {

              int duration;
              timer = Timer(const Duration(seconds: 2), () { 
                nextIndex == currentIndex ? null :
                {
                  nextIsImage ? null : {
                    controller2 = VideoPlayerController.file(File(nextPath)),
                    controller2?.initialize(),
                    controller2?.setVolume(0),
                    controller2?.pause(),
                    controllerName2 = nextContent.name,
                  }
                };
              });
              controller1 = VideoPlayerController.file(File(path));
              controller1?.initialize().then((_) {
                duration = controller1!.value.duration.inMilliseconds;
                controllerName1 = cnf.name;
                timer = Timer(Duration(milliseconds: duration), () {
                  controllerName1 = 'BigBuckBunny.mp4';
                  nextIndex == currentIndex ? null :
                  {
                    ref.read(contentIndexProvider.notifier).state = nextIndex,
                    controller1?.dispose()
                  };
                });
              });
              nextIndex == currentIndex ? controller1?.setLooping(true) : null;
              controller1?.setVolume(0);
              controller1?.play();
              return _videoContent(controller1!);

            }
          }
        }
      },
    );
  }

  /*
  // Widget _imageContent(Widget image){
  //   return SizedBox(
  //     height: MediaQuery.of(context).size.width,
  //     width: MediaQuery.of(context).size.width,
  //     child: image
  //   );
  // }

  Widget _imageContent(String path, BuildContext context){
    return SizedBox(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      child: Image.file(
        File(path), 
        fit: BoxFit.fill, 
        gaplessPlayback: true,
        cacheWidth: MediaQuery.of(context).size.width.toInt(),
      )
    );
  }
  */

  Widget _videoContent(VideoPlayerController controller){
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayer(controller),
    );
  }



}