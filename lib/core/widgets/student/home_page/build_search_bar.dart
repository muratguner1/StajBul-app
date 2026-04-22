import 'package:flutter/material.dart';

Widget buildSearchBar({
  required Function(String) onChanged,
  required VoidCallback onFilterTap,
}) {
  return Row(
    children: [
      Expanded(
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: "Pozisyon veya teknoloji ara...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
      const SizedBox(width: 12),
      InkWell(
        onTap: onFilterTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2E3A59),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.filter_list,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}
