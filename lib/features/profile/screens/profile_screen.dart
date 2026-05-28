import 'package:flutter/material.dart';

import '../../../core/services/session_service.dart';
import '../../../models/post_model.dart';
import '../../auth/screens/login_screen.dart';
import '../../posts/services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<PostModel>> futurePosts;

  @override
  void initState() {
    super.initState();

    futurePosts = PostService.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = SessionService.currentUserEmail ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Align(
              alignment: Alignment.topRight,

              child: ElevatedButton.icon(
                onPressed: () async {
                  await SessionService.logout();

                  Navigator.pushAndRemoveUntil(
                    context,

                    MaterialPageRoute(builder: (_) => const LoginScreen()),

                    (route) => false,
                  );
                },

                icon: const Icon(Icons.logout),

                label: const Text('Logout'),
              ),
            ),

            const SizedBox(height: 20),

            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),

            const SizedBox(height: 16),

            Text(
              currentUser,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            const Text(
              'My Posts',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<PostModel>>(
                future: futurePosts,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('No posts yet'));
                  }

                  final myPosts = snapshot.data!.where((post) {
                    return post.userEmail == currentUser;
                  }).toList();

                  if (myPosts.isEmpty) {
                    return const Center(child: Text('No posts yet'));
                  }

                  return ListView.builder(
                    itemCount: myPosts.length,

                    itemBuilder: (context, index) {
                      final post = myPosts[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),

                        child: ListTile(
                          leading: const Icon(Icons.warning_amber_rounded),

                          title: Text(post.title),

                          subtitle: Text('${post.city} • ${post.category}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
