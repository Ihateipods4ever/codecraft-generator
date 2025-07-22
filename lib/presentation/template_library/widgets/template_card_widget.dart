import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Corrected: The import paths were adjusted to correctly locate the files
// from within the 'presentation/template_library/widgets' directory.
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TemplateCardWidget extends StatelessWidget {
  final Map<String, dynamic> templateData;
  final VoidCallback onTap;

  const TemplateCardWidget({
    Key? key,
    required this.templateData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 15.h,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: templateData['icon'] ?? 'code',
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          templateData['title'] ?? 'Untitled Template',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          templateData['description'] ?? 'No description available.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'person_outline',
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          templateData['author'] ?? 'Unknown',
                          style: theme.textTheme.labelSmall,
                        ),
                        const Spacer(),
                        CustomIconWidget(
                          iconName: 'download_for_offline',
                          size: 14,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${templateData['downloads'] ?? 0}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
