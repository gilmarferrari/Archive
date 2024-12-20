import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final String label;
  final bool checked;
  final bool enabled;
  final void Function(bool?) onChecked;

  const CustomCheckbox({
    required this.label,
    required this.checked,
    required this.onChecked,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Row(children: [
        Checkbox(value: checked, onChanged: enabled ? onChecked : null),
        Text(
          label,
          style: TextStyle(color: enabled ? null : Colors.grey),
        ),
      ]),
    );
  }
}
