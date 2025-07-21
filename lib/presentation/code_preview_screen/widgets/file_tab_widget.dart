import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FileTabWidget extends StatelessWidget {
  final String fileName;
  final bool isActive;
  final bool hasUnsavedChanges;

  const FileTabWidget({
    Key? key,
    required this.fileName,
    required this.isActive,
    this.hasUnsavedChanges = false,
  }) : super(key: key);

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart':
        return 'code';
      case 'yaml':
      case 'yml':
        return 'settings';
      case 'json':
        return 'data_object';
      case 'md':
        return 'description';
      case 'html':
        return 'web';
      case 'css':
        return 'palette';
      case 'js':
        return 'javascript';
      default:
        return 'insert_drive_file';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                  ? AppTheme.primaryDark.withOpacity(0.1)
                  : AppTheme.primaryLight.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: _getFileIcon(fileName),
              color: isActive
                  ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
              size: 16,
            ),
            SizedBox(width: 8.w),
            Text(
              fileName,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isActive
                    ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                    : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (hasUnsavedChanges) ...[
              SizedBox(width: 4.w),
              Container(
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.warningLight,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
