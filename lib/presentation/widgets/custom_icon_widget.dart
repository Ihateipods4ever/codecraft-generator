import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double? size;

  const CustomIconWidget({
    Key? key,
    required this.iconName,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (iconName) {
      case 'code':
        iconData = Icons.code;
        break;
      case 'add_circle':
        iconData = Icons.add_circle;
        break;
      case 'shopping_cart':
        iconData = Icons.shopping_cart;
        break;
      case 'task_alt':
        iconData = Icons.task_alt;
        break;
      case 'wb_sunny':
        iconData = Icons.wb_sunny;
        break;
      case 'arrow_forward_ios':
        iconData = Icons.arrow_forward_ios;
        break;
      // You can add more icon cases here
      default:
        iconData = Icons.error; // A default icon for any unknown names
    }

    return Icon(
      iconData,
      color: color,
      size: size,
    );
  }
}