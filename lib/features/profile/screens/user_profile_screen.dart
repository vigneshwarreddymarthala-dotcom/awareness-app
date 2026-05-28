import 'package:flutter/material.dart';

import '../../../models/post_model.dart';
import '../../posts/services/post_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userEmail;

  const UserProfileScreen({super.key, required this.userEmail});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<List<PostModel>> futurePosts;

  @override
  void initState() {
    super.initState();

    futurePosts = PostService.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),

      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No posts found'));
          }

          final userPosts = snapshot.data!.where((post) {
            return post.userEmail == widget.userEmail;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const CircleAvatar(
                  radius: 40,

                  child: Icon(Icons.person, size: 40),
                ),

                const SizedBox(height: 16),

                Text(
                  widget.userEmail,

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Posts (${userPosts.length})',

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: userPosts.length,

                    itemBuilder: (context, index) {
                      final post = userPosts[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),

                        child: ListTile(
                          leading: const Icon(Icons.warning_amber_rounded),

                          title: Text(post.title),

                          subtitle: Text('${post.city} • ${post.category}'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
