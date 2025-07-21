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
                      import '../../../../core/app_export.dart';
