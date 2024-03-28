import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'characteristics.freezed.dart';
part 'characteristics.g.dart';

@riverpod
class Characteristics extends _$Characteristics {
  late final _box = Hive.box<AppQualifiedCharacteristic>('characteristics');

  @override
  List<AppQualifiedCharacteristic> build() {
    return _box.values.toList();
  }

  void add(AppQualifiedCharacteristic characteristic) {
    _box.add(characteristic);
    ref.invalidateSelf();
  }

  void editAt(int index, AppQualifiedCharacteristic characteristic) {
    _box.putAt(index, characteristic);
    ref.invalidateSelf();
  }

  void deleteAt(int index) {
    _box.deleteAt(index);
    ref.invalidateSelf();
  }
}

@freezed
@HiveType(typeId: 0)
class AppQualifiedCharacteristic with _$AppQualifiedCharacteristic {
  const factory AppQualifiedCharacteristic({
    @HiveField(0) required Uint8List characteristicId,
    @HiveField(1) required Uint8List serviceId,
    @HiveField(2) required String deviceId,
    @HiveField(3) @Default('') final String name,
  }) = _AppQualifiedCharacteristic;

  const AppQualifiedCharacteristic._();

  static AppQualifiedCharacteristic fromQualifiedCharacteristic(
    QualifiedCharacteristic characteristic, {
    String name = '',
  }) =>
      AppQualifiedCharacteristic(
        characteristicId: characteristic.characteristicId.data,
        serviceId: characteristic.serviceId.data,
        deviceId: characteristic.deviceId,
        name: name,
      );

  QualifiedCharacteristic toQualifiedCharacteristic() =>
      QualifiedCharacteristic(
        characteristicId: Uuid(characteristicId),
        serviceId: Uuid(serviceId),
        deviceId: deviceId,
      );
}

extension AppQualifiedCharacteristicX on AppQualifiedCharacteristic {
  String get shortCharacteristicId => characteristicId.toShortString();
  String get shortServiceId => serviceId.toShortString();
  String get shortDeviceId => deviceId.substring(12);
}

extension on Uint8List {
  String toShortString() => Uuid(this).toString().split('-').first;
}
