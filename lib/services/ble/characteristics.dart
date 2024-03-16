import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'characteristics.freezed.dart';
part 'characteristics.g.dart';

@riverpod
class Characteristics extends _$Characteristics {
  final _box = Hive.box<HiveQualifiedCharacteristic>('characteristics');

  @override
  List<QualifiedCharacteristic> build() {
    return [for (final c in _box.values) c.toQualifiedCharacteristic()];
  }

  void add(QualifiedCharacteristic characteristic) {
    _box.add(
      HiveQualifiedCharacteristic.fromQualifiedCharacteristic(characteristic),
    );
    ref.invalidateSelf();
  }

  void deleteAt(int index) {
    _box.deleteAt(index);
    ref.invalidateSelf();
  }
}

@freezed
@HiveType(typeId: 0)
class HiveQualifiedCharacteristic with _$HiveQualifiedCharacteristic {
  const factory HiveQualifiedCharacteristic({
    @HiveField(0) required Uint8List characteristicId,
    @HiveField(1) required Uint8List serviceId,
    @HiveField(2) required String deviceId,
  }) = _HiveQualifiedCharacteristic;

  const HiveQualifiedCharacteristic._();

  static HiveQualifiedCharacteristic fromQualifiedCharacteristic(
    QualifiedCharacteristic characteristic,
  ) =>
      HiveQualifiedCharacteristic(
        characteristicId: characteristic.characteristicId.data,
        serviceId: characteristic.serviceId.data,
        deviceId: characteristic.deviceId,
      );

  QualifiedCharacteristic toQualifiedCharacteristic() =>
      QualifiedCharacteristic(
        characteristicId: Uuid(characteristicId),
        serviceId: Uuid(serviceId),
        deviceId: deviceId,
      );
}
