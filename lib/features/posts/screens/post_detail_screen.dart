import 'package:flutter/material.dart';
import '../../profile/screens/user_profile_screen.dart';
import '../../../models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              post.title,

              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Chip(label: Text(post.city)),

                const SizedBox(width: 10),

                Chip(label: Text(post.category)),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.person),

                const SizedBox(width: 8),

                Text(
                  post.userEmail,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'What Happened',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(post.story, style: const TextStyle(fontSize: 18, height: 1.6)),

            const SizedBox(height: 40),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        UserProfileScreen(userEmail: post.userEmail),
                  ),
                );
              },

              child: Row(
                children: [
                  const Icon(Icons.person),

                  const SizedBox(width: 8),

                  Text(
                    post.userEmail,

                    style: const TextStyle(
                      fontWeight: FontWeight.w600,

                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
