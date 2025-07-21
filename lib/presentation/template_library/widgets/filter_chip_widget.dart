import 'package:flutter/material.dart';
// Still using sizer for potential future responsive needs, but not for direct sizing here

import '../../../core/app_export.dart'; // Assuming AppTheme is here

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Fixed padding
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary // Purple for selected
              : AppTheme.lightTheme.colorScheme.surface, // White for unselected
          borderRadius: BorderRadius.circular(20.0), // More rounded corners
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary // Purple border for selected
                : AppTheme.lightTheme.dividerColor, // Grey border for unselected
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.onPrimary // White text for selected
                : AppTheme.lightTheme.colorScheme.onSurface, // Dark text for unselected
            fontSize: 14.0, // Fixed font size
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
