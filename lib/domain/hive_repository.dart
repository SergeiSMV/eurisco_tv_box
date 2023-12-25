

abstract class HiveRepository{

  // сохранить логин / пароль
  Future<void> saveAuthData(Map authData);

  // получить логин / пароль
  Future<Map> getAuthData();

  //сохраняем ссылки файлов
  Future<void> saveConfig(List config);

  //сохраняем имя устройства
  Future<void> saveDeviceName(String name);

  //получить ссылки файлов
  Future<List> getConfig();

  //получить имя устройства
  Future<String> getDeviceName();

}