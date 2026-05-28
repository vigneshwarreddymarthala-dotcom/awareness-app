import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String city;
  final String category;

  const PostCard({
    super.key,
    required this.title,
    required this.city,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('$city • $category'),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Useful')),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Experienced'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
