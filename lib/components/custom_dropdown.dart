import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final IconData icon;
  final List<T> list;
  final T? value;
  final String label;
  final String? title;
  final bool includeAll;
  final bool enabled;
  final Color? backgroundColor;
  final Function(T? value) onChanged;

  const CustomDropdown({
    required this.icon,
    required this.list,
    required this.value,
    required this.onChanged,
    this.backgroundColor,
    this.includeAll = false,
    this.enabled = true,
    this.label = '',
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.grey[100],
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Icon(icon, color: !enabled ? Colors.grey : Colors.black54),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: title != null ? 8 : 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            DropdownButtonHideUnderline(
              child: DropdownButton<T?>(
                hint: const Text('Selecione uma opção'),
                value: value,
                items: [
                  if (includeAll)
                    const DropdownMenuItem(
                      value: null,
                      child: Text(
                        'Todos',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ...list.map((v) => DropdownMenuItem<T>(
                        value: v,
                        child: Text(
                          '$label $v'.trim(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ))
                ],
                onChanged: enabled ? (v) => onChanged(v) : null,
              ),
            ),
          ]),
        )
      ]),
    );
  }
}
