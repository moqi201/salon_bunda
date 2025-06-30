import 'package:flutter/material.dart';

class FadeHaircutDetailScreen extends StatelessWidget {
  const FadeHaircutDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Art of the Perfect Fade Haircut'),
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
                'assets/image/rambut.png', // Specific image for this detail
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
              'Mastering the seamless transition from short to long.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'A fade haircut is a timeless and versatile style that offers a clean and polished look. It involves gradually tapering the hair length from top to bottom, creating a seamless blend. There are various types of fades, including low fade, mid fade, high fade, skin fade, and more. Each offers a distinct aesthetic and can be customized to suit different face shapes and personal preferences. Achieving a perfect fade requires skill and precision, often involving multiple clipper guard sizes and blending techniques.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Tips for maintaining your fade:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '- Regular trims are crucial to keep the fade sharp.\n'
              '- Use quality hair products designed for your hair type.\n'
              '- Protect your haircut with a durag or skull cap while sleeping to preserve the shape.',
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
