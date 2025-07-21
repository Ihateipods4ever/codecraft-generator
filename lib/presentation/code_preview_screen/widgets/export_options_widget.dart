import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart'; // Import CustomIconWidget

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

  // Removed _exportOptions as it was unused and causing an unused_field diagnostic

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

  // Removed _handleExport as it was unused and causing an unused_element diagnostic

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
                width: 90.w, // Use sizer unit
                constraints: BoxConstraints(maxHeight: 80.h), // Use sizer unit
                margin: EdgeInsets.symmetric(horizontal: 20.w), // Use sizer unit
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
                      padding: EdgeInsets.all(16.0),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Export Options',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith( // Use Theme.of(context)
                              fontWeight: FontWeight.w600,
                              fontSize: 20.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: _closeOverlay,
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                              size: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Export options list will go here
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Removed _formatTime as it was unused and causing an unused_element diagnostic
}
