import 'package:flutter/material.dart';
import 'package:codecraft_generator/models/project.dart';
import 'package:codecraft_generator/presentation/code_preview_screen/widgets/code_editor_widget.dart';
import 'package:codecraft_generator/presentation/code_preview_screen/widgets/file_tab_widget.dart';
import 'package:codecraft_generator/presentation/code_preview_screen/widgets/code_toolbar_widget.dart';

// ignore_for_file: must_be_immutable
class CodePreviewScreen extends StatefulWidget {
  CodePreviewScreen({Key? key, this.project}) : super(key: key);
  Project? project;
  @override
  CodePreviewScreenState createState() => CodePreviewScreenState();
}

class CodePreviewScreenState extends State<CodePreviewScreen> {
  Project? project;
  List<String> filePaths = [];
  Map<String, String> fileContents = {};
  String? currentFileName;
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    project = widget.project;
    _loadProjectFiles();
  }

  void _loadProjectFiles() async {
    if (project != null) {
      filePaths = project!.filePaths;

      for (String filePath in filePaths) {
        String content = await _readFileContent(filePath);
        fileContents[filePath] = content;
      }

      setState(() {
        _isLoading = false;
        if (filePaths.isNotEmpty) {
          currentFileName = filePaths.first;
        }
      });
    }
  }

  Future<String> _readFileContent(String filePath) async {
    // Implement actual file reading logic
    return "File content for $filePath"; // Placeholder
  }

  void _onFileTabSelected(String fileName) {
    setState(() {
      currentFileName = fileName;
    });
  }

  void _onCodeChanged(String newCode) {
    if (currentFileName != null) {
      fileContents[currentFileName!] = newCode;
    }
  }

  void _onExport() {
    setState(() {
      _isExporting = true;
    });
    // Implement export logic
    print("Export tapped");
    // After export is done
    setState(() {
      _isExporting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Column(
            children: [
              SizedBox(height: 27.0), 
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0), 
                    child: Column(
                      children: [
                        _buildToolBar(context),
                        SizedBox(height: 24.0), 
                        _buildFileTabs(),
                        SizedBox(height: 24.0), 
                        _buildCodeEditor(),
                        SizedBox(height: 24.0), 
                        _buildExportButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return CodeToolbarWidget(
      currentFile: currentFileName != null ? {"name": currentFileName!, "size": "N/A", "lastModified": DateTime.now()} : {}, // Added required arguments with placeholders
      isOptimizing: false, // Placeholder
      onCopy: () {}, // Placeholder
      onFormat: () {}, // Placeholder
      onRun: () {}, // Placeholder
      onOptimize: () {}, // Placeholder
    );
  }

  Widget _buildFileTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filePaths.map((
          fileName,
        ) =>
            FileTabWidget(
              fileName: fileName,
              isActive: fileName == currentFileName,
              onTap: () => _onFileTabSelected(fileName), // Passing the callback
            )).toList(),
      ),
    );
  }

  Widget _buildCodeEditor() {
    if (_isLoading) {
      return CircularProgressIndicator();
    } else if (currentFileName != null && fileContents.containsKey(currentFileName!)) {
      return CodeEditorWidget(
        content: fileContents[currentFileName!]!,
        language: currentFileName!.split('.').last, // Placeholder language
        transformationController: TransformationController(), // Placeholder
        onContentChanged: _onCodeChanged,
      );
    } else {
      return Text("Select a file to view code.");
    }
  }

  Widget _buildExportButton() {
    return ElevatedButton(
      onPressed: _isExporting ? null : _onExport,
      child: _isExporting
          ? CircularProgressIndicator(color: Colors.white)
          : Text("Export Project"),
    );
  }
}
