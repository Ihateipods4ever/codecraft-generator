import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

// Ensure these imports are correct based on your file structure
import '../../core/app_export.dart'; // For AppTheme and possibly CustomIconWidget
import './widgets/framework_selection_widget.dart'; // For FrameworkSelectionWidget
import './widgets/onboarding_page_widget.dart'; // For OnboardingPageWidget
import './widgets/page_indicator_widget.dart'; // For PageIndicatorWidget
// Explicitly importing CustomIconWidget (assuming it's part of app_export or a separate file)

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _typingAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _slideAnimation;

  int _currentPage = 0;
  final int _totalPages = 4;
  String _typedText = '';
  final String _fullText = 'Create a React login form';
  int _currentFrameworkIndex = 0;

  final List<String> _frameworks = ['React', 'Vue', 'Angular'];
  final List<String> _codeExamples = [
    'function LoginForm() {\n  return (\n    <form>\n      <input type="email" />\n      <input type="password" />\n      <button>Login</button>\n    </form>\n  );\n}',
    '<template>\n  <form>\n    <input v-model="email" type="email" />\n    <input v-model="password" type="password" />\n    <button @click="login">Login</button>\n  </form>\n</template>',
    '@Component({\n  template: `\n    <form>\n      <input [(ngModel)]="email" type="email" />\n      <input [(ngModel)]="password" type="password" />\n      <button (click)="login()">Login</button>\n    </form>\n  `\n})'
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _startTypingAnimation();
    _startSlideAnimation();
  }

  void _startTypingAnimation() {
    _typingAnimationController.addListener(() {
      final progress = _typingAnimationController.value;
      final targetLength = (_fullText.length * progress).round();

      if (mounted) {
        setState(() {
          _typedText = _fullText.substring(0, targetLength);
        });
      }
    });

    // We'll let it repeat indefinitely or consider stopping after the first full cycle
    // For an onboarding flow, one cycle might be enough or it could just keep animating.
    _typingAnimationController.repeat(reverse: true);
  }

  void _startSlideAnimation() {
    _slideAnimationController.addListener(() {
      if (_slideAnimationController.isCompleted) {
        setState(() {
          _currentFrameworkIndex =
              (_currentFrameworkIndex + 1) % _frameworks.length;
        });
        _slideAnimationController.reset();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _slideAnimationController.forward();
          }
        });
      }
    });

    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _typingAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Replace with your actual navigation logic
    // For example: Navigator.of(context).pushReplacementNamed('/project-dashboard');
    // Using a simple pop for demonstration if no route is defined
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // If there's no previous route, push the dashboard
      Navigator.pushReplacementNamed(context, '/project-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        // The main content area of the onboarding flow.
        // It uses a Column to arrange elements vertically.
        // The entire content is wrapped in SingleChildScrollView to handle overall scrolling if needed.
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Skip button at the top right
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content displayed via PageView
              // This SizedBox gives the PageView a definite height within the scrollable Column.
              SizedBox(
                height: 70.h, // Fixed height for the PageView. Adjust as needed.
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildPromptInputPage(),
                    _buildMultiFrameworkPage(),
                    _buildMobileFeaturesPage(),
                    _buildFrameworkSelectionPage(),
                  ],
                ),
              ),

              // Bottom navigation area (indicators and buttons)
              // This Container provides consistent padding and acts as the bottom section.
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                child: Column(
                  children: [
                    // Page indicators
                    PageIndicatorWidget(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                    ),

                    SizedBox(height: 3.h),

                    // Navigation buttons (Back and Next/Get Started)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button (only visible on pages after the first)
                        _currentPage > 0
                            ? TextButton(
                                onPressed: _previousPage,
                                child: Text(
                                  'Back',
                                  style: AppTheme.lightTheme.textTheme.labelLarge
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.secondary,
                                  ),
                                ),
                              )
                            : const SizedBox(width: 60), // Placeholder to maintain spacing

                        // Next or Get Started button
                        Expanded( // This Expanded now correctly wraps your existing button structure
                          child: Align( // Use Align to keep the button aligned to the right within its new flexible space
                            alignment: Alignment.centerRight,
                            child:
                                // Your existing Container and ElevatedButton are now correctly nested here
                                Container(
                                  decoration: AppTheme.getAccentGradientDecoration(), // Assuming this returns a BoxDecoration
                                  child: ElevatedButton(
                                    onPressed: _nextPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent, // Makes the button background transparent to show gradient
                                      shadowColor: Colors.transparent, // Removes shadow to prevent it clashing with gradient
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 2.h),
                                    ),
                                    child: Text(
                                      _currentPage == _totalPages - 1
                                          ? 'Get Started'
                                          : 'Next',
                                      style: AppTheme.lightTheme.textTheme.labelLarge
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the first onboarding page
  Widget _buildPromptInputPage() {
    return OnboardingPageWidget(
      headline: 'Natural Language\nCode Generation',
      description:
          'Simply describe what you want to build in plain English. Our AI understands your requirements and generates production-ready code instantly.',
      illustration: Container(
        // FIX: Increased width to provide more space for content
        width: 90.w, // Changed from 80.w
        height: 25.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'chat_bubble_outline',
                size: 48,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Container(
                // Removed fixed width here to allow it to be constrained by padding
                // and the parent 90.w container.
                padding: EdgeInsets.symmetric(horizontal: 5.w), // Adjusted padding for better responsiveness
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                child: Row( // This is the Row at line 163
                  children: [
                    Expanded(
                      child: Text(
                        _typedText,
                        style: AppTheme.getCodeTextStyle(
                          isLight: true,
                          fontSize: 12.sp,
                        ),
                        overflow: TextOverflow.ellipsis, // Added ellipsis to prevent overflow
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 20,
                      color: _typingAnimationController.value > 0.5
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.transparent, // Blinking cursor
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the second onboarding page
  Widget _buildMultiFrameworkPage() {
    return OnboardingPageWidget(
      headline: 'Multi-Framework\nSupport',
      description:
          'Generate code for React, Vue, Angular, Node.js, Python, and more. Switch between frameworks seamlessly with consistent quality.',
      illustration: Container(
        width: 80.w,
        height: 27.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        // Added SingleChildScrollView for the illustration content itself
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Framework tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _frameworks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final framework = entry.value;
                  final isSelected = index == _currentFrameworkIndex;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        framework,
                        style: AppTheme.lightTheme.textTheme.labelMedium
                            ?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 2.h),

              // Code preview with animation
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(100.w * (1 - _slideAnimation.value), 0),
                    child: Opacity(
                      opacity: _slideAnimation.value,
                      child: Container(
                        width: 70.w,
                        height: 12.h,
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        child: SingleChildScrollView( // Allow code to scroll if long
                          child: Text(
                            _codeExamples[_currentFrameworkIndex],
                            style: AppTheme.getCodeTextStyle(
                              isLight: true,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the third onboarding page
  Widget _buildMobileFeaturesPage() {
    final features = [
      {
        'icon': 'mic',
        'title': 'Voice Input',
        'description': 'Speak your ideas',
      },
      {
        'icon': 'cloud_off',
        'title': 'Offline Mode',
        'description': 'Generate without internet',
      },
      {
        'icon': 'file_download',
        'title': 'Export Projects',
        'description': 'Download as ZIP files',
      },
    ];

    return OnboardingPageWidget(
      headline: 'Mobile-First\nDevelopment',
      description:
          'Optimized for mobile developers. Voice input, offline generation, and seamless project export make coding on-the-go effortless.',
      illustration: Container(
        width: 80.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        // Added SingleChildScrollView for the illustration content itself
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'phone_android',
                size: 48,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: features.map((feature) {
                  return Expanded( // Expanded is fine here because the Row has bounded width
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomIconWidget(
                            iconName: feature['icon'] as String,
                            size: 24,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          feature['title'] as String,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          feature['description'] as String,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the final onboarding page with framework selection
  Widget _buildFrameworkSelectionPage() {
    return OnboardingPageWidget(
      headline: 'Choose Your\nFramework',
      description:
          'Select your preferred frameworks to get started. You can always change these later in settings.',
      illustration: Container(
        width: 80.w,
        height: 25.h, // Adjusted height for this illustration
        // Crucially, this SingleChildScrollView allows the content of FrameworkSelectionWidget to scroll
        // if it exceeds 25.h, preventing overflow from FrameworkSelectionWidget itself.
        child: SingleChildScrollView(
          child: FrameworkSelectionWidget(),
        ),
      ),
    );
  }
}
