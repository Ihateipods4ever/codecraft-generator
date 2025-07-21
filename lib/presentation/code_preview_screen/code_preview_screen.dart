import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Assuming this imports AppTheme, CustomIconWidget
// Assuming this provides OpenAIClient
import './widgets/code_editor_widget.dart';
import './widgets/code_toolbar_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/file_tab_widget.dart';
import './widgets/search_overlay_widget.dart';

// --- Placeholder for CodeFile class for demonstration ---
// In a real app, this would likely be in a separate models or core file.
class CodeFile {
  String filename;
  String content;
  String language;
  TransformationController? transformationController; // To manage its own zoom/pan

  CodeFile({
    required this.filename,
    required this.content,
    required this.language,
    this.transformationController,
  });

  // Method to update content (useful for onContentChanged)
  CodeFile copyWith({
    String? filename,
    String? content,
    String? language,
    TransformationController? transformationController, // Added to copyWith
  }) {
    return CodeFile(
      filename: filename ?? this.filename,
      content: content ?? this.content,
      language: language ?? this.language,
      transformationController: transformationController ?? this.transformationController,
    );
  }
}
// --- End of Placeholder ---


// --- Placeholder for AppTheme and CustomIconWidget for demonstration ---
// In a real app, these would come from your core/app_export.dart or similar.

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0),
    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.blue,
      onSurface: Colors.black87,
      surface: Colors.white,
      secondary: Colors.amber, // Placeholder for other colors
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), elevation: 0),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.blue,
      onSurface: Colors.white,
      surface: const Color(0xFF1E1E1E),
      secondary: Colors.orange, // Placeholder for other colors
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  static Color successLight = Colors.green; // Example color
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
      case 'arrow_back':
        iconData = Icons.arrow_back;
        break;
      case 'light_mode':
        iconData = Icons.light_mode;
        break;
      case 'dark_mode':
        iconData = Icons.dark_mode;
        break;
      case 'file_download':
        iconData = Icons.file_download;
        break;
      case 'search':
        iconData = Icons.search;
        break;
      default:
        iconData = Icons.help_outline;
    }
    return Icon(iconData, color: color, size: size);
  }
}
// --- End of Placeholder ---


class CodePreviewScreen extends StatefulWidget {
  const CodePreviewScreen({Key? key}) : super(key: key);

  @override
  State<CodePreviewScreen> createState() => _CodePreviewScreenState();
}

