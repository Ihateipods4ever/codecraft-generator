import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color color;
  final double size;

  const CustomIconWidget({
    Key? key,
    required this.iconName,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      // You'll need to map iconName string to an actual IconData
      // For now, I'll use a placeholder icon.
      Icons.error,
      color: color,
      size: size,
    );
  }
}