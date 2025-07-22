import 'package:flutter/material.dart';

// Assuming these are correctly defined in your project.
import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class CodeToolbarWidget extends StatelessWidget {
  final Map<String, dynamic> currentFile;
  final bool isOptimizing;
  final VoidCallback onCopy;
  final VoidCallback onFormat;
  final VoidCallback onRun;
  final VoidCallback onOptimize;

  const CodeToolbarWidget({
    Key? key,
    required this.currentFile,
    required this.isOptimizing,
    required this.onCopy,
    required this.onFormat,
    required this.onRun,
    required this.onOptimize,
  }) : super(key: key);

  bool _canRunFile(String fileName) {
    // A simple utility to check if the file is runnable based on its extension.
    final extension = fileName.split('.').last.toLowerCase();
    return ['dart', 'js', 'py', 'java'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canRun = _canRunFile(currentFile["name"] ?? 'unknown.file');

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // Safely access file name with a fallback value.
                  currentFile["name"] ?? 'No file selected',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  // Safely access file properties.
                  '${currentFile["size"] ?? '0 KB'} • Modified ${_formatTime(currentFile["lastModified"])}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // Using a Spacer to push the buttons to the right.
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildToolbarButton(
                context: context, // Pass context
                icon: 'content_copy',
                label: 'Copy',
                onTap: onCopy,
                isDark: isDark,
              ),
              const SizedBox(width: 16.0),
              _buildToolbarButton(
                context: context, // Pass context
                icon: 'code',
                label: 'Format',
                onTap: onFormat,
                isDark: isDark,
              ),
              if (canRun) ...[
                const SizedBox(width: 16.0),
                _buildToolbarButton(
                  context: context, // Pass context
                  icon: 'play_arrow',
                  label: 'Run',
                  onTap: onRun,
                  isDark: isDark,
                  isHighlighted: true,
                ),
              ],
              const SizedBox(width: 16.0),
              _buildToolbarButton(
                context: context, // Pass context
                icon: isOptimizing ? 'hourglass_empty' : 'auto_fix_high',
                label: 'AI Optimize',
                onTap: isOptimizing ? null : onOptimize,
                isDark: isDark,
                isLoading: isOptimizing,
                isHighlighted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    // Corrected: Added BuildContext as a parameter to safely access the theme.
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
    bool isHighlighted = false,
    bool isLoading = false,
  }) {
    // Corrected: All instances of Theme.of(null!) are replaced with Theme.of(context).
    // This resolves the 'null_check_always_fails' warnings and prevents runtime crashes.
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final labelSmallStyle = theme.textTheme.labelSmall;

    Color iconColor;
    Color labelColor;

    if (onTap == null) {
      iconColor = isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight;
      labelColor = isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight;
    } else if (isHighlighted) {
      iconColor = primaryColor;
      labelColor = primaryColor;
    } else {
      iconColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
      labelColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isHighlighted ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted
              ? Border.all(color: primaryColor, width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20, // Adjusted size to fit well
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            else
              CustomIconWidget(
                iconName: icon,
                color: iconColor,
                size: 20,
              ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: labelSmallStyle?.copyWith(
                color: labelColor,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    // Added a null check for safety.
    if (dateTime == null) {
      return 'a while ago';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
