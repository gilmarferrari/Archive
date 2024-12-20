import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color? backgroundColor;
  final bool obscureText;
  final bool enabled;
  final bool displayFloatingLabel;
  final TextInputType? keyboardType;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool expands;

  const CustomFormField({
    required this.label,
    required this.controller,
    required this.icon,
    this.backgroundColor,
    this.keyboardType,
    this.displayFloatingLabel = false,
    this.obscureText = false,
    this.enabled = true,
    this.maxLength,
    this.focusNode,
    this.expands = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Colors.grey[100],
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: TextField(
          maxLength: maxLength,
          minLines: null,
          maxLines: expands ? null : 1,
          expands: expands,
          focusNode: focusNode,
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          enabled: enabled,
          decoration: InputDecoration(
            fillColor: Colors.black12,
            hintText: !displayFloatingLabel ? label : null,
            labelText: displayFloatingLabel ? label : null,
            prefixIcon: Icon(
              icon,
              color: Colors.black54,
              size: 22,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
