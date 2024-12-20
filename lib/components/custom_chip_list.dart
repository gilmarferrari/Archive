import 'package:flutter/material.dart';
import 'custom_chip.dart';

class CustomChipList<T> extends StatefulWidget {
  final String? label;
  final List<T> items;
  final T? initiallySelectedItem;
  final Function(T) onSelect;

  const CustomChipList({
    required this.items,
    required this.onSelect,
    this.label,
    this.initiallySelectedItem,
  });

  @override
  State<CustomChipList<T>> createState() => _CustomChipListState<T>();
}

class _CustomChipListState<T> extends State<CustomChipList<T>> {
  late T? _selectedValue = widget.initiallySelectedItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label != null)
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 5),
            child: Text('${widget.label}'),
          ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.items.length,
            itemBuilder: ((context, index) {
              var item = widget.items[index];

              return CustomChip(
                value: item,
                onTap: () => onSelect(item),
                isSelected: item == _selectedValue,
              );
            }),
          ),
        ),
      ],
    );
  }

  onSelect(T item) {
    setState(() => _selectedValue = item);
    widget.onSelect(item);
  }
}
