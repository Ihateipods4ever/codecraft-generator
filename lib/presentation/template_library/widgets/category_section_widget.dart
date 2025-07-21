import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart'; // Sizer is not used directly in this widget, can be removed if not needed elsewhere

import '../../../core/app_export.dart';
import 'template_card_widget.dart'; // Assuming this import is needed

class CategorySectionWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final List<Map<String, dynamic>> templates;
  final Function(Map<String, dynamic>) onTemplatePreview;
  final Function(String, String) onToggleFavorite;
  final VoidCallback? onViewAll; // <--- ADD THIS LINE: New callback for View All button

  const CategorySectionWidget({
    Key? key,
    required this.category,
    required this.templates,
    required this.onTemplatePreview,
    required this.onToggleFavorite,
    this.onViewAll, // <--- ADD THIS LINE: Initialize the new callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Consistent horizontal padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title Row (Icon, Name, View All Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the middle
            children: [
              CustomIconWidget(
                iconName: category["icon"],
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24.0, // Slightly reduced icon size for better balance
              ),
              const SizedBox(width: 12.0), // Adjusted spacing
              Expanded( // Ensures category name takes available space
                child: Text(
                  category["name"],
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700, // Made font bolder
                    fontSize: 18.0, // Adjusted font size for prominence
                  ),
                  overflow: TextOverflow.ellipsis, // Truncate long names
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12.0), // Adjusted spacing
              if (onViewAll != null) // Only show button if callback is provided
                TextButton(
                  onPressed: onViewAll, // <--- USE THE NEW CALLBACK HERE
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove default text button padding
                    minimumSize: Size.zero, // Remove default minimum size
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
                  ),
                  child: Text(
                    'View All (${category["count"]})',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600, // Made font bolder
                      fontSize: 14.0, // Adjusted font size
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0), // Spacing below the title row and before the list
          // Horizontal List of Templates
          SizedBox(
            height: 200.0, // Fixed height for the horizontal list of templates
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: templates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16.0), // Fixed spacing between cards
              itemBuilder: (context, index) {
                final template = templates[index];
                return TemplateCardWidget(
                  template: template,
                  onTap: () => onTemplatePreview(template),
                  onFavorite: () => onToggleFavorite(template["id"], category["name"]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}