import 'package:flutter/material.dart';
import 'package:codecraft_generator/presentation/home_screen/home_screen.dart'; // Assuming a home_screen exists

class AppRoutes {
  static const String homeScreen = '/home_screen';

  static Map<String, WidgetBuilder> routes = {
    homeScreen: (context) => HomeScreen(), // Assuming HomeScreen is a valid widget
  };
}