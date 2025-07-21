import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

// Assuming AppTheme and CustomIconWidget are imported correctly from your core/app_export.dart
// Adjust path if necessary
// Explicitly imported if not in app_export
import '../widgets/custom_icon_widget.dart';

// NOTE: These placeholder classes for AppTheme and CustomIconWidget are included
// to make this code self-contained and runnable for demonstration.
// In your actual project, ensure AppTheme and CustomIconWidget are correctly
// defined and imported from your `core/app_export.dart` and `widgets/custom_icon_widget.dart`.
// The ColorExtension for `withValues` is removed as `withOpacity` is the standard method.

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF42A5F5), // A shade of blue
      secondary: Color(0xFFFFC107), // A shade of amber
      primaryContainer: Color(0xFFE3F2FD), // Light blue for containers
      onSurface: Colors.black87, // Default text color on surfaces
      onSurfaceVariant: Colors.black54, // Secondary text color on surfaces
      outline: Color(0xFFBBDEFB), // Outline color
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.normal),
      bodyLarge: TextStyle(fontSize: 16.0),
      bodyMedium: TextStyle(fontSize: 14.0),
      labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12.0),
      bodySmall: TextStyle(fontSize: 12.0),
    ),
    cardColor: Colors.white, // Example card color
    dividerColor: Colors.grey.shade300, // Example divider color
    shadowColor: Colors.black12, // Example shadow color
  );

  static Color accentGradientEnd = Colors.blue.shade800; // Example gradient end color

  static BoxDecoration getAccentGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.lightTheme.colorScheme.primary,
          AppTheme.accentGradientEnd,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static TextStyle getCodeTextStyle({required bool isLight, double? fontSize}) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      color: isLight ? Colors.black : Colors.white,
    );
  }

  static List<BoxShadow> getSubtleShadow({required bool isLight}) {
    return [
      BoxShadow(
        color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _loadingAnimation;

  bool _isInitializing = true;
  String _loadingText = "Initializing AI services...";
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
    _setSystemUIOverlay();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _logoController.forward();
    _loadingController.repeat();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    await _simulateInitialization();
    await _checkAuthenticationStatus();
  }

  Future<void> _simulateInitialization() async {
    final List<String> loadingSteps = [
      "Loading AI models...",
      "Caching code templates...",
      "Preparing offline capabilities...",
      "Checking authentication...",
      "Ready to generate code!"
    ];

    for (int i = 0; i < loadingSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _loadingText = loadingSteps[i];
          _progress = (i + 1) / loadingSteps.length;
        });
      }
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isInitializing = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    final bool isAuthenticated = false; // Mock value
    final bool isFirstTime = true; // Mock value

    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/project-dashboard');
    } else if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
              AppTheme.accentGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          // FIX: Wrap the Column in SingleChildScrollView to handle overflow.
          // Children of a SingleChildScrollView's Column should not be Expanded.
          child: SingleChildScrollView(
            child: Column( // This is the Column at line 204
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Allow Column to shrink-wrap its children
              children: [
                // FIX: Removed Expanded wrappers. Children will take their natural size.
                _buildLogoSection(),
                _buildLoadingSection(),
                // Removed SizedBox(height: 8.h) as it was contributing to overflow
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoFadeAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Corrected to withOpacity
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'code',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 12.w,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'CodeCraft',
                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'AI-Powered Code Generation',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9), // Corrected to withOpacity
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70.w,
          height: 0.8.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // Corrected to withOpacity
            borderRadius: BorderRadius.circular(1.h),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 70.w * _progress,
                height: 0.8.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.h),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3), // Corrected to withOpacity
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),
        AnimatedBuilder(
          animation: _loadingAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: 0.5 + (_loadingAnimation.value * 0.5),
              child: Text(
                _loadingText,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8), // Corrected to withOpacity
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        SizedBox(height: 2.h),
        if (_isInitializing)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  final delay = index * 0.2;
                  final animationValue =
                      (_loadingController.value + delay) % 1.0;
                  final opacity = animationValue < 0.5
                      ? animationValue * 2
                      : (1.0 - animationValue) * 2;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
      ],
    );
  }
}
