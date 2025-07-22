import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app_export.dart';

void main() async {
  // Ensures that widget binding is initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  // Loads environment variables from the .env file.
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme, // Using the light theme defined in AppTheme.
      title: 'CodeCraft Generator',
      debugShowCheckedModeBanner: false,
      // Corrected: Set the initial route to a valid screen like the splash screen.
      // The 'homeScreen' route was removed from AppRoutes, causing the error.
      initialRoute: AppRoutes.splashScreen,
      // Uses the routes map defined in the AppRoutes class for navigation.
      routes: AppRoutes.routes,
    );
  }
}
