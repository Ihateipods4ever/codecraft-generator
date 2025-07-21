import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreateProject;

  const EmptyStateWidget({
    Key? key,
    required this.onCreateProject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(context),
            SizedBox(height: 4.h),
            _buildTitle(context),
            SizedBox(height: 2.h),
            _buildDescription(context),
            SizedBox(height: 4.h),
            _buildCreateButton(context),
            SizedBox(height: 3.h),
            _buildSuggestedPrompts(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    return Container(
      width: 60.w,
      height: 30.h,
      decoration: BoxDecoration(
       color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'code',
            color: Theme.of(context).colorScheme.primary,
            size: 80,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTechIcon(context, 'flutter', Color(0xFF02569B)),
              SizedBox(width: 2.w),
              _buildTechIcon(context, 'react', Color(0xFF61DAFB)),
              SizedBox(width: 2.w),
              _buildTechIcon(context, 'vue', Color(0xFF4FC08D)),
              SizedBox(width: 2.w),
              _buildTechIcon(context, 'angular', Color(0xFFDD0031)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechIcon(BuildContext context, String tech, Color color) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // Corrected: was .withValues
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomIconWidget(
        iconName: 'code',
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Create Your First Project',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      'Transform your ideas into production-ready code with AI-powered generation. Start with a simple prompt and watch your vision come to life.',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8), // Corrected: was .withValues
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
           color: Theme.of(context).colorScheme.primary.withOpacity(0.3), // Corrected: was .withValues

            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onCreateProject,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add_circle',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Start Creating',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedPrompts(BuildContext context) {
    final List<Map<String, dynamic>> prompts = [
      {
        "title": "E-commerce App",
        "description": "Create a mobile shopping app with cart and payments",
        "icon": "shopping_cart",
      },
      {
        "title": "Task Manager",
        "description": "Build a productivity app with team collaboration",
        "icon": "task_alt",
      },
      {
        "title": "Weather Dashboard",
        "description": "Design a responsive weather forecast interface",
        "icon": "wb_sunny",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Starter Ideas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        ...prompts.map((prompt) => _buildPromptCard(context, prompt)).toList(),
      ],
    );
  }

  Widget _buildPromptCard(BuildContext context, Map<String, dynamic> prompt) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onCreateProject,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                // This was the problematic block. Corrected:
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomIconWidget(
                iconName: prompt['icon'] as String,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prompt['title'] as String,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    prompt['description'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}