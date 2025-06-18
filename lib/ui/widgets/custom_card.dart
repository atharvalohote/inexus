// lib/ui/widgets/custom_card.dart
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title; // Title of the card (e.g., "Device Status")
  final String content; // Main content displayed on the card (e.g., "Online")
  final Color? contentColor; // Optional color for the content text
  final IconData? icon; // Optional icon to display next to the title

  const CustomCard({
    super.key,
    required this.title,
    required this.content,
    this.contentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Shadow depth for the card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded corners
      margin: const EdgeInsets.all(8.0), // Margin around the card
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start (left)
          children: [
            Row(
              children: [
                if (icon != null) ...[ // Conditionally display icon if provided
                  Icon(icon, size: 24, color: Theme.of(context).primaryColor), // Icon with primary color
                  const SizedBox(width: 10), // Spacing between icon and title
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color, // Title text style
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0), // Spacing between title and content
            Text(
              content,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: contentColor ?? Theme.of(context).textTheme.titleLarge?.color, // Content text style, with optional custom color
                fontSize: 28, // Larger font size for content
              ),
            ),
          ],
        ),
      ),
    );
  }
}