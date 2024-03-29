import 'package:flutter/material.dart';

import '../utils/extensions.dart';

class CopyableListTile extends StatelessWidget {
  const CopyableListTile({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.visualDensity,
  });

  /// A function that returns the text that will be copied to the clipboard.
  final String Function() data;
  final Widget? title;
  final Widget? subtitle;
  final VisualDensity? visualDensity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      onTap: () => context.copy(data()),
      visualDensity: visualDensity,
    );
  }
}
