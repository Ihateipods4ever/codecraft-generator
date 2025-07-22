import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';

// --- Placeholder for AppTheme and CustomIconWidget for demonstration ---
// In a real app, these would come from your core/app_export.dart or similar.

extension ColorExtension on Color {
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    return Color.fromRGBO(
      red != null ? red.toInt() : this.red,
      green != null ? green.toInt() : this.green,
      blue != null ? blue.toInt() : this.blue,
      alpha != null ? alpha.toDouble() : this.opacity,
    );
  }
}

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.light().copyWith(
      surface: Colors.white,
      onSurface: Colors.black,
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.dark().copyWith(
      surface: Color(0xFF1E1E1E), // A common dark background color for code editors
      onSurface: Colors.white,
    ),
  );

  static Color surfaceLight = Colors.white;
  static Color surfaceDark = const Color(0xFF1E1E1E);
  static Color dividerLight = Colors.grey.shade300;
  static Color dividerDark = Colors.grey.shade700;
  static Color textSecondaryLight = Colors.grey.shade600;
  static Color textSecondaryDark = Colors.grey.shade400;

  static TextStyle getCodeTextStyle({
    required bool isLight,
    required double fontSize,
    double? height, // Added height for potential line spacing control
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      color: isLight ? Colors.black : Colors.white,
      height: height,
    );
  }
}

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
      case 'copy':
        iconData = Icons.copy;
        break;
      case 'comment':
        iconData = Icons.comment;
        break;
      case 'auto_fix_high':
        iconData = Icons.auto_fix_high;
        break;
      default:
        iconData = Icons.help_outline;
    }
    return Icon(iconData, color: color, size: size);
  }
}

class CodeEditorWidget extends StatefulWidget {
  final String content;
  final String language;
  final TransformationController transformationController;
  final Function(String) onContentChanged;

  const CodeEditorWidget({
    Key? key,
    required this.content,
    required this.language,
    required this.transformationController,
    required this.onContentChanged,
  }) : super(key: key);

  @override
  State<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> with AutomaticKeepAliveClientMixin<CodeEditorWidget> {
  late TextEditingController _textController;
  late ScrollController _scrollController;
  bool _isEditing = false;

  final double _editorFontSize = 14.0;
  final double _lineNumberFontSize = 12.0;
  final double _estimatedLineHeight = 20.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.content);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildLineNumbers(String content, bool isDark) {
    // Corrected: Replaced the literal newline with the '\n' escape sequence.
    final lines = content.split('\n');
    final int maxDigits = lines.length.toString().length;
    final double lineNumberColumnWidth = 10.0 + (maxDigits * _lineNumberFontSize * 0.7);

    return Container(
      width: lineNumberColumnWidth,
      padding: const EdgeInsets.only(right: 8.0, top: 16.0),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withOpacity(0.5)
            : AppTheme.surfaceLight.withOpacity(0.5),
        border: Border(
          right: BorderSide(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(lines.length, (index) {
          return Container(
            height: _estimatedLineHeight,
            alignment: Alignment.centerRight,
            child: Text(
              '${index + 1}',
              style: AppTheme.getCodeTextStyle(
                isLight: !isDark,
                fontSize: _lineNumberFontSize,
                height: 1.0,
              ).copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineNumbers(
            _isEditing ? _textController.text : widget.content,
            isDark,
          ),
          Expanded(
            child: InteractiveViewer(
              transformationController: widget.transformationController,
              minScale: 0.5,
              maxScale: 3.0,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: _isEditing
                      ? TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: false,
                          style: AppTheme.getCodeTextStyle(
                            isLight: !isDark,
                            fontSize: _editorFontSize,
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (newContent) {
                            widget.onContentChanged(newContent);
                            setState(() {});
                          },
                          contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
                            final TextEditingController controller = editableTextState.widget.controller;
                            final TextSelection selection = controller.selection;

                            if (selection.isValid && !selection.isCollapsed) {
                              return AdaptiveTextSelectionToolbar.buttonItems(
                                anchors: editableTextState.contextMenuAnchors,
                                buttonItems: <ContextMenuButtonItem>[
                                  ContextMenuButtonItem(
                                    onPressed: () {
                                      editableTextState.copySelection(SelectionChangedCause.toolbar);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Code copied to clipboard')),
                                      );
                                    },
                                    type: ContextMenuButtonType.copy,
                                  ),
                                  ContextMenuButtonItem(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Code commented (action not fully implemented)')),
                                      );
                                      editableTextState.hideToolbar();
                                    },
                                    label: 'Comment',
                                  ),
                                  ContextMenuButtonItem(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('AI refactoring... (action not fully implemented)')),
                                      );
                                      editableTextState.hideToolbar();
                                    },
                                    label: 'Refactor with AI',
                                  ),
                                ],
                              );
                            }
                            return AdaptiveTextSelectionToolbar.editableText(
                              editableTextState: editableTextState,
                            );
                          },
                        )
                      : GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _isEditing = true;
                              _textController.text = widget.content;
                              _textController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _textController.text.length));
                            });
                          },
                          child: HighlightView(
                            widget.content,
                            language: widget.language,
                            theme: isDark ? vs2015Theme : githubTheme,
                            padding: EdgeInsets.zero,
                            textStyle: AppTheme.getCodeTextStyle(
                              isLight: !isDark,
                              fontSize: _editorFontSize,
                              height: 1.5,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
