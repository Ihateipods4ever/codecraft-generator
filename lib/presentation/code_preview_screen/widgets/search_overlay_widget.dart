import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// Assuming these are correctly imported from your core/app_export.dart
// If not, you might need to provide their definitions here for standalone testing.
// Ensure this path is correct

// --- Placeholders if not correctly imported from app_export.dart ---
// You should remove these if your app_export.dart provides them.

// Example: AppTheme with missing colors
class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    // ... existing properties
    textTheme: const TextTheme(
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14),
      labelSmall: TextStyle(fontSize: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    // ... existing properties
    textTheme: const TextTheme(
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 14),
      labelSmall: TextStyle(fontSize: 12),
    ),
  );

  static Color surfaceLight = Colors.white;
  static Color surfaceDark = const Color(0xFF1E1E1E);
  static Color dividerLight = Colors.grey.shade300;
  static Color dividerDark = Colors.grey.shade700;
  static Color textPrimaryLight = Colors.black87;
  static Color textPrimaryDark = Colors.white;
  static Color textSecondaryLight = Colors.grey.shade600;
  static Color textSecondaryDark = Colors.grey.shade400;
  static Color textDisabledLight = Colors.grey.shade400;
  static Color textDisabledDark = Colors.grey.shade600;
  static Color primaryLight = Colors.blue; // Example
  static Color primaryDark = Colors.blue; // Example
  static Color shadowLight = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.4);
}

// Example: CustomIconWidget with missing icons
class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color color;
  final double size;

  const CustomIconWidget({
    Key? key,
    required this.iconName,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (iconName) {
      case 'search':
        iconData = Icons.search;
        break;
      case 'close':
        iconData = Icons.close;
        break;
      case 'clear':
        iconData = Icons.clear;
        break;
      case 'find_replace':
        iconData = Icons.find_replace;
        break;
      case 'keyboard_arrow_up':
        iconData = Icons.keyboard_arrow_up;
        break;
      case 'keyboard_arrow_down':
        iconData = Icons.keyboard_arrow_down;
        break;
      default:
        iconData = Icons.help_outline;
    }
    return Icon(iconData, color: color, size: size);
  }
}

// Add an extension for Color to allow `.withValues` if it's not defined elsewhere
extension ColorExtension on Color {
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    return Color.fromRGBO(
      red != null ? red.toInt() : this.red,
      green != null ? green.toInt() : this.green,
      blue != null ? blue.toInt() : this.blue,
      alpha ?? this.opacity,
    );
  }
}
// --- End of Placeholders ---


class SearchOverlayWidget extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String) onSearch;
  final TextEditingController searchController; // <--- ADDED
  final FocusNode focusNode; // <--- ADDED
  final List<int> searchResults; // <--- ADDED
  final int searchIndex; // <--- ADDED
  final VoidCallback onNextResult; // <--- ADDED
  final VoidCallback onPreviousResult; // <--- ADDED


  const SearchOverlayWidget({
    Key? key,
    required this.onClose,
    required this.onSearch,
    required this.searchController, // <--- ADDED to constructor
    required this.focusNode, // <--- ADDED to constructor
    required this.searchResults, // <--- ADDED to constructor
    required this.searchIndex, // <--- ADDED to constructor
    required this.onNextResult, // <--- ADDED to constructor
    required this.onPreviousResult, // <--- ADDED to constructor
  }) : super(key: key);

  @override
  State<SearchOverlayWidget> createState() => _SearchOverlayWidgetState();
}

