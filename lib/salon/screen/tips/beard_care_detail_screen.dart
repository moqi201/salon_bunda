import 'package:flutter/material.dart';

class BeardCareDetailScreen extends StatelessWidget {
  const BeardCareDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Essential Beard Care Routine'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/image/jnggt.png', // Specific image for this detail
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tips for a healthy, luscious beard and promoting growth.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Maintaining a healthy and well-groomed beard requires a consistent routine. It goes beyond just letting it grow; proper care prevents itchiness, dryness, and promotes healthier growth. A good routine typically involves washing, conditioning, oiling, and brushing your beard regularly. The right products can make a significant difference in the texture, shine, and overall health of your facial hair.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Your Daily Beard Care Checklist:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '- Wash your beard 2-3 times a week with a specialized beard shampoo.\n'
              '- Apply beard conditioner after washing to keep it soft.\n'
              '- Use beard oil daily to moisturize skin and hair.\n'
              '- Brush your beard with a boar bristle brush to distribute oils and style.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
