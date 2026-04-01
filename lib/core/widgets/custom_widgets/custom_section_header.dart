import 'package:flutter/material.dart';

class CustomSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const CustomSectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent.shade700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
