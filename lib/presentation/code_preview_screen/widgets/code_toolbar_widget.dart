import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
    final extension = fileName.split('.').last.toLowerCase();
    return ['dart', 'js', 'py', 'java'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canRun = _canRunFile(currentFile["name"]);

    return Container(
      height: 80, // Reduced height from 60.h to a fixed value for a toolbar
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h), // Adjusted padding to be consistent with other screens
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
          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentFile["name"],
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis, // Ensure file name truncates if too long
                  maxLines: 1,
                ),
                Text(
                  '${currentFile["size"]} • Modified ${_formatTime(currentFile["lastModified"])}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis, // Ensure time info truncates
                  maxLines: 1,
                ),
              ],
            ),
          ),

          // Action Buttons - This Row was causing the overflow
          Expanded( // <--- Wrapped the action buttons Row in Expanded
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
              children: [
                _buildToolbarButton(
                  icon: 'content_copy',
                  label: 'Copy',
                  onTap: onCopy,
                  isDark: isDark,
                ),
                SizedBox(width: 2.w), // Adjusted spacing
                _buildToolbarButton(
                  icon: 'code',
                  label: 'Format',
                  onTap: onFormat,
                  isDark: isDark,
                ),
                if (canRun) ...[
                  SizedBox(width: 2.w), // Adjusted spacing
                  _buildToolbarButton(
                    icon: 'play_arrow',
                    label: 'Run',
                    onTap: onRun,
                    isDark: isDark,
                    isHighlighted: true,
                  ),
                ],
                SizedBox(width: 2.w), // Adjusted spacing
                _buildToolbarButton(
                  icon: isOptimizing ? 'hourglass_empty' : 'auto_fix_high',
                  label: 'AI Optimize',
                  onTap: isOptimizing ? null : onOptimize,
                  isDark: isDark,
                  isLoading: isOptimizing,
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required String icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
    bool isHighlighted = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Adjusted horizontal padding to be a fixed value, as percentage width
        // on small buttons can cause issues when combined with Expanded parents.
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Changed vertical padding to fixed value
        decoration: BoxDecoration(
          color: isHighlighted
              ? (isDark
                  ? AppTheme.primaryDark.withOpacity(0.1) // Use withOpacity for clarity
                  : AppTheme.primaryLight.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted
              ? Border.all(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 24, // Fixed size for progress indicator
                    height: 24, // Fixed size for progress indicator
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: icon,
                    color: onTap == null
                        ? (isDark
                            ? AppTheme.textDisabledDark
                            : AppTheme.textDisabledLight)
                        : isHighlighted
                            ? (isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight)
                            : (isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight),
                    size: 20, // Adjusted icon size
                  ),
            SizedBox(height: 4.0), // Adjusted spacing to fixed value
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: onTap == null
                    ? (isDark
                        ? AppTheme.textDisabledDark
                        : AppTheme.textDisabledLight)
                    : isHighlighted
                        ? (isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight)
                        : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
                fontSize: 9.sp, // Adjusted font size
              ),
              overflow: TextOverflow.ellipsis, // Ensure label truncates if too long
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
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