import 'dart:async';

import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../colors.dart';
import '../data/providers.dart';
import '../domain/config_model/config_model.dart';
import 'player/preview_player.dart';

class ActionIntent extends Intent {}

class ContentLib extends ConsumerStatefulWidget {
  final Map deviceConfig;
  const ContentLib({super.key, required this.deviceConfig});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentLibState();
}

class _ContentLibState extends ConsumerState<ContentLib> {

  // Timer timer = Timer(const Duration(seconds: 0), () { null; });
  // late String _timeString;

  @override
  void initState() {
    // _timeString = _formatDateTime(DateTime.now());
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  void dispose() async {
    // timer.cancel();
    super.dispose();
  }

  /*
  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }
  */

  @override
  Widget build(BuildContext context) {

    // ref.watch(getConfigProvider);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select) : const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActionIntent: CallbackAction(onInvoke: (Intent i) => null),
        },
        child: GestureDetector(
          onPanDown: (details) async {
            ref.read(configProvider.notifier).state = {};
            ref.read(onFocusIndexProvider.notifier).state = 999;
            return Future.delayed(const Duration(seconds: 3), () {
              return ref.refresh(getConfigProvider);
            });
          },
          child: Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  opacity: 0.7,
                  image: AssetImage('lib/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Consumer(
                builder: (context, ref, child) {

                  final focusIndex = ref.watch(onFocusIndexProvider);
            
                  return widget.deviceConfig.isEmpty ? loading() :
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
        
                      Row(
                        verticalDirection: VerticalDirection.down,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20, left: 25),
                                child: Text('ID: ${widget.deviceConfig['deviceID']}', style: firm18,),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text('Имя: ${widget.deviceConfig['deviceName']}', style: firm18,),
                              ),
                            ],
                          ),
                          // const SizedBox(width: 50,),
                          // Text(_timeString, style: firm18)
                        ],
                      ),                      
        
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.1,
                              crossAxisCount: 3
                            ),
                            itemCount: widget.deviceConfig['content'].length,
                            itemBuilder: (context, index){

                              ConfigModel config = ConfigModel(configModel: Map<String, dynamic>.from(widget.deviceConfig['content'][index]));

                              return InkWell(
                                onFocusChange: (bool isFocused){
                                  isFocused ? ref.read(onFocusIndexProvider.notifier).state = index : null;
                                },
                                onTap: (){ 
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PreviewPlayer(content: widget.deviceConfig['content'][index])));
                                },
                                overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(0),
                                          border: Border.all(color: focusIndex == index ? firmColor : Colors.transparent.withOpacity(0), width: 2),
                                          color: Colors.transparent,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Stack(
                                            alignment: AlignmentDirectional.center,
                                            children: [
                                              AspectRatio(
                                                aspectRatio: 16.0 / 9.0,
                                                child: FittedBox(
                                                  fit: BoxFit.fill,
                                                  child: Image.network(config.preview)
                                                )
                                              ),
                                              Positioned.fill(
                                                child: Container(
                                                  color: focusIndex == index ? Colors.transparent.withOpacity(0) : Colors.white60,
                                                ),
                                              ),
                                              focusIndex == index ?
                                              Center(
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: firmColor,
                                                  child: const Icon(
                                                    Icons.play_arrow, size: 55,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ) : const SizedBox.shrink()
                                            ],
                                          ),
                                        )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(config.name, style: firm18,),
                                      ),

                                      config.show ? const SizedBox.shrink() :
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text('показ на устройстве запрещен', style: firm14)
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text('дата: с ${config.startDate} по ${config.endDate}', style: firm14)
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text('время: с ${config.startTime} до ${config.endTime}', style: firm14)
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
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


}