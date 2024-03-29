import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble/characteristics.dart';
import 'extensions.dart';

Future<AppQualifiedCharacteristic?> showCharacteristicsSheet(
  BuildContext context, {
  bool selectable = false,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<AppQualifiedCharacteristic?>(
    context: context,
    useRootNavigator: useRootNavigator,
    showDragHandle: true,
    builder: (_) {
      return _CharacteristicsSheet(selectable: selectable);
    },
  );
}

class _CharacteristicsSheet extends ConsumerWidget {
  const _CharacteristicsSheet({this.selectable = false});

  final bool selectable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characteristics = ref.watch(characteristicsProvider);

    void addCharacteristic() {
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: ((context) {
          return const _AddCharacteristicDialog();
        }),
      );
    }

    return PaddedColumn(
      padding: const EdgeInsets.only(bottom: 24),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          selectable ? 'Select characteristic' : 'Characteristics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Divider(),
        for (final (index, characteristic) in characteristics.indexed)
          _CharacteristicListTile(
            index,
            characteristic,
            onTap: selectable
                ? () => Navigator.of(context).pop(characteristic)
                : null,
          ),
        ListTile(
          onTap: addCharacteristic,
          leading: const Icon(Icons.add),
          title: const Text('Add new characteristic'),
        ),
      ],
    );
  }
}

class _AddCharacteristicDialog extends HookConsumerWidget {
  const _AddCharacteristicDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final characteristicIdController = useTextEditingController();
    final serviceIdController = useTextEditingController();
    final deviceIdController = useTextEditingController();

    void saveCharacteristic() {
      try {
        ref
            .read(characteristicsProvider.notifier)
            .add(AppQualifiedCharacteristic(
              characteristicId:
                  Uuid.parse(characteristicIdController.text).data,
              serviceId: Uuid.parse(serviceIdController.text).data,
              deviceId: deviceIdController.text,
              name: nameController.text,
            ));
        Navigator.of(context).pop();
      } on Exception catch (e) {
        context.showTextSnackBar(e.toString());
      }
    }

    return AlertDialog(
      title: const Text('Add Characteristic'),
      content: SingleChildScrollView(
        child: SeparatedColumn(
          separatorBuilder: () => const Gap(16),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: characteristicIdController,
              decoration: const InputDecoration(
                labelText: 'Characteristic ID',
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: serviceIdController,
              decoration: const InputDecoration(
                labelText: 'Service ID',
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: deviceIdController,
              decoration: const InputDecoration(
                labelText: 'Device ID',
                isDense: true,
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: saveCharacteristic,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CharacteristicListTile extends StatelessWidget {
  const _CharacteristicListTile(this.index, this.characteristic, {this.onTap});

  final int index;
  final AppQualifiedCharacteristic characteristic;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    void editCharacteristic() {
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: ((context) {
          return _EditCharacteristicDialog(index, characteristic);
        }),
      );
    }

    return ListTile(
      onTap: onTap,
      title: Text(characteristic.name),
      subtitle: Text(
        characteristic.shortDescription,
      ),
      trailing: IconButton(
        onPressed: editCharacteristic,
        icon: const Icon(Icons.edit),
      ),
    );
  }
}

class _EditCharacteristicDialog extends HookConsumerWidget {
  const _EditCharacteristicDialog(this.index, this.characteristic);

  final int index;
  final AppQualifiedCharacteristic characteristic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: characteristic.name);
    final characteristicIdController = useTextEditingController(
        text: Uuid(characteristic.characteristicId).toString());
    final serviceIdController = useTextEditingController(
        text: Uuid(characteristic.serviceId).toString());
    final deviceIdController =
        useTextEditingController(text: characteristic.deviceId);

    void saveCharacteristic() {
      try {
        ref.read(characteristicsProvider.notifier).editAt(
            index,
            AppQualifiedCharacteristic(
              characteristicId:
                  Uuid.parse(characteristicIdController.text).data,
              serviceId: Uuid.parse(serviceIdController.text).data,
              deviceId: deviceIdController.text,
              name: nameController.text,
            ));
        Navigator.of(context).pop();
      } on Exception catch (e) {
        context.showTextSnackBar(e.toString());
      }
    }

    void deleteCharacteristic() {
      ref.read(characteristicsProvider.notifier).deleteAt(index);
      Navigator.of(context).pop();
    }

    return AlertDialog(
      title: const Text('Edit Characteristic'),
      content: SingleChildScrollView(
        child: SeparatedColumn(
          separatorBuilder: () => const Gap(16),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: characteristicIdController,
              decoration: const InputDecoration(
                labelText: 'Characteristic ID',
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: serviceIdController,
              decoration: const InputDecoration(
                labelText: 'Service ID',
                isDense: true,
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: deviceIdController,
              decoration: const InputDecoration(
                labelText: 'Device ID',
                isDense: true,
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: deleteCharacteristic,
          child: Text(
            'Delete',
            style: TextStyle(color: context.colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: saveCharacteristic,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