class _CodePreviewScreenState extends State<CodePreviewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  // The _scrollController here is for the overall Scaffold body,
  // not directly for the content within CodeEditorWidget.
  // For precise scrolling within the code, CodeEditorWidget itself
  // would need to expose a scroll controller or a scroll method.
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Code generation data
  String _generatedCode = '';
  String _framework = 'React';
  bool _useTypeScript = false;
  List<CodeFile> _codeFiles = [];

  bool _isLoading = false;
  bool _showSearchOverlay = false;
  bool _isDarkMode = false;
  bool _isExporting = false;


  int _currentSearchIndex = 0;
  List<int> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with a temporary length (e.g., 1)
    // It will be re-initialized correctly after _parseGeneratedCode.
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_onTabChanged); // Listen for tab changes
    _loadCodeData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose(); // Disposing even if its direct utility is limited
    _searchController.dispose();
    _searchFocusNode.dispose();
    // Dispose of transformation controllers for each file
    for (var file in _codeFiles) {
      file.transformationController?.dispose();
    }
    super.dispose();
  }

  void _onTabChanged() {
    // Reset search results when tab changes
    _closeSearch();
  }

  void _loadCodeData() {
    // Get arguments passed from code generation screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        setState(() {
          _generatedCode = args['generatedCode'] ?? '';
          _framework = args['framework'] ?? 'React';
          _useTypeScript = args['useTypeScript'] ?? false;
          // Parse the generated code into files
          _parseGeneratedCode();
          // After parsing, re-initialize TabController if needed
          _reinitializeTabController();
        });
      }
    });
  }

  void _reinitializeTabController() {
    if (_tabController.length != _codeFiles.length) {
      _tabController.dispose();
      _tabController = TabController(length: _codeFiles.length, vsync: this);
      _tabController.addListener(_onTabChanged); // Re-add listener
    }
  }

  void _parseGeneratedCode() {
    if (_generatedCode.isEmpty) {
      _codeFiles = [
        CodeFile(
            filename: 'main.${_getFileExtension()}',
            content: 'No code generated yet.',
            language: _getLanguage(),
            transformationController: TransformationController()), // Initialize controller
      ];
    } else {
      // Parse code blocks from the generated response
      _codeFiles = _parseCodeBlocks(_generatedCode);

      // If no code blocks found, treat entire response as single file
      if (_codeFiles.isEmpty) {
        _codeFiles = [
          CodeFile(
              filename: 'generated.${_getFileExtension()}',
              content: _generatedCode,
              language: _getLanguage(),
              transformationController: TransformationController()), // Initialize controller
        ];
      }
    }

    // Ensure each CodeFile has a TransformationController
    for (var i = 0; i < _codeFiles.length; i++) {
      if (_codeFiles[i].transformationController == null) {
        // Use copyWith to create a new CodeFile instance with the existing data
        // and a newly initialized transformationController.
        _codeFiles[i] = _codeFiles[i].copyWith(
          transformationController: TransformationController(),
        );
      }
    }
  }

  List<CodeFile> _parseCodeBlocks(String content) {
    final codeFiles = <CodeFile>[];
    // Regex for markdown code blocks, capturing optional language and content
    final regex =
        RegExp(r'```(\w+)?\n(.*?)\n```', multiLine: true, dotAll: true);
    final matches = regex.allMatches(content);

    for (final match in matches) {
      final language = match.group(1) ?? _getLanguage();
      final code = match.group(2) ?? '';

      // Try to extract filename from the first line or use generic name
      final lines = code.split('\n');
      String filename = 'file${codeFiles.length + 1}.${_getFileExtension()}';
      String actualCode = code;

      // Improved filename extraction: Look for a line that starts with a filename pattern
      if (lines.isNotEmpty && lines.first.trim().endsWith(_getFileExtension())) {
        final firstLine = lines.first.trim();
        // Check if the first line looks like a filename (e.g., "Component.jsx" or "src/utils/helper.ts")
        if (firstLine.contains('/') || firstLine.contains('.')) {
          filename = firstLine;
          actualCode = lines.skip(1).join('\n');
        }
      } else {
        // If first line is not a filename, check for comments indicating filename
        final filenameCommentRegex = RegExp(r'(?:filename|file):?\s*([^\s]+)');
        final commentMatch = filenameCommentRegex.firstMatch(lines.first);
        if (commentMatch != null && commentMatch.group(1) != null) {
          filename = commentMatch.group(1)!;
          actualCode = lines.skip(1).join('\n');
        }
      }

      codeFiles.add(CodeFile(
          filename: filename,
          content: actualCode,
          language: language,
          transformationController: TransformationController())); // Initialize controller
    }

    return codeFiles;
  }

  String _getLanguage() {
    switch (_framework.toLowerCase()) {
      case 'react':
      case 'vue':
      case 'angular':
        return _useTypeScript ? 'typescript' : 'javascript';
      case 'python':
        return 'python';
      case 'flutter':
        return 'dart';
      case 'node.js':
        return _useTypeScript ? 'typescript' : 'javascript';
      default:
        return 'text';
    }
  }

  String _getFileExtension() {
    switch (_framework.toLowerCase()) {
      case 'react':
        return _useTypeScript ? 'tsx' : 'jsx';
      case 'vue':
        return 'vue';
      case 'angular':
        return _useTypeScript ? 'ts' : 'js';
      case 'python':
        return 'py';
      case 'flutter':
        return 'dart';
      case 'node.js':
        return _useTypeScript ? 'ts' : 'js';
      default:
        return 'txt';
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _copyToClipboard() {
    if (_codeFiles.isNotEmpty) {
      final currentFile = _codeFiles[_tabController.index];
      Clipboard.setData(ClipboardData(text: currentFile.content));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Code copied to clipboard'),
          backgroundColor: AppTheme.successLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0))));
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty || _codeFiles.isEmpty) {
      setState(() {
        _searchResults = [];
        _currentSearchIndex = 0;
      });
      return;
    }

    final currentFile = _codeFiles[_tabController.index];
    final results = <int>[];
    final lowerQuery = query.toLowerCase();
    final lowerContent = currentFile.content.toLowerCase();

    int index = 0;
    while (index < lowerContent.length) {
      final found = lowerContent.indexOf(lowerQuery, index);
      if (found == -1) break;
      results.add(found);
      index = found + lowerQuery.length; // Move past the found query to find next
    }

    setState(() {
      _searchResults = results;
      _currentSearchIndex = results.isNotEmpty ? 0 : -1; // -1 if no results
    });
  }

  void _goToNextSearchResult() {
    if (_searchResults.isEmpty) return;
    setState(() {
      _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
      // Scroll to the result when navigating (conceptual, see _scrollToSearchResult comments)
      _scrollToSearchResult(_searchResults[_currentSearchIndex]);
    });
  }

  void _goToPreviousSearchResult() {
    if (_searchResults.isEmpty) return;
    setState(() {
      _currentSearchIndex = (_currentSearchIndex - 1 + _searchResults.length) % _searchResults.length;
      // Scroll to the result when navigating (conceptual, see _scrollToSearchResult comments)
      _scrollToSearchResult(_searchResults[_currentSearchIndex]);
    });
  }

  void _scrollToSearchResult(int index) {
    // This method's functionality relies on the CodeEditorWidget's ability
    // to expose its internal scrolling mechanism or a way to scroll to a specific
    // character/line offset. The `_scrollController` in this `_CodePreviewScreenState`
    // manages the outer layout, not the content inside the `CodeEditorWidget`
    // which uses its own `InteractiveViewer` and `TransformationController`.
    //
    // For a precise scroll-to-search-result feature, enhancements would be needed
    // within the `CodeEditorWidget` to accept a scroll command.
    //
    // The current `_scrollController.animateTo(index.toDouble())` is a placeholder
    // and will not correctly scroll to the character index within the code editor.
    // To implement this properly, `CodeEditorWidget` would need to be modified.
  }


  void _toggleSearchOverlay() {
    setState(() {
      _showSearchOverlay = !_showSearchOverlay;
      if (!_showSearchOverlay) {
        _closeSearch(); // Clear search on closing overlay
      } else {
        _searchFocusNode.requestFocus(); // Focus search input when opened
      }
    });
  }

  void _closeSearch() {
    setState(() {
      _showSearchOverlay = false;
      _searchResults = [];
      _currentSearchIndex = 0;
    });
    _searchController.clear();
    _searchFocusNode.unfocus(); // Unfocus search input when closed
  }

  Map<String, dynamic> _codeFileToMap(CodeFile codeFile) {
    return {
      'name': codeFile.filename,
      'size': '${codeFile.content.length} chars',
      'lastModified': DateTime.now(), // Always current time for simplicity
    };
  }

  void _exportCode() {
    setState(() {
      _isExporting = true;
    });

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ExportOptionsWidget(
              onClose: () => setState(() => _isExporting = false),
              onExport: (format) {
                // Handle export functionality
                Navigator.pop(context); // Close the bottom sheet after export
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Exporting code in $format format... (Not fully implemented)'),
                    backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                );
              },
            ));
  }

  void _updateCodeFileContent(int index, String newContent) {
    setState(() {
      _codeFiles[index] = _codeFiles[index].copyWith(content: newContent);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure _tabController is ready, especially for the first build
    if (_codeFiles.isEmpty && !_isLoading) {
      // Provide a minimal setup if codeFiles are not yet loaded
      _codeFiles = [
        CodeFile(
            filename: 'loading.${_getFileExtension()}',
            content: 'Loading code...',
            language: 'text',
            transformationController: TransformationController()),
      ];
      _tabController = TabController(length: 1, vsync: this);
      _tabController.addListener(_onTabChanged);
    }

    return Scaffold(
      backgroundColor: _isDarkMode
          ? AppTheme.darkTheme.scaffoldBackgroundColor
          : AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Code Preview',
            style: _isDarkMode
                ? AppTheme.darkTheme.textTheme.titleLarge
                : AppTheme.lightTheme.textTheme.titleLarge),
        backgroundColor: _isDarkMode
            ? AppTheme.darkTheme.appBarTheme.backgroundColor
            : AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: _isDarkMode
                  ? AppTheme.darkTheme.colorScheme.onSurface
                  : AppTheme.lightTheme.colorScheme.onSurface,
              size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
                iconName: 'search', // Search icon
                color: _isDarkMode
                    ? AppTheme.darkTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 24),
            onPressed: _toggleSearchOverlay, // Toggle search overlay
          ),
          IconButton(
            icon: CustomIconWidget(
                iconName: _isDarkMode ? 'light_mode' : 'dark_mode',
                color: _isDarkMode
                    ? AppTheme.darkTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 24),
            onPressed: _toggleTheme,
          ),
          IconButton(
            icon: CustomIconWidget(
                iconName: 'file_download',
                color: _isDarkMode
                    ? AppTheme.darkTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 24),
            onPressed: _exportCode,
          ),
        ],
        bottom: _codeFiles.length > 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: _isDarkMode
                      ? AppTheme.darkTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.primary,
                  labelColor: _isDarkMode
                      ? AppTheme.darkTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.primary,
                  unselectedLabelColor: _isDarkMode
                      ? AppTheme.darkTheme.colorScheme.onSurface.withOpacity(0.7)
                      : AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                  tabs: _codeFiles
                      .map((file) => Tab(
                            child: FileTabWidget(
                              fileName: file.filename,
                              isActive: _tabController.index == _codeFiles.indexOf(file),
                            ),
                          ))
                      .toList(),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Toolbar
              CodeToolbarWidget(
                onCopy: _copyToClipboard,
                currentFile: _codeFiles.isNotEmpty
                    ? _codeFileToMap(_codeFiles[_tabController.index])
                    : {
                        'name': 'No file',
                        'size': '0 chars',
                        'lastModified': DateTime.now(),
                      },
                isOptimizing: false, // This state is not managed in this snippet
                onFormat: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Format action (Not implemented)'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  );
                },
                onOptimize: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Optimize action (Not implemented)'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  );
                },
                onRun: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Run action (Not implemented)'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  );
                },
              ),

              // Code editor
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: _isDarkMode
                                ? AppTheme.darkTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.primary))
                    : TabBarView(
                        controller: _tabController,
                        children: _codeFiles
                            .map((file) => CodeEditorWidget(
                                  language: file.language,
                                  content: file.content,
                                  onContentChanged: (value) {
                                    _updateCodeFileContent(_codeFiles.indexOf(file), value);
                                  },
                                  transformationController:
                                      file.transformationController!, // Use the file's own controller
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),

          if (_showSearchOverlay)
            SearchOverlayWidget(
              onSearch: _performSearch,
              onClose: _closeSearch,
              searchController: _searchController,
              focusNode: _searchFocusNode,
              searchResults: _searchResults,
              searchIndex: _currentSearchIndex,
              onNextResult: _goToNextSearchResult,
              onPreviousResult: _goToPreviousSearchResult,
            ),
        ],
      ),
    );
  }
}