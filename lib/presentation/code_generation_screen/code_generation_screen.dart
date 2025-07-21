import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for clipboard
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as genai;
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '../../core/app_export.dart';

class CodeGenerationScreen extends StatefulWidget {
  const CodeGenerationScreen({Key? key}) : super(key: key);

  @override
  State<CodeGenerationScreen> createState() => _CodeGenerationScreenState();
}

class _CodeGenerationScreenState extends State<CodeGenerationScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  TabController? _tabController;

  String _selectedFramework = 'Flutter';
  String _selectedLanguage = 'Dart';
  bool _isLoading = false;
  
  String? _generatedCode;
  String? _generatedReadme; // New: To store generated README
  bool _isReadmeLoading = false; // New: To track README generation loading

  /*
  // This function is commented out because 'listModels' is not available
  // in the installed 'google_generative_ai' package version (0.4.7).
  // Attempting to use it will cause a compilation error.
  void _listAvailableModels() async {
    _showMessage('Listing available models...', isError: false);
    print('--- Attempting to list Gemini Models ---');

    try {
      final debugApiKey = dotenv.env['GEMINI_API_KEY'];

      if (debugApiKey == null || debugApiKey.isEmpty) {
        _showMessage("Gemini API Key not found for model listing. Check .env file.", isError: true);
        print("Error: Gemini API Key is null or empty. Cannot list models.");
        return;
      }

      // This specific line will cause a compilation error as the method
      // 'listModels' is not found in google_generative_ai 0.4.7.
      // final models = await genai.GenerativeModel.listModels(apiKey: debugApiKey);

      // The rest of this try block depends on 'models', so it's effectively
      // non-functional without 'listModels'.
      // print('\n--- Available Gemini Models ---');
      // if (models.isEmpty) {
      //   print('No models found. Please check your API key, internet connection, or region access.');
      // }
      // for (var model in models) {
      //   print('  - Name: ${model.name}');
      //   print('    Description: ${model.description ?? 'No description'}');
      //   print('    Input Token Limit: ${model.inputTokenLimit}');
      //   print('    Output Token Limit: ${model.outputTokenLimit}');
      //   print('    Supported Methods: ${model.supportedGenerationMethods.join(', ')}');
      //   print('------------------------------');
      // }
      // _showMessage('Available models listed in debug console.', isError: false);

    } catch (e) {
      _showMessage('Error listing models: ${e.toString()}', isError: true);
      print('Error listing models: $e');
    }
    print('--- Finished listing Gemini Models ---');
  }
  */

  final List<String> _frameworks = ['Flutter', 'React', 'Vue', 'Angular', 'Node.js', 'Python', 'Swift', 'Java'];
  final List<String> _languages = ['Dart', 'JavaScript', 'TypeScript', 'Python', 'Swift', 'Kotlin', 'Java', 'C++', 'C#', 'Go'];

  genai.GenerativeModel? _geminiModel;
  bool _isGeminiModelInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _descriptionController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGeminiModel();
    });

    // Listen for tab changes to generate README when preview tab is selected
    _tabController?.addListener(() {
      if (_tabController?.index == 1 && _generatedCode != null && !_isReadmeLoading && _generatedReadme == null) {
        _generateReadme();
      }
    });
  }

  void _initializeGeminiModel() {
    final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      _showMessage('Gemini API Key not found or empty in .env. Code generation will not work.', isError: true);
    } else {
      _geminiModel = genai.GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: geminiApiKey); // Changed model name
      setState(() {
        _isGeminiModelInitialized = true;
      });
      print("Gemini model initialized successfully.");
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _generateCode() async {
    if (_descriptionController.text.isEmpty) {
      _showMessage('Please describe what you want to build.', isError: true);
      return;
    }

    if (!_isGeminiModelInitialized || _geminiModel == null) {
      _showMessage('AI model is not ready. Please check your API key and internet connection.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedCode = null; // Clear previous code
      _generatedReadme = null; // Clear previous README
    });
    HapticFeedback.lightImpact();

    try {
      String prompt = 'Generate $_selectedFramework code in $_selectedLanguage for the following description: "${_descriptionController.text}". '
                      'Provide only the code, no extra text or explanations. '
                      'Wrap the code in triple backticks if it\'s not already, and include the language type (e.g., ```dart, ```javascript).';

      final response = await _geminiModel!.generateContent([genai.Content.text(prompt)]);
      
      String generatedCode = response.text ?? 'No code generated. Please try a different description or prompt.';
      generatedCode = generatedCode.trim();

      setState(() {
        _generatedCode = generatedCode;
        _isLoading = false;
      });

      _tabController?.animateTo(1); // Switch to preview tab
      _showMessage('Code generation complete!', isError: false);

      // Automatically generate README after code generation
      _generateReadme();

    } catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Error generating code: ${e.toString()}';
      if (e is genai.GenerativeAIException) {
        errorMessage = 'Gemini API Error: ${e.message}. Please check your API key or try again.';
      }
      _showMessage(errorMessage, isError: true);
      print('Error generating code: $e');
    }
  }

  // New function to generate README content
  void _generateReadme() async {
    if (_generatedCode == null || _generatedCode!.isEmpty) {
      return; // No code to generate README for
    }

    setState(() {
      _isReadmeLoading = true;
      _generatedReadme = null; // Clear previous README
    });

    try {
      String readmePrompt = 'Based on the following $_selectedFramework code in $_selectedLanguage, generate a simple README.md content. '
                            'Include sections like "Project Setup", "How to Run", and "Dependencies". '
                            'Provide only the Markdown content, no extra text or explanations outside the Markdown. '
                            'Here is the code:\n```$_selectedLanguage\n$_generatedCode\n```';

      final readmeResponse = await _geminiModel!.generateContent([genai.Content.text(readmePrompt)]);
      String readmeContent = readmeResponse.text ?? 'No README generated.';
      
      // Remove triple backticks if the model wrapped the entire README in them
      readmeContent = readmeContent.replaceAll('```markdown', '').replaceAll('```', '').trim();

      setState(() {
        _generatedReadme = readmeContent;
        _isReadmeLoading = false;
      });
      _showMessage('README generated!', isError: false);

    } catch (e) {
      setState(() => _isReadmeLoading = false);
      _showMessage('Error generating README: ${e.toString()}', isError: true);
      print('Error generating README: $e');
    }
  }

  // Function to copy code to clipboard
  void _copyCodeToClipboard() {
    if (_generatedCode != null && _generatedCode!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      _showMessage('Code copied to clipboard!', isError: false);
    } else {
      _showMessage('No code to copy.', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildEditorTab(),
          _buildPreviewTab(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 1.0,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back, color: AppTheme.lightTheme.colorScheme.onSurface),
      ),
      title: Text(
        'Code Generation',
        style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        indicatorColor: AppTheme.lightTheme.colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Editor'),
          Tab(text: 'Preview'),
        ],
      ),
    );
  }

  Widget _buildEditorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          _buildDescriptionSection(),
          const SizedBox(height: 24.0),
          _buildFrameworkSelection(),
          const SizedBox(height: 24.0),
          _buildLanguageSelection(),
          const SizedBox(height: 32.0),
          _buildGenerateButton(),
          const SizedBox(height: 16.0),
          /*
          // This debug button is commented out because _listAvailableModels()
          // is not functional in the current google_generative_ai version (0.4.7).
          // Keeping it uncommented will cause a compilation error.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _listAvailableModels, // This line is now part of a commented block
              icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
              label: const Text(
                'List Available Gemini Models (Debug)',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade50,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.blueGrey.shade200),
                ),
              ),
            ),
          ),
          */
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    if (_generatedCode == null || _generatedCode!.isEmpty) {
      return const Center(
        child: Text(
          'Generate code to see the preview here.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    String highlightLanguage;
    switch (_selectedLanguage.toLowerCase()) {
      case 'dart':
        highlightLanguage = 'dart';
        break;
      case 'javascript':
      case 'typescript':
      case 'react':
      case 'vue':
      case 'angular':
      case 'node.js':
        highlightLanguage = 'javascript';
        break;
      case 'python':
        highlightLanguage = 'python';
        break;
      case 'swift':
        highlightLanguage = 'swift';
        break;
      case 'kotlin':
        highlightLanguage = 'kotlin';
        break;
      case 'java':
        highlightLanguage = 'java';
        break;
      case 'c++':
        highlightLanguage = 'cpp';
        break;
      case 'c#':
        highlightLanguage = 'csharp';
        break;
      case 'go':
        highlightLanguage = 'go';
        break;
      default:
        highlightLanguage = 'plaintext';
    }

    String codeToDisplay = _generatedCode!;
    final codeBlockPattern = RegExp(r'```(?:\w+)?\n([\s\S]*?)\n```');
    final match = codeBlockPattern.firstMatch(codeToDisplay);
    if (match != null && match.groupCount > 0) {
      codeToDisplay = match.group(1)!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _copyCodeToClipboard,
              icon: const Icon(Icons.copy, color: Colors.white),
              label: const Text(
                'Copy Code to Clipboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Code Preview
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: HighlightView(
              codeToDisplay,
              language: highlightLanguage,
              theme: atomOneDarkTheme,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.4,
              ),
              padding: EdgeInsets.zero,
              tabSize: 4,
            ),
          ),
          const SizedBox(height: 24.0),

          // README Section
          Text(
            'README.md',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0),
          _isReadmeLoading
              ? const Center(child: CircularProgressIndicator())
              : _generatedReadme != null && _generatedReadme!.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppTheme.lightTheme.dividerColor),
                      ),
                      child: SelectableText(
                        _generatedReadme!,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    )
                  : const Text(
                      'No README available. Generate code first, or an error occurred during README generation.',
                      style: TextStyle(color: Colors.grey),
                    ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe what you want to build',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: AppTheme.lightTheme.dividerColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 8,
            minLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: 'e.g., "A simple to-do list app with Flutter that stores items locally."',
              hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16.0),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            '${_descriptionController.text.length}/2000',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrameworkSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Framework',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _frameworks.map((framework) {
            final isSelected = _selectedFramework == framework;
            return ChoiceChip(
              label: Text(framework),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedFramework = framework),
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.lightTheme.colorScheme.onPrimary : AppTheme.lightTheme.colorScheme.onSurface,
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: isSelected ? AppTheme.lightTheme.colorScheme.primary : AppTheme.lightTheme.dividerColor,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Language',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _languages.map((language) {
            final isSelected = _selectedLanguage == language;
            return ChoiceChip(
              label: Text(language),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedLanguage = language),
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.lightTheme.colorScheme.onPrimary : AppTheme.lightTheme.colorScheme.onSurface,
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: isSelected ? AppTheme.lightTheme.colorScheme.primary : AppTheme.lightTheme.dividerColor,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading || !_isGeminiModelInitialized ? null : _generateCode,
        icon: _isLoading
            ? const SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.code, color: Colors.white),
        label: Text(
          _isLoading
              ? 'Generating...'
              : _isGeminiModelInitialized
                  ? 'Generate Code'
                  : 'API Key Missing',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
