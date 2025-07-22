import 'package:flutter/material.dart';

// TODO: Ensure all these import paths are correct for your project structure.
import 'package:codecraft_generator/presentation/project_dashboard/project_dashboard.dart';
import 'package:codecraft_generator/presentation/splash_screen/splash_screen.dart';
import 'package:codecraft_generator/presentation/onboarding_flow/onboarding_flow.dart';
import 'package:codecraft_generator/presentation/code_generation_screen/code_generation_screen.dart'; // Corrected path
import 'package:codecraft_generator/presentation/template_library/template_library.dart';
import 'package:codecraft_generator/presentation/code_preview_screen/code_preview_screen.dart';
import 'package:codecraft_generator/presentation/all_templates_screen/all_templates_screen.dart';

class AppRoutes {
  // Route constants for type-safe navigation
  static const String projectDashboardScreen = '/project_dashboard_screen';
  static const String openAiDemoScreen = '/openai_demo_screen'; // Note: Screen for this is not imported as it was unused.
  static const String codeGenerationScreen = '/code_generation_screen';
  static const String templateLibraryScreen = '/template_library_screen';
  static const String codePreviewScreen = '/code_preview_screen';
  static const String allTemplatesScreen = '/all_templates_screen';
  static const String splashScreen = '/splash_screen';
  static const String onboardingFlow = '/onboarding_flow';

  static Map<String, WidgetBuilder> routes = {
    // Corrected: Widgets are now called directly with their constructors.
    projectDashboardScreen: (context) => ProjectDashboard(),
    codeGenerationScreen: (context) => CodeGenerationScreen(),
    templateLibraryScreen: (context) => TemplateLibrary(),
    codePreviewScreen: (context) => CodePreviewScreen(),
    // Corrected: Added the required 'categoryData' argument.
    // You may need to adjust the value based on your app's logic.
    allTemplatesScreen: (context) => AllTemplatesScreen(categoryData: {}),
    splashScreen: (context) => SplashScreen(),
    onboardingFlow: (context) => OnboardingFlow(),
  };
}