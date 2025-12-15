import 'package:flutter/material.dart';

class TabContent extends StatefulWidget {
  final title;

  const TabContent({super.key, required this.title});

  @override
  State<TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        widget.title,
        style: TextStyle(fontSize: 22, color: Colors.blueAccent),
      ),
    );
  }
}
