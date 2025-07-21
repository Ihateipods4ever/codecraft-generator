import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // Import sizer for responsive units

// ignore_for_file: must_be_immutable
class FrameworkSelectionWidget extends StatefulWidget {
  FrameworkSelectionWidget({
    Key? key,
    required this.onFrameworkSelected,
  }) : super(key: key);
  Function(String) onFrameworkSelected;
  @override
  FrameworkSelectionWidgetState createState() =>
      FrameworkSelectionWidgetState();
}

class FrameworkSelectionWidgetState extends State<FrameworkSelectionWidget> {
  int selectedFrameworkIndex = -1;
  final List<Map<String, dynamic>> frameworks = [
    {
      'name': 'Flutter',
      'icon': Icons.flutter_dash,
      'color': Colors.blue,
    },
    {
      'name': 'React Native',
      'icon': Icons.mobile_friendly,
      'color': Colors.cyan,
    },
    {
      'name': 'Native Android',
      'icon': Icons.android,
      'color': Colors.green,
    },
    {
      'name': 'Native iOS',
      'icon': Icons.apple,
      'color': Colors.grey,
    },
    {
      'name': 'Vanilla JS',
      'icon': Icons.javascript,
      'color': Colors.yellow,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w), // Use sizer unit
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Your Framework",
            style: Theme.of(context).textTheme.headlineMedium, // Use Theme.of(context)
          ),
          SizedBox(height: 20.h), // Use sizer unit
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: frameworks.length,
            itemBuilder: (context, index) {
              final framework = frameworks[index];
              final isSelected = selectedFrameworkIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFrameworkIndex = index;
                  });
                  widget.onFrameworkSelected(framework['name']);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16.h), // Use sizer unit
                  padding: EdgeInsets.all(16.w), // Use sizer unit
                  decoration: BoxDecoration(
                    color: isSelected ? framework['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(8.w), // Use sizer unit
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        framework['icon'] as IconData,
                        color: isSelected ? Colors.white : framework['color'],
                        size: 40.w, // Use sizer unit
                      ),
                      SizedBox(width: 16.w), // Use sizer unit
                      Text(
                        framework['name'],
                        style: TextStyle(
                          fontSize: 18.sp, // Use sizer unit
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
