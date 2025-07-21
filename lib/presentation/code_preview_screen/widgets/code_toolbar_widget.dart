import 'package:flutter/material.dart';

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
    final extension = fileName.split('.').last.toLowerCase();
    return ['dart', 'js', 'py', 'java'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canRun = _canRunFile(currentFile["name"]);

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
                  currentFile["name"],
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
                  '${currentFile["size"]} • Modified ${_formatTime(currentFile["lastModified"])}',
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildToolbarButton(
                  icon: 'content_copy',
                  label: 'Copy',
                  onTap: onCopy,
                  isDark: isDark,
                ),
                SizedBox(width: 16.0),
                _buildToolbarButton(
                  icon: 'code',
                  label: 'Format',
                  onTap: onFormat,
                  isDark: isDark,
                ),
                if (canRun) ...[
                  SizedBox(width: 16.0),
                  _buildToolbarButton(
                    icon: 'play_arrow',
                    label: 'Run',
                    onTap: onRun,
                    isDark: isDark,
                    isHighlighted: true,
                  ),
                ],
                SizedBox(width: 16.0),
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isHighlighted
              ? (isDark
                  ? Theme.of(null!).primaryColor.withOpacity(0.1)
                  : Theme.of(null!).primaryColor.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted
              ? Border.all(
                  color: isDark ? Theme.of(null!).primaryColor : Theme.of(null!).primaryColor,
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Theme.of(null!).primaryColor : Theme.of(null!).primaryColor,
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
                                ? Theme.of(null!).primaryColor
                                : Theme.of(null!).primaryColor)
                            : (isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight),
                    size: 20,
                  ),
            SizedBox(height: 4.0),
            Text(
              label,
              style: Theme.of(null!).textTheme.labelSmall?.copyWith(
                color: onTap == null
                    ? (isDark
                        ? AppTheme.textDisabledDark
                        : AppTheme.textDisabledLight)
                    : isHighlighted
                        ? (isDark
                            ? Theme.of(null!).primaryColor
                            : Theme.of(null!).primaryColor)
                        : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
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