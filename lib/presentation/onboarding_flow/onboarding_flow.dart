import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

// Ensure these imports are correct based on your file structure
import '../../core/app_export.dart'; // For AppTheme and possibly CustomIconWidget
import './widgets/framework_selection_widget.dart'; // For FrameworkSelectionWidget
import './widgets/onboarding_page_widget.dart'; // For OnboardingPageWidget
import './widgets/page_indicator_widget.dart'; // For PageIndicatorWidget

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
    'function LoginForm() {
  return (
    <form>
      <input type="email" />
      <input type="password" />
      <button>Login</button>
    </form>
  );
}',
    '<template>
  <form>
    <input v-model="email" type="email" />
    <input v-model="password" type="password" />
    <button @click="login">Login</button>
  </form>
</template>',
    '@Component({
  template: `
    <form>
      <input [(ngModel)]="email" type="email" />
      <input [(ngModel)]="password" type="password" />
    <button (click)="login()">Login</button>
    </form>
  `
})'
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

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeInOut),
    );

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

    _typingAnimationController.repeat(reverse: true);
  }

  void _startSlideAnimation() {
    _slideAnimationController.addListener(() {
      if (_slideAnimationController.isCompleted) {
        setState(() {
          _currentFrameworkIndex = (_currentFrameworkIndex + 1) % _frameworks.length;
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
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.projectDashboardScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              SizedBox(
                height: 70.h,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildPromptInputPage(context), // Pass context
                    _buildMultiFrameworkPage(context), // Pass context
                    _buildMobileFeaturesPage(context), // Pass context
                    _buildFrameworkSelectionPage(context), // Pass context
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                child: Column(
                  children: [
                    PageIndicatorWidget(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                            : const SizedBox(width: 60),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child:
                                Container(
                                  decoration: AppTheme.getAccentGradientDecoration(),
                                  child: ElevatedButton(
                                    onPressed: _nextPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
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

  Widget _buildPromptInputPage(BuildContext context) { // Accept context
    return OnboardingPageWidget(
      headline: 'Natural Language
Code Generation',
      description:
          'Simply describe what you want to build in plain English. Our AI understands your requirements and generates production-ready code instantly.',
      illustration: Container(
        width: 90.w,
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
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _typedText,
                        style: AppTheme.getCodeTextStyle(
                          isLight: true,
                          fontSize: 12.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 20,
                      color: _typingAnimationController.value > 0.5
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.transparent,
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

  Widget _buildMultiFrameworkPage(BuildContext context) { // Accept context
    return OnboardingPageWidget(
      headline: 'Multi-Framework
Support',
      description:
          'Generate code for React, Vue, Angular, Node.js, Python, and more. Switch between frameworks seamlessly with consistent quality.',
      illustration: Container(
        width: 80.w,
        height: 27.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                        child: SingleChildScrollView(
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

  Widget _buildMobileFeaturesPage(BuildContext context) { // Accept context
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
      headline: 'Mobile-First
Development',
      description:
          'Optimized for mobile developers. Voice input, offline generation, and seamless project export make coding on-the-go effortless.',
      illustration: Container(
        width: 80.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
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
                  return Expanded(
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

  Widget _buildFrameworkSelectionPage(BuildContext context) { // Accept context
    return OnboardingPageWidget(
      headline: 'Choose Your
Framework',
      description:
          'Select your preferred frameworks to get started. You can always change these later in settings.',
      illustration: Container(
        width: 80.w,
        height: 25.h,
        child: SingleChildScrollView(
          child: FrameworkSelectionWidget(onFrameworkSelected: (framework) {  }), // Added missing required argument
        ),
      ),
    );
  }
}
