import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
class RssiThreshold extends _$RssiThreshold {
  @override
  double build() => -80;

  void set(double value) => state = value;
}
