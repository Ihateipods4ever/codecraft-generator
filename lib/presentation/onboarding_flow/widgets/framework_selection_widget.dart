// lib/presentation/onboarding_flow/widgets/framework_selection_widget.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// CORRECTED IMPORTS:

// For AppTheme (assuming AppTheme is defined in lib/core/app_export.dart)
import '../../../core/app_export.dart';

// For CustomIconWidget (assuming CustomIconWidget is in lib/widgets/custom_icon_widget.dart)


class FrameworkSelectionWidget extends StatefulWidget {
  const FrameworkSelectionWidget({Key? key}) : super(key: key);

  @override
  State<FrameworkSelectionWidget> createState() => _FrameworkSelectionWidgetState();
}

class _FrameworkSelectionWidgetState extends State<FrameworkSelectionWidget> {
  // Mock data for frameworks. Replace with your actual data source if dynamic.
  final List<Map<String, dynamic>> _frameworksData = [
    {
      'name': 'React',
      'description': 'A JavaScript library for building user interfaces.',
      'icon': 'react_logo', // Ensure 'react_logo' resolves to an actual icon
      'color': Colors.blue,
    },
    {
      'name': 'Vue.js',
      'description': 'The Progressive JavaScript Framework.',
      'icon': 'vue_logo', // Ensure 'vue_logo' resolves to an actual icon
      'color': Colors.green,
    },
    {
      'name': 'Angular',
      'description': 'The web framework for everyone.',
      'icon': 'angular_logo', // Ensure 'angular_logo' resolves to an actual icon
      'color': Colors.red,
    },
    {
      'name': 'Node.js',
      'description': 'JavaScript runtime built on Chrome\'s V8 JavaScript engine.',
      'icon': 'nodejs_logo', // Ensure 'nodejs_logo' resolves to an actual icon
      'color': Colors.lightGreen,
    },
    {
      'name': 'Python',
      'description': 'A versatile language for web, AI, and data science.',
      'icon': 'python_logo', // Ensure 'python_logo' resolves to an actual icon
      'color': Colors.yellow,
    },
    // Add more frameworks as needed to test scrolling
    {
      'name': 'Flutter',
      'description': 'Google\'s UI toolkit for building natively compiled applications.',
      'icon': 'flutter_logo',
      'color': Colors.lightBlueAccent,
    },
    {
      'name': 'Swift/iOS',
      'description': 'Develop native iOS applications with Swift.',
      'icon': 'apple_logo',
      'color': Colors.grey,
    },
    {
      'name': 'Kotlin/Android',
      'description': 'Modern language for Android app development.',
      'icon': 'android_logo',
      'color': Colors.greenAccent,
    },
  ];

  final List<String> _selectedFrameworks = [];

  void _toggleFramework(String frameworkName) {
    setState(() {
      if (_selectedFrameworks.contains(frameworkName)) {
        _selectedFrameworks.remove(frameworkName);
      } else {
        _selectedFrameworks.add(frameworkName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional: Add a title or introductory text here
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Text(
            'Select your preferred frameworks:',
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
        ),

        Wrap(
          spacing: 2.w,
          runSpacing: 2.h,
          children: _frameworksData.map((framework) {
            final bool isSelected = _selectedFrameworks.contains(framework['name']);
            return GestureDetector(
              onTap: () => _toggleFramework(framework['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primaryContainer
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: (framework['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget( // This will now be recognized
                        iconName: framework['icon'],
                        size: 20,
                        color: framework['color'],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            framework['name'],
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            framework['description'],
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      CustomIconWidget( // This will now be recognized
                        iconName: 'check_circle',
                        size: 16,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        if (_selectedFrameworks.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Text(
              '${_selectedFrameworks.length} framework${_selectedFrameworks.length == 1 ? '' : 's'} selected',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}