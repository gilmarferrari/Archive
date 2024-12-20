import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class CustomChip extends StatelessWidget {
  final dynamic value;
  final bool isSelected;
  final bool showCheckIcon;
  final Function()? onTap;

  const CustomChip({
    required this.value,
    required this.onTap,
    this.isSelected = false,
    this.showCheckIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: Chip(
              avatar: showCheckIcon && isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
              backgroundColor:
                  isSelected ? AppConstants.primaryColor : Colors.grey[300],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              label: Text(
                '$value',
                style: TextStyle(
                  color:
                      isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
              )),
        ));
  }
}
