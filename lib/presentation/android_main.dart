import 'dart:async';
// ignore: unused_import
import 'dart:developer';
import 'dart:io' as io;

import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../colors.dart';
import '../data/implements/config_implementation.dart';
import '../data/providers.dart';
import '../domain/config_model/config_model.dart';
import 'content_lib.dart';

class ActionIntent extends Intent {}

class AndroidMain extends ConsumerStatefulWidget {
  const AndroidMain({super.key});

  @override
  ConsumerState<AndroidMain> createState() => _AndroidMainState();
}

class _AndroidMainState extends ConsumerState<AndroidMain> {

  int loopLength = 0;
  int contentIndex = 0;

  VideoPlayerController _controller1 = VideoPlayerController.networkUrl(
    Uri.parse('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'))..initialize();

  VideoPlayerController _controller2 = VideoPlayerController.networkUrl(
    Uri.parse('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'))..initialize();

  String controllerName1 = 'BigBuckBunny.mp4';
  String controllerName2 = 'BigBuckBunny.mp4';

  late final io.Directory? directory;
  Timer indexTimer = Timer(const Duration(seconds: 0), () { null; });
  Timer initTimer = Timer(const Duration(seconds: 0), () { null; });


  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  void dispose() async {
    _controller1.dispose();
    _controller2.dispose();
    indexTimer.cancel();
    initTimer.cancel();
    super.dispose();
  }

  Future initialization() async {
    directory = await getExternalStorageDirectory();
  }

