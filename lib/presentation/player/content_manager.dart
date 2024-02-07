import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/implements/config_implementation.dart';
import '../../data/providers.dart';
import 'demo_mode.dart';
import 'new_content_player.dart';

class ContentManager extends ConsumerStatefulWidget {
  final List allContents;
  const ContentManager({super.key, required this.allContents});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentPlayerState();
}

class _ContentPlayerState extends ConsumerState<ContentManager> {


  Timer? monitoring;

  @override
  void initState() {
    scheduleContent();
    super.initState();
  }

  @override
  void dispose() async {
    monitoring?.cancel();
    super.dispose();
  }

  void scheduleContent() {
    if (monitoring != null) {
      monitoring!.cancel();
    }
    List forDisplay = ref.read(contentForDisplayProvider);
    List contentForShow = [];
    monitoring = Timer(const Duration(seconds: 10), () {
      for (var con in widget.allContents){
        bool show = con['show'];
        bool time = ConfigImpl().compireTime(con['start_time'], con['end_time']);
        bool date = ConfigImpl().compireDate(con['start_date'], con['end_date']);
        show && time && date ? contentForShow.add(con) : null;
      }
      
      String jsonContentForShow = jsonEncode(contentForShow);
      String jsonContentForDisplay = jsonEncode(forDisplay);
      // Set.from(contentForShow).containsAll(forDisplay) && Set.from(forDisplay).containsAll(contentForShow) 
      jsonContentForShow == jsonContentForDisplay ?
      null : {
        ref.read(contentForDisplayProvider.notifier).state = [].toList(),
        ref.read(contentIndexProvider.notifier).state = 0,
        ref.read(contentForDisplayProvider.notifier).state = contentForShow.toList(),
      };

      scheduleContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {

        List contentForDispaly = ref.watch(contentForDisplayProvider);

        return contentForDispaly.isEmpty ?
        const DemoMode(title: '',) : 
        // ContentPlayer(contentForDisplay: contentForDispaly, key: ValueKey(contentForDispaly.length),);
        NewContentPlayer(contentForDisplay: contentForDispaly, key: ValueKey(contentForDispaly.length),);
      }
    );
  }
}