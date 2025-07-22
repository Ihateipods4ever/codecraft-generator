import 'package:flutter/material.dart';

// Corrected: All local widget imports now use a consistent, direct path.
import 'widgets/category_section_widget.dart';
import 'widgets/filter_chip_widget.dart';
import 'widgets/popular_template_card_widget.dart';
import 'widgets/template_card_widget.dart';

// Assuming these are correctly located in your project structure.
import '../../core/app_export.dart';
import '../widgets/custom_icon_widget.dart';

class TemplateLibrary extends StatefulWidget {
  const TemplateLibrary({Key? key}) : super(key: key);

  @override
  State<TemplateLibrary> createState() => _TemplateLibraryState();
}
// ... (rest of the file is unchanged and correct)
