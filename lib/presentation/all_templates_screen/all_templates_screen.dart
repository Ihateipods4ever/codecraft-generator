import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../template_library/widgets/template_card_widget.dart'; // Assuming this path

class AllTemplatesScreen extends StatefulWidget {
  final Map<String, dynamic> categoryData;

  const AllTemplatesScreen({Key? key, required this.categoryData}) : super(key: key);

  @override
  State<AllTemplatesScreen> createState() => _AllTemplatesScreenState();
}

class _AllTemplatesScreenState extends State<AllTemplatesScreen> {
  // You might want to add search/filter functionality here later if needed
  // For now, it just displays all templates for the passed category.

  @override
  Widget build(BuildContext context) {
    final String categoryName = widget.categoryData['name'];
    final List<Map<String, dynamic>> templates = List<Map<String, dynamic>>.from(widget.categoryData['templates']);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 1.0,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: AppTheme.lightTheme.colorScheme.onSurface),
        ),
        title: Text(
          '$categoryName Templates',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: templates.isEmpty
          ? Center(
              child: Text(
                'No templates found for this category.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0), // Fixed padding
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Adjusted aspect ratio for cards
                crossAxisSpacing: 16.0, // Fixed spacing
                mainAxisSpacing: 16.0, // Fixed spacing
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                // You'll need to pass proper onFavorite and onTap handlers here
                // For simplicity, I'm using a placeholder onTap and no onFavorite
                return TemplateCardWidget(
                  template: template,
                  onTap: () {
                    // Implement navigation to template preview or code generation
                    // For now, just show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on ${template['name']}')),
                    );
                  },
                  onFavorite: () {
                    // Implement favorite toggling if needed
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Favorited ${template['name']}')),
                    );
                  },
                );
              },
            ),
    );
  }
}