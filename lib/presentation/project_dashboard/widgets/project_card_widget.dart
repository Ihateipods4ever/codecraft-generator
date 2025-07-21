import 'package:flutter/material.dart';
import '../../../../models/project.dart'; // Import the central Project model

class ProjectCardWidget extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProjectCardWidget({
    Key? key,
    required this.project,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the formattedLastModified getter from the Project model
    final String lastModifiedText = 'Last Modified: ${project.formattedLastModified}';

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8.0),
              Text(
                lastModifiedText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              // Add more project details here, e.g., framework and progress
              const SizedBox(height: 4.0),
              Text(
                'Framework: ${project.framework}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4.0),
              LinearProgressIndicator(
                value: project.progress,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 4.0),
              Text(
                'Progress: ${(project.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
