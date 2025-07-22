import 'package:flutter/material.dart';
// Corrected: The import path for TemplateCardWidget was incorrect.
import '../template_library/widgets/template_card_widget.dart';

class AllTemplatesScreen extends StatelessWidget {
  final Map<String, dynamic> categoryData;

  const AllTemplatesScreen({
    Key? key,
    required this.categoryData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = (categoryData['templates'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          categoryData['name'] ?? 'All Templates',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
      ),
      body: templates.isEmpty
          ? const Center(
              child: Text('No templates available in this category.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return TemplateCardWidget(
                  templateData: template,
                  onTap: () {
                    // TODO: Implement navigation or preview logic for the template
                    print('Tapped on ${template['name']}');
                  },
                );
              },
            ),
    );
  }
}
