import 'package:flutter/material.dart';

Widget buildSearchBar() {
  //arama çubuğunu düzenle
  return Row(
    children: [
      Expanded(
        child: TextField(
          decoration: InputDecoration(
            hintText: "Pozisyon veya şirket ara...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefix: Icon(Icons.search, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
      SizedBox(width: 12),
      Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Color(0xFF2E3A59),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.filter_list,
          color: Colors.white,
        ),
      ),
    ],
  );
}
