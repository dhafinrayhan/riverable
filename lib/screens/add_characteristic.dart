import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ble/characteristics.dart';
import '../utils/extensions.dart';

class AddCharacteristicScreen extends HookConsumerWidget {
  const AddCharacteristicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characteristicIdController = useTextEditingController();
    final serviceIdController = useTextEditingController();
    final deviceIdController = useTextEditingController();

    void addCharacteristic() {
      try {
        ref.read(characteristicsProvider.notifier).add(QualifiedCharacteristic(
              characteristicId: Uuid.parse(characteristicIdController.text),
              serviceId: Uuid.parse(serviceIdController.text),
              deviceId: deviceIdController.text,
            ));
        context.go('/characteristics');
      } on Exception catch (e) {
        context.showTextSnackBar(e.toString());
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Characteristic'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: addCharacteristic,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SeparatedColumn(
          padding: const EdgeInsets.all(24),
          separatorBuilder: () => const Gap(16),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: characteristicIdController,
              decoration: const InputDecoration(
                labelText: 'Characteristic ID',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: serviceIdController,
              decoration: const InputDecoration(
                labelText: 'Service ID',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: deviceIdController,
              decoration: const InputDecoration(
                labelText: 'Device ID',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
