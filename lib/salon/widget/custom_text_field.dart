import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onTap; // Optional: for date pickers etc.
  final bool readOnly; // Optional: for date pickers etc.

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          suffixIcon: suffixIcon,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscureText,
        onTap: onTap,
        readOnly: readOnly,
      ),
    );
  }
}
