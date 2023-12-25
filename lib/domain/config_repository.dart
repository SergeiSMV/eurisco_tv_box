import 'dart:io';

abstract class ConfigRepository{

  // получить следующий индекс
  int getNextIndex(int currentIndex, int loopLength, List config);

  // получить путь к файлу следующего индекса
  String getNextPath(List config, int nextIndex, Directory directory);

  // сравнить время в конфигурации с текущим
  bool compireTime(String startTime, String endTime);

  // определить тип файла, видео или изображение
  bool isImage(String path);

}