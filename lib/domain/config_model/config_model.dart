
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_model.freezed.dart';
part 'config_model.g.dart';

@freezed
class ConfigModel with _$ConfigModel {
  const ConfigModel._();
  const factory ConfigModel({
    required Map<String, dynamic> configModel,
  }) = _ConfigModel;

  factory ConfigModel.fromJson(Map<String, dynamic> json) => _$ConfigModelFromJson(json);

  String get name => configModel['name'];
  int get duration => configModel['duration'];
  bool get show => configModel['show'];
  String get startTime => configModel['start_time'];
  String get endTime => configModel['end_time'];
  String get startDate => configModel['start_date'];
  String get endDate => configModel['end_date'];
  String get preview => configModel['preview'];
  String get stream => configModel['stream'];
}