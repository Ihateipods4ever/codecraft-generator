import 'package:flutter/material.dart';
// Corrected: The import paths were adjusted to correctly locate the files
// from within the 'presentation/template_library/widgets' directory.
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'template_card_widget.dart';

class CategorySectionWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final List<Map<String, dynamic>> templates;
  final Function(Map<String, dynamic>) onTemplatePreview;
  final Function(String, String) onToggleFavorite;
  final VoidCallback onViewAll;

  const CategorySectionWidget({
    Key? key,
    required this.category,
    required this.templates,
    required this.onTemplatePreview,
    required this.onToggleFavorite,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: category['icon'] ?? 'category',
                    color: theme.colorScheme.primary,
                    size: 28.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    category['name'] ?? 'Untitled Category',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 280, // A fixed height for the horizontal list
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: templates.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16.0),
            itemBuilder: (context, index) {
              final template = templates[index];
              return SizedBox(
                width: 200, // Fixed width for the cards in the list
                child: TemplateCardWidget(
                  templateData: template,
                  onTap: () => onTemplatePreview(template),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