  @override
  Widget build(BuildContext context) {
    
    ref.watch(getConfigProvider);
    final loopLength = ref.watch(loopLengthProvider);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select) : const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActionIntent: CallbackAction(onInvoke: (Intent i) => null),
        },
        child: WillPopScope(
          onWillPop: () async {
            ref.read(onFocusIndexProvider.notifier).state = 999;
            ref.read(containerSizeProvider.notifier).state = 0;
            return false;
          },
          child: GestureDetector(
            onPanUpdate: (details) async {
              ref.read(configProvider.notifier).state = {};
              ref.read(loopLengthProvider.notifier).state = 0;
              ref.read(contentIndexProvider.notifier).state = 0;
              indexTimer.cancel();
              initTimer.cancel();
              _controller1.dispose();
              _controller2.dispose();
              controllerName1 = 'BigBuckBunny.mp4'; controllerName2 = 'BigBuckBunny.mp4';
              return Future.delayed(const Duration(seconds: 3), () {
                return ref.refresh(getConfigProvider);
              });
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              body: ProgressHUD(
                barrierColor: Colors.white.withOpacity(0.7),
                padding: const EdgeInsets.all(20.0),
                child: Consumer(
                  builder: (context, ref, child) {

                    final config = ref.watch(configProvider);

                    return config.isEmpty ? 
                    // загрузка
                    Center(child: Text('загрузка...', style: white18,),)
                    // loading()
                    :
                    // основной экран
                    Stack(
                      children: [
                        config['config'].isEmpty ? demoMode() : content(config['config'], loopLength),
                        // appBar приложения
                        settingsAppBar(config['deviceID'], config['deviceName']),
                      ],
                    );
                  }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  Widget content(List config, int loopLength) {
    bool noContent = checkBlocContent(config);
    return noContent ? demoMode() :
    Consumer(
      builder: ((context, ref, child) {

        ConfigImpl cnfImpl = ConfigImpl();

        final currentIndex = ref.watch(contentIndexProvider);
        ConfigModel cnf = ConfigModel(configModel:  Map<String, dynamic>.from(config[currentIndex]));
        
        String path = '${directory!.path}/${cnf.name}';
        bool isImage = cnfImpl.isImage(path);
        bool show = cnf.show;
        bool showTime = cnfImpl.compireTime(cnf.startShow, cnf.endShow);



        int nextIndex = cnfImpl.getNextIndex(currentIndex, loopLength, config);
        ConfigModel nextCnf = ConfigModel(configModel: Map<String, dynamic>.from(config[nextIndex]));
        String nextPath = cnfImpl.getNextPath(config, nextIndex, directory!);
        bool nextIsImage = cnfImpl.isImage(nextPath);

        
        if (loopLength == 1) {
          if (isImage){
            return cnf.show && cnfImpl.compireTime(cnf.startShow, cnf.endShow) ? _imageContent(path) : demoMode();
          } else {
            cnf.show && cnfImpl.compireTime(cnf.startShow, cnf.endShow)  ?  {
              _controller1 = VideoPlayerController.file(io.File(path)),
              _controller1.initialize(),
              _controller1.setLooping(true),
              _controller1.setVolume(0),
              _controller1.play(),
            } : null;
            return cnf.show && cnfImpl.compireTime(cnf.startShow, cnf.endShow) ? _videoContent(_controller1) : demoMode();
          }
        }

        else {
          if (isImage) {
            if (show && showTime) {
              initTimer = Timer(const Duration(seconds: 2), () { 
                nextIndex == currentIndex ? null :
                {
                  nextIsImage ? null : {
                    _controller1 = VideoPlayerController.file(io.File(nextPath)),
                    _controller1.initialize().then((value){
                      _controller1.setVolume(0);
                      _controller1.pause();
                      controllerName1 = nextCnf.name;
                    })
                  }
                };
              });

              indexTimer = Timer(Duration(seconds: cnf.duration), () { 
                nextIndex == currentIndex ? null : ref.read(contentIndexProvider.notifier).state = nextIndex;
              });
              return _imageContent(path);

            } else {
              indexTimer = Timer(const Duration(seconds: 2), () {
                ref.read(contentIndexProvider.notifier).state = nextIndex;
              });
              return loading();
            }

          } else {

            if (controllerName1 == cnf.name){
              int duration = _controller1.value.duration.inMilliseconds;

              initTimer = Timer(const Duration(seconds: 2), () { 
                nextIndex == currentIndex ? null :
                {
                  nextIsImage ? null : {
                    _controller2 = VideoPlayerController.file(io.File(nextPath)),
                    _controller2.initialize(),
                    _controller2.setVolume(0),
                    _controller2.pause(),
                    controllerName2 = nextCnf.name,
                  }
                };
              });

              indexTimer = Timer(Duration(milliseconds: duration), () {
                controllerName1 = 'BigBuckBunny.mp4';
                nextIndex == currentIndex ? null : 
                {
                  ref.read(contentIndexProvider.notifier).state = nextIndex,
                  _controller1.dispose()
                };
              });
              nextIndex == currentIndex ? _controller1.setLooping(true) : null;
              _controller1.setVolume(0);
              _controller1.play();
              return _videoContent(_controller1);
            } 
            
            else if (controllerName2 == cnf.name){
              int duration = _controller2.value.duration.inMilliseconds;

              initTimer = Timer(const Duration(seconds: 2), () { 
                nextIndex == currentIndex ? null :
                {
                  nextIsImage ? null : {
                    _controller1 = VideoPlayerController.file(io.File(nextPath)),
                    _controller1.initialize(),
                    _controller1.setVolume(0),
                    _controller1.pause(),
                    controllerName1 = nextCnf.name,
                  }
                };
              });

              indexTimer = Timer(Duration(milliseconds: duration), () {
                controllerName2 = 'BigBuckBunny.mp4';
                nextIndex == currentIndex ? null :
                {
                  ref.read(contentIndexProvider.notifier).state = nextIndex,
                  _controller2.dispose()
                };
              });
              nextIndex == currentIndex ? _controller1.setLooping(true) : null;
              _controller2.setVolume(0);
              _controller2.play();
              return _videoContent(_controller2);
            }
            
            else {
              if (show && showTime) {
                int duration;
                initTimer = Timer(const Duration(seconds: 2), () { 
                  nextIndex == currentIndex ? null :
                  {
                    nextIsImage ? null : {
                      _controller2 = VideoPlayerController.file(io.File(nextPath)),
                      _controller2.initialize(),
                      _controller2.setVolume(0),
                      _controller2.pause(),
                      controllerName2 = nextCnf.name,
                    }
                  };
                });
                _controller1 = VideoPlayerController.file(io.File(path));
                _controller1.initialize().then((_) {
                  duration = _controller1.value.duration.inMilliseconds;
                  controllerName1 = cnf.name;
                  indexTimer = Timer(Duration(milliseconds: duration), () {
                    controllerName1 = 'BigBuckBunny.mp4';
                    nextIndex == currentIndex ? null :
                    {
                      ref.read(contentIndexProvider.notifier).state = nextIndex,
                      _controller1.dispose()
                    };
                  });
                });
                nextIndex == currentIndex ? _controller1.setLooping(true) : null;
                _controller1.setVolume(0);
                _controller1.play();
                return _videoContent(_controller1);
              } else {
                indexTimer = Timer(const Duration(seconds: 2), () {
                  nextIndex == currentIndex ? null : ref.read(contentIndexProvider.notifier).state = nextIndex;
                });
                return loading();
              }
            }
          }
        }
      })
    );
  }

  bool checkBlocContent(List config){
    int unBlockContent = 0;
    for (var conf in config){
      bool showTime = ConfigImpl().compireTime(conf['start'], conf['end']);
      conf['show'] && showTime ? unBlockContent++ : null;
    }
    return unBlockContent == 0 ? true : false;
  }

  Widget demoMode(){
    String path = '${directory!.path}/bg.mp4';
    _controller1 = VideoPlayerController.file(io.File(path));
    _controller1.initialize();
    _controller1.setVolume(0);
    _controller1.setLooping(true);
    _controller1.play();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayer(_controller1),
    );
  }


  Widget _imageContent(String path){
    return SizedBox(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      child: Image.file(io.File(path), fit: BoxFit.fill,)
    );
  }


  Widget _videoContent(VideoPlayerController controller){
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: VideoPlayer(controller),
    );
  }

  Widget loading(){
    return Center(
      child: SizedBox(
        height: 300,
        width: 300,
        child: DotLottieLoader.fromAsset('lib/images/loading.lottie',
          frameBuilder: (ctx, dotlottie) {
            // return dotlottie != null ? Lottie.memory(dotlottie.animations.values.single) : Container();
            return SizedBox(
              height: 10,
              width: 10,
              child: dotlottie != null ? Lottie.memory(dotlottie.animations.values.single) : Container(),
            );
        }),
      ),
    );
  }

  Widget settingsAppBar(String id, String name){
    return Consumer(
      builder: ((context, ref, child) {

        final containerSize = ref.watch(containerSizeProvider);
        final focusIndex = ref.watch(onFocusIndexProvider);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: MediaQuery.of(context).size.width,
          height: containerSize,
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: $id', style: white18,),
                        Text('Имя: $name', style: const TextStyle(color: Colors.white, fontSize: 18),),
                      ],
                    ),
                  ),
          
                  const Expanded(child: SizedBox(width: 5,)),

                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: focusIndex == 1 ? Colors.white : Colors.blueGrey.shade600,
                    ),
                    child: 
                    TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
                      ),
                      onFocusChange: (bool isFocused) { 
                        isFocused ? {
                          ref.read(onFocusIndexProvider.notifier).state = 1,
                          ref.read(containerSizeProvider.notifier).state = 95,
                        } : null;
                      },
                      onPressed: () { 
                        ref.read(containerSizeProvider.notifier).state = 0;
                        ref.read(onFocusIndexProvider.notifier).state = 999;
                        ref.read(configProvider.notifier).state = {};
                        indexTimer.cancel();
                        initTimer.cancel();
                        _controller1.dispose();
                        _controller2.dispose();
                        controllerName1 = 'BigBuckBunny.mp4'; controllerName2 = 'BigBuckBunny.mp4';
                        return ref.refresh(getConfigProvider); 
                      }, 
                      child: const Text('обновить')
                    ),
                  ),

                  const SizedBox(width: 10,),

                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: focusIndex == 2 ? Colors.white : Colors.blueGrey.shade600,
                    ),
                    child: TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
                      ),
                      onFocusChange: (bool isFocused) { 
                        isFocused ? {
                          ref.read(onFocusIndexProvider.notifier).state = 2,
                          ref.read(containerSizeProvider.notifier).state = 95,
                        } : null;
                      },
                      onPressed: (){ 
                        ref.read(onFocusIndexProvider.notifier).state = 999;
                        ref.read(containerSizeProvider.notifier).state = 0;
                      }, 
                      child: const Text('закрыть')
                    ),
                  ),

                  const SizedBox(width: 10,),

                  InkWell(
                    onFocusChange: (bool isFocused){ 
                      isFocused ? {
                        ref.read(onFocusIndexProvider.notifier).state = 3,
                        ref.read(containerSizeProvider.notifier).state = 95,
                      } : null; 
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: IconButton(
                        onPressed: (){ 
                          ref.read(onFocusIndexProvider.notifier).state = 999;
                          ref.read(containerSizeProvider.notifier).state = 0;
                          _controller1.dispose(); _controller2.dispose();
                          initTimer.cancel(); indexTimer.cancel();
                          _controller1.dispose();
                          _controller2.dispose();
                          controllerName1 = 'BigBuckBunny.mp4'; controllerName2 = 'BigBuckBunny.mp4';
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContentLib())).whenComplete(() { 
                            ref.read(containerSizeProvider.notifier).state = 0;
                            ref.read(onFocusIndexProvider.notifier).state = 999;
                            ref.read(configProvider.notifier).state = {};
                            indexTimer.cancel();
                            initTimer.cancel();
                            _controller1.dispose();
                            _controller2.dispose();
                            controllerName1 = 'BigBuckBunny.mp4'; controllerName2 = 'BigBuckBunny.mp4';
                            return ref.refresh(getConfigProvider); 
                          });
                        }, 
                        icon: const Icon(Icons.photo_library, size: 45,),
                        color: containerSize == 0 ? Colors.transparent : focusIndex == 3 ? Colors.white : Colors.blueGrey.shade600,
                        splashRadius: 1,
                      ),
                    )
                  ),

                  const SizedBox(width: 20,), 
                ],
              ),
            ),
          ),
        );
      })
    );
  }

}