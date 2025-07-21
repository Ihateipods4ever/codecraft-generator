import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportOptionsWidget extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String) onExport;

  const ExportOptionsWidget({
    Key? key,
    required this.onClose,
    required this.onExport,
  }) : super(key: key);

  @override
  State<ExportOptionsWidget> createState() => _ExportOptionsWidgetState();
}

class _ExportOptionsWidgetState extends State<ExportOptionsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final List<Map<String, dynamic>> _exportOptions = [
    {
      "type": "ZIP",
      "title": "Download as ZIP",
      "description": "Download all project files as a compressed archive",
      "icon": "archive",
      "color": AppTheme.primaryLight,
    },
    {
      "type": "GitHub",
      "title": "Push to GitHub",
      "description": "Create a new repository and push your code",
      "icon": "cloud_upload",
      "color": AppTheme.successLight,
    },
    {
      "type": "Share",
      "title": "Share Project Link",
      "description": "Generate a shareable link for collaboration",
      "icon": "share",
      "color": AppTheme.warningLight,
    },
    {
      "type": "VS Code",
      "title": "Open in VS Code",
      "description": "Open project directly in Visual Studio Code",
      "icon": "code",
      "color": AppTheme.primaryLight,
    },
    {
      "type": "Replit",
      "title": "Export to Replit",
      "description": "Create a new Replit project with your code",
      "icon": "play_circle",
      "color": AppTheme.successLight,
    },
    {
      "type": "CodePen",
      "title": "Export to CodePen",
      "description": "Create a new CodePen with your web code",
      "icon": "web",
      "color": AppTheme.warningLight,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  void _handleExport(String type) {
    _animationController.reverse().then((_) {
      widget.onExport(type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _opacityAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 90.w,
                constraints: BoxConstraints(maxHeight: 80.h),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? AppTheme.dividerDark
                                : AppTheme.dividerLight,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'download',
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                            size: 24,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Export Options',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _closeOverlay,
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Export Options List
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(16.w),
                        itemCount: _exportOptions.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final option = _exportOptions[index];
                          return _buildExportOption(option, isDark);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportOption(Map<String, dynamic> option, bool isDark) {
    return GestureDetector(
      onTap: () => _handleExport(option["type"]),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
               color: (option["color"] as Color).withOpacity(0.1),


                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: option["icon"],
                  color: option["color"],
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option["title"],
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    option["description"],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
