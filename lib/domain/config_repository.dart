import 'dart:io';

abstract class ConfigRepository{

  // получить следующий индекс
  int getNextIndex(int currentIndex, int loopLength, List config);

  // получить путь к файлу следующего индекса
  String getNextPath(List config, int nextIndex, Directory directory);

  // сравнить время в конфигурации с текущим
  bool compireTime(String startTime, String endTime);

  // сравнить дату в конфигурации с текущим
  bool compireDate(String startDate, String endDate);

  // Преобразование даты из формата dd.MM.yyyy в yyyy-MM-dd
  String formatDateString(String dateString);

  // определить тип файла, видео или изображение
  bool isImage(String path);

}