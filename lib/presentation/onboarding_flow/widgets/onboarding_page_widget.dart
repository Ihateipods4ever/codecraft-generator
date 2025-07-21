// lib/presentation/onboarding_flow/widgets/onboarding_page_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // Make sure sizer is imported here if you use .h, .w

class OnboardingPageWidget extends StatelessWidget {
  final Widget illustration;
  final String headline;
  final String description;

  const OnboardingPageWidget({
    Key? key,
    required this.illustration,
    required this.headline,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 4.h),
          illustration, // The content causing potential layout issues might be here
          SizedBox(height: 4.h),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}