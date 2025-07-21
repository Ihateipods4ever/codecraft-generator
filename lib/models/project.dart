import 'package:intl/intl.dart'; // Import intl for date formatting

/// Represents a project with its details.
class Project {
  final String name;
  final String framework;
  final DateTime? lastModified; // Nullable DateTime
  final String status;
  final String description;
  final double progress;

  Project({
    required this.name,
    required this.framework,
    this.lastModified, // Now nullable
    required this.status,
    required this.description,
    required this.progress,
  });

  /// Helper to format the lastModified date for display.
  /// Returns 'N/A' if lastModified is null.
  String get formattedLastModified {
    if (lastModified == null) {
      return 'N/A';
    }
    // You can customize your desired date format here.
    // Example: 'yyyy-MM-dd' or 'MMM dd, yyyy'
    return DateFormat('MMM dd, yyyy').format(lastModified!);
  }
}