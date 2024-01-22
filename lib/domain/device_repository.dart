abstract class DeviceRepository{

  //получаем данные о девайсе
  Future<String> getCurrentDeviceId();

  // удаляем весь контент с устройства
  Future<void> deleteAllContents();

}