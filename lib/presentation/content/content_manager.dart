import 'dart:async';
import 'dart:io' as io;

import 'package:eurisco_tv_box/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../data/providers.dart';



class ContentManager extends ConsumerStatefulWidget {
  final List content;
  const ContentManager({super.key, required this.content});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentManagerState();
}

class _ContentManagerState extends ConsumerState<ContentManager> {

  VideoPlayerController _controller1 = VideoPlayerController.networkUrl(
    Uri.parse('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'))..initialize();

  VideoPlayerController _controller2 = VideoPlayerController.networkUrl(
    Uri.parse('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'))..initialize();

  late final io.Directory? directory;
  String useController = '_controller1';
  Timer? _timer;

  @override
  void initState() {
    initialization();
    super.initState();
  }

  @override
  void dispose() async {
    _controller1.dispose();
    _controller1.dispose();
    super.dispose();
  }

  Future initialization() async {
    directory = await getExternalStorageDirectory();
  }

  void scheduleNextPage(int duration, int currentPage) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(seconds: duration), () {
      if (currentPage < widget.content.length - 1) {
        ref.read(contentIndexProvider.notifier).state = currentPage++;
      } else {
        ref.read(contentIndexProvider.notifier).state = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final currentIndex = ref.watch(contentIndexProvider);

    return Consumer(
      builder: (context, ref, child){
        
        String mimeType = lookupMimeType('${directory!.path}/${widget.content[currentIndex]['name']}').toString();
        

        
        
        
        
        return PageView.builder(
          itemCount: widget.content.length,
          itemBuilder: (context, index){
            return Center(child: Text('${widget.content[index]['name']}', style: white14,));
          }
        );


      }
    );
  }






}















/*
Widget contentManager(BuildContext mainContext, List content, Directory? directory){

  return ProviderScope(
    parent: ProviderScope.containerOf(mainContext),
    child: Consumer(
      builder: (context, ref, child){
        final currentIndex = ref.watch(contentIndexProvider);
        final loopLength = ref.watch(loopLengthProvider);

        // return Center(child: Text('загрузка...', style: white18));

        if(content.isEmpty){
          String path = '${directory!.path}/bg.mp4';

        }



      }
    ),
  );

}
*/
