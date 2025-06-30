import 'package:flutter/material.dart';

class PomadeChoiceDetailScreen extends StatelessWidget {
  const PomadeChoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choosing the Right Pomade for Your Style'),
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
                'assets/image/pomade.png', // Specific image for this detail
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
              'Understanding different types of pomade and their hold for your perfect hairstyle.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Pomades are a staple for many modern hairstyles, offering various levels of hold and shine. Choosing the right one depends on your hair type, desired style, and the finish you prefer. They are generally categorized into water-based, oil-based, and clay pomades, each with unique properties and benefits. Knowing the differences can help you achieve the exact look you\'re aiming for, whether it\'s a slick back, a pompadour, or a textured natural look.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Types of Pomade:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '- **Water-based:** Easy to wash out, offers medium to strong hold, often with shine.\n'
              '- **Oil-based:** Provides strong hold and high shine, but can be harder to wash out.\n'
              '- **Clay pomade:** Offers a natural, matte finish with good hold and added volume.',
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
