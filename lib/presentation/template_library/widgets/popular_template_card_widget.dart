import 'package:flutter/material.dart';

import '../../../core/app_export.dart'; // Assuming CustomImageWidget and AppTheme

class PopularTemplateCardWidget extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const PopularTemplateCardWidget({
    Key? key,
    required this.template,
    required this.onTap,
    required this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280.0, // Fixed width for the card
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          boxShadow: AppTheme.getSubtleShadow(isLight: true), // Subtle shadow
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: CustomImageWidget(
                    imageUrl: template["image"],
                    width: double.infinity,
                    height: 120.0, // Fixed height for the image
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: template["isFavorite"] ? 'favorite' : 'favorite_border',
                        color: template["isFavorite"] ? Colors.red : Colors.white,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8.0,
                  left: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary, // Purple background for framework
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      template["framework"],
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary, // White text
                        fontSize: 10.0, // Smaller font size
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0), // Padding for text content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template["name"],
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0, // Fixed font size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: Colors.amber,
                        size: 16.0, // Fixed icon size
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        template["popularity"].toString(),
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.0, // Fixed font size
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      CustomIconWidget(
                        iconName: 'download',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 16.0, // Fixed icon size
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        template["downloads"],
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.0, // Fixed font size
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
