import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble/characteristics.dart';
import '../utils/extensions.dart';

/// A screen showing all characteristics in a list view, with a floating action button to
/// add a new characteristic item.
class CharacteristicsScreen extends ConsumerWidget {
  const CharacteristicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characteristics = ref.watch(characteristicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Characteristics'),
      ),
      body: ListView.builder(
        itemCount: characteristics.length,
        itemBuilder: (_, index) => _CharacteristicListTile(
          characteristics[index],
          onTap: () => context.showTextSnackBar('Long press to delete'),
          onLongPress: () =>
              ref.read(characteristicsProvider.notifier).deleteAt(index),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/characteristics/add'),
        tooltip: 'Add characteristic',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CharacteristicListTile extends StatelessWidget {
  const _CharacteristicListTile(
    this.characteristic, {
    this.onTap,
    this.onLongPress,
  });

  final AppQualifiedCharacteristic characteristic;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      title: Text(characteristic.name),
    );
  }
}
