import 'dart:io';
import 'package:mime/mime.dart';

import '../../domain/config_repository.dart';

class ConfigImpl extends ConfigRepository{

  // получить следующий индекс
  @override
  int getNextIndex(int currentIndex, int loopLength, List config){

    bool continueLoop = true;
    int returnIndex = 0;
    int nextIndex = currentIndex == loopLength - 1 ? 0 : currentIndex + 1;
    
    while (continueLoop){
      String startTime = config[nextIndex]['start'];
      String endTime = config[nextIndex]['end'];
      bool show = config[nextIndex]['show'];
      bool showTime = compireTime(startTime, endTime);
      if (show && showTime){
        returnIndex = nextIndex;
        continueLoop = false;
      } else {
        nextIndex == loopLength - 1 ? nextIndex = 0 : nextIndex = nextIndex + 1;
      }
    }
    return returnIndex;
  }

  // получить путь к файлу следующего индекса
  @override
  String getNextPath(List config, int nextIndex, Directory directory){
    return '${directory.path}/${config[nextIndex]['name']}';
  }

  // сравнить время в конфигурации с текущим
  @override
  bool compireTime(String startTime, String endTime){
    DateTime now = DateTime.now();
    String currentDate = now.toString().split(' ')[0];
    DateTime start = DateTime.parse('$currentDate $startTime');
    DateTime end = DateTime.parse('$currentDate $endTime');
    return start.isBefore(now) && now.isBefore(end);
  }

  // проверить является ли файл видео
  @override
  bool isImage(String path){
    String mimeType = lookupMimeType(path).toString();
    return mimeType == 'image/jpeg' ? true : false;
  }

}