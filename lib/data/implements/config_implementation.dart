import 'dart:io';
import 'package:mime/mime.dart';

import '../../domain/config_repository.dart';

class ConfigImpl extends ConfigRepository{

  // получить следующий индекс
  @override
  int getNextIndex(int currentIndex, int loopLength, List config){
    int nextIndex = currentIndex == loopLength - 1 ? 0 : currentIndex + 1;
    return nextIndex;
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

  // сравнить дату в конфигурации с текущим
  @override
  bool compireDate(String startDate, String endDate){
    bool result;
    // Преобразование строк в объекты DateTime
    DateTime dateStartDate = DateTime.parse(formatDateString(startDate));
    DateTime dateEndDate = DateTime.parse(formatDateString(endDate));
    DateTime now = DateTime.now();
    now.isAfter(dateStartDate) && now.isBefore(dateEndDate) ?
      result = true : result = false;
    return result;
  }

  // Преобразование даты из формата dd.MM.yyyy в yyyy-MM-dd
  @override
  String formatDateString(String dateString) {
    List<String> parts = dateString.split('.');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }


  // проверить является ли файл видео
  @override
  bool isImage(String path){
    String mimeType = lookupMimeType(path).toString();
    return mimeType == 'image/jpeg' ? true : false;
  }

}