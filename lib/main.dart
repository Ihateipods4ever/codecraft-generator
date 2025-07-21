import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Remove the sizer import
// import 'package:sizer/sizer.dart' as Sizer;
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Remove the Sizer widget
    return MaterialApp(
      theme: AppTheme.lightTheme,
      title: 'CodeCraft Generator',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.homeScreen,
      routes: AppRoutes.routes,
    );
  }
}
