import 'package:flutter/material.dart';
import 'custom_chip.dart';

class CustomMultiSelectChipList<T> extends StatefulWidget {
  final String? label;
  final List<T> availableItems;
  final List<T> initiallySelectedItems;
  final void Function(List<T>) onSelect;
  final bool enabled;

  const CustomMultiSelectChipList({
    required this.availableItems,
    required this.initiallySelectedItems,
    required this.onSelect,
    this.label,
    this.enabled = true,
  });

  @override
  State<CustomMultiSelectChipList<T>> createState() =>
      _CustomMultiSelectChipListState<T>();
}

class _CustomMultiSelectChipListState<T>
    extends State<CustomMultiSelectChipList<T>> {
  late final List<T> _selectedItems = widget.initiallySelectedItems;

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
            itemCount: widget.availableItems.length,
            itemBuilder: ((context, index) {
              T item = widget.availableItems[index];

              return CustomChip(
                value: item,
                onTap: widget.enabled ? () => onSelect(item) : null,
                isSelected: _selectedItems.contains(item),
                showCheckIcon: true,
              );
            }),
          ),
        ),
      ],
    );
  }

  onSelect(T item) {
    if (_selectedItems.contains(item)) {
      setState(() => _selectedItems.remove(item));
    } else {
      setState(() => _selectedItems.add(item));
    }

    widget.onSelect(_selectedItems);
  }
}
