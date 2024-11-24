// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class homePageTile extends StatefulWidget {
  final String name;
  final String imagePath;
  final int age;
  final double height;
  final double weight;
  const homePageTile({
    super.key,
    required this.name,
    required this.imagePath,
    required this.age,
    required this.height,
    required this.weight,
  });

  @override
  State<homePageTile> createState() => _homePageTileState();
}

class _homePageTileState extends State<homePageTile> {
  bool isExpanded = false;

  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(
              widget.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(widget.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age: ${widget.age} years'),
                  Text('Height: ${widget.height} cm'),
                  Text('Weight: ${widget.weight} kg'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
