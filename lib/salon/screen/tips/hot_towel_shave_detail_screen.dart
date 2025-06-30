import 'package:flutter/material.dart';

class HotTowelShaveDetailScreen extends StatelessWidget {
  const HotTowelShaveDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Why a Hot Towel Shave is a Must-Try'),
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
                'assets/image/handuk.png', // Specific image for this detail
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
              'Experience ultimate relaxation and a perfectly clean shave.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'The hot towel shave is a classic barbershop experience that transcends a simple razor glide. It’s a ritual that prepares your skin and beard for the closest, most comfortable shave possible, while also offering a moment of pure relaxation. The warmth of the towel softens the beard hairs, opens up pores, and allows for a smoother blade pass, minimizing irritation and ingrown hairs. It’s more than just a shave; it’s a therapeutic treatment for your face.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Benefits of a Hot Towel Shave:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '- Softens beard hair for an easier cut.\n'
              '- Opens pores, allowing for a deeper cleanse.\n'
              '- Reduces razor burn and ingrown hairs.\n'
              '- Provides a relaxing and luxurious experience.',
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