class _SearchOverlayWidgetState extends State<SearchOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  // Use the controllers passed from the parent, no need to declare here.
  // late TextEditingController _searchController; // REMOVE
  late TextEditingController _replaceController;

  bool _showReplace = false;
  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _useRegex = false;

  // Search results and index will now come from widget properties,
  // so remove the local declaration here.
  // final List<Map<String, dynamic>> _searchResults = [...]; // REMOVE
  // int _currentResultIndex = 0; // REMOVE

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Use const for duration
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // _searchController is now passed in widget.searchController
    _replaceController = TextEditingController();

    // The overlay should animate in when it's first built.
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // widget.searchController is disposed by its owner (CodePreviewScreen)
    _replaceController.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  // These navigation functions will now call the callbacks provided by the parent
  void _navigateResult(bool next) {
    if (next) {
      widget.onNextResult();
    } else {
      widget.onPreviousResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        // Only apply vertical translation for the slide animation
        // Offset (0, _slideAnimation.value * height) will make it slide from top
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * MediaQuery.of(context).size.height * 0.15), // Slide down by a percentage of screen height
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              // Wrap with Material to provide proper theme context if needed, and clip content
              child: Material(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Use min to wrap content
                    children: [
                      // Search Header
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'search',
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                            size: 20,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Find in File',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _closeOverlay,
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Search Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.searchController, // Use widget.searchController
                              focusNode: widget.focusNode, // Use widget.focusNode
                              autofocus: true,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                prefixIcon: CustomIconWidget(
                                  iconName: 'search',
                                  color: isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight,
                                  size: 16,
                                ),
                                suffixIcon: widget.searchController.text.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          widget.searchController.clear();
                                          widget.onSearch(''); // Notify parent to clear search
                                          // No need for setState here if parent rebuilds this widget
                                        },
                                        child: CustomIconWidget(
                                          iconName: 'clear',
                                          color: isDark
                                              ? AppTheme.textSecondaryDark
                                              : AppTheme.textSecondaryLight,
                                          size: 16,
                                        ),
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                // No setState here, parent will trigger rebuild via onSearch
                                widget.onSearch(value); // Notify parent of search query change
                              },
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.primaryDark.withValues(alpha: 0.1)
                                  : AppTheme.primaryLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              // Use widget.searchResults and widget.searchIndex
                              '${widget.searchResults.isNotEmpty ? widget.searchIndex + 1 : 0}/${widget.searchResults.length}',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: isDark
                                    ? AppTheme.primaryDark
                                    : AppTheme.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Replace Input (if visible)
                      if (_showReplace) ...[
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _replaceController,
                          style:
                              AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Replace with...',
                            prefixIcon: CustomIconWidget(
                              iconName: 'find_replace',
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                              size: 16,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 12.h),

                      // Search Options and Navigation
                      Row(
                        children: [
                          // Navigation Buttons
                          GestureDetector(
                            onTap: widget.searchResults.isNotEmpty
                                ? () => _navigateResult(false) // Call parent's previous
                                : null,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: widget.searchResults.isNotEmpty
                                    ? (isDark
                                        ? AppTheme.surfaceDark
                                        : AppTheme.surfaceLight)
                                    : Colors.transparent, // Disable color when no results
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.dividerDark
                                      : AppTheme.dividerLight,
                                ),
                              ),
                              child: CustomIconWidget(
                                iconName: 'keyboard_arrow_up',
                                color: widget.searchResults.isNotEmpty
                                    ? (isDark
                                        ? AppTheme.textPrimaryDark
                                        : AppTheme.textPrimaryLight)
                                    : (isDark // Disabled color
                                        ? AppTheme.textDisabledDark
                                        : AppTheme.textDisabledLight),
                                size: 16,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: widget.searchResults.isNotEmpty
                                ? () => _navigateResult(true) // Call parent's next
                                : null,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: widget.searchResults.isNotEmpty
                                    ? (isDark
                                        ? AppTheme.surfaceDark
                                        : AppTheme.surfaceLight)
                                    : Colors.transparent, // Disable color when no results
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.dividerDark
                                      : AppTheme.dividerLight,
                                ),
                              ),
                              child: CustomIconWidget(
                                iconName: 'keyboard_arrow_down',
                                color: widget.searchResults.isNotEmpty
                                    ? (isDark
                                        ? AppTheme.textPrimaryDark
                                        : AppTheme.textPrimaryLight)
                                    : (isDark // Disabled color
                                        ? AppTheme.textDisabledDark
                                        : AppTheme.textDisabledLight),
                                size: 16,
                              ),
                            ),
                          ),

                          SizedBox(width: 16.w),

                          // Toggle Replace
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showReplace = !_showReplace;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: _showReplace
                                    ? (isDark
                                        ? AppTheme.primaryDark
                                            .withValues(alpha: 0.1)
                                        : AppTheme.primaryLight
                                            .withValues(alpha: 0.1))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: _showReplace
                                    ? Border.all(
                                        color: isDark
                                            ? AppTheme.primaryDark
                                            : AppTheme.primaryLight,
                                      )
                                    : null,
                              ),
                              child: Text(
                                'Replace',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: _showReplace
                                      ? (isDark
                                          ? AppTheme.primaryDark
                                          : AppTheme.primaryLight)
                                      : (isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(), // Use const for spacers

                          // Search Options
                          Row(
                            children: [
                              _buildOptionButton('Aa', _caseSensitive, () {
                                setState(() {
                                  _caseSensitive = !_caseSensitive;
                                  // Call parent's onSearch to re-trigger search with new option
                                  widget.onSearch(widget.searchController.text);
                                });
                              }, isDark),
                              SizedBox(width: 4.w),
                              _buildOptionButton('Ab', _wholeWord, () {
                                setState(() {
                                  _wholeWord = !_wholeWord;
                                  // Call parent's onSearch to re-trigger search with new option
                                  widget.onSearch(widget.searchController.text);
                                });
                              }, isDark),
                              SizedBox(width: 4.w),
                              _buildOptionButton('.*', _useRegex, () {
                                setState(() {
                                  _useRegex = !_useRegex;
                                  // Call parent's onSearch to re-trigger search with new option
                                  widget.onSearch(widget.searchController.text);
                                });
                              }, isDark),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
      String label, bool isActive, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                  ? AppTheme.primaryDark.withValues(alpha: 0.1)
                  : AppTheme.primaryLight.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive
                ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: isActive
                ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                : (isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight),
            fontSize: 10.sp, // Use 10.sp directly for better sizing control
          ),
        ),
      ),
    );
  }
}