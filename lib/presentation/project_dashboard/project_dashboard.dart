import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// Keep this import for _parseRelativeTime

import '../../core/app_export.dart';
import '../../models/project.dart'; // Import the central Project model
import './widgets/empty_state_widget.dart';
import './widgets/project_card_widget.dart';
import './widgets/stats_card_widget.dart';
// Ensure CustomIconWidget is imported

class ProjectDashboard extends StatefulWidget {
  const ProjectDashboard({Key? key}) : super(key: key);

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  // Helper function to parse relative time strings into DateTime objects
  DateTime? _parseRelativeTime(String relativeTime) {
    final now = DateTime.now();
    if (relativeTime.contains('hours ago')) {
      final hours = int.tryParse(relativeTime.split(' ')[0]);
      if (hours != null) {
        return now.subtract(Duration(hours: hours));
      }
    } else if (relativeTime.contains('day ago') || relativeTime.contains('days ago')) {
      final days = int.tryParse(relativeTime.split(' ')[0]);
      if (days != null) {
        return now.subtract(Duration(days: days));
      } else if (relativeTime == '1 day ago') { // Handle singular "1 day ago"
        return now.subtract(const Duration(days: 1));
      }
    }
    // Return null if parsing fails or for other formats
    return null;
  }

  // Initialize projects with DateTime objects for lastModified
  late final List<Project> _projects;

  @override
  void initState() {
    super.initState();
    _projects = [
      Project(
        name: 'E-commerce App',
        framework: 'React',
        lastModified: _parseRelativeTime('2 hours ago'), // Convert to DateTime
        status: 'Active',
        description: 'Full-stack e-commerce application with payment integration',
        progress: 0.75,
      ),
      Project(
        name: 'Portfolio Website',
        framework: 'Vue',
        lastModified: _parseRelativeTime('1 day ago'), // Convert to DateTime
        status: 'Completed',
        description: 'Personal portfolio website with modern design',
        progress: 1.0,
      ),
      Project(
        name: 'Task Manager',
        framework: 'Flutter',
        lastModified: _parseRelativeTime('3 days ago'), // Convert to DateTime
        status: 'In Progress',
        description: 'Cross-platform task management application',
        progress: 0.45,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Projects',
            style: AppTheme.lightTheme.textTheme.titleLarge),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: CustomIconWidget(
                iconName: 'science',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24),
            onPressed: () {
              Navigator.pushNamed(context, '/openai-demo-screen');
            },
          ),
          IconButton(
            icon: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: StatsCardWidget(
                    title: 'Total Projects',
                    value: '${_projects.length}',
                    icon: 'folder',
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: StatsCardWidget(
                    title: 'Active',
                    value:
                        '${_projects.where((p) => p.status == 'Active' || p.status == 'In Progress').length}',
                    icon: 'trending_up',
                    color: AppTheme.successLight,
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/code-generation-screen');
                    },
                    icon: CustomIconWidget(
                        iconName: 'add', color: Colors.white, size: 20),
                    label: const Text( // Removed Flexible/Expanded here
                      'New Project',
                      overflow: TextOverflow.ellipsis, // Directly apply ellipsis
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.h)),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/template-library');
                    },
                    icon: CustomIconWidget(
                        iconName: 'library_books',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20),
                    label: const Text( // Removed Flexible/Expanded here
                      'Templates',
                      overflow: TextOverflow.ellipsis, // Directly apply ellipsis
                    ),
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.h)),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Projects section
            Text('Recent Projects',
                style: AppTheme.lightTheme.textTheme.titleMedium),
            SizedBox(height: 2.h),

            // Projects list
            if (_projects.isEmpty)
              EmptyStateWidget(
                onCreateProject: () {
                  Navigator.pushNamed(context, '/code-generation-screen');
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: ProjectCardWidget(
                      project: project,
                      onTap: () {
                        Navigator.pushNamed(context, '/code-preview-screen');
                      },
                      onLongPress: () {
                        // Handle long press, e.g., show a dialog with options
                        _showProjectOptions(context, project);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showProjectOptions(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Project'),
                onTap: () {
                  Navigator.pop(bc); // Close the bottom sheet
                  // Implement edit project logic
                  print('Edit project: ${project.name}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Project'),
                onTap: () {
                  Navigator.pop(bc); // Close the bottom sheet
                  // Implement delete project logic
                  print('Delete project: ${project.name}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Project'),
                onTap: () {
                  Navigator.pop(bc); // Close the bottom sheet
                  // Implement share project logic
                  print('Share project: ${project.name}');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
