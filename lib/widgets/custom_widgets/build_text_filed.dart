import 'package:flutter/material.dart';

Widget buildTextField(
    String label, TextEditingController controller, IconData icon,
    {int maxLines = 1}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Lütfen $label girin.';
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    ),
  );
}
