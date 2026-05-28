import 'package:flutter/material.dart';

import '../../../core/services/supabase_service.dart';
import '../../../models/post_model.dart';
import '../../posts/screens/post_detail_screen.dart';
import '../../posts/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<PostModel> posts = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadPosts();

    SupabaseService.client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
          final updatedPosts = data.map<PostModel>((post) {
            return PostModel(
              id: post['id'].toString(),
              title: post['title'],
              city: post['city'],
              category: post['category'],
              story: post['story'],
              userEmail: post['user_email'],

              usefulCount: post['useful_count'] ?? 0,

              usefulVotes: post['useful_votes'] ?? [],
            );
          }).toList();

          setState(() {
            posts = updatedPosts;

            loading = false;
          });
        });
  }

  Future<void> loadPosts() async {
    final response = await SupabaseService.client
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      posts = response.map<PostModel>((post) {
        return PostModel(
          id: post['id'].toString(),
          title: post['title'],
          city: post['city'],
          category: post['category'],
          story: post['story'],
          userEmail: post['user_email'],

          usefulCount: post['useful_count'] ?? 0,

          usefulVotes: post['useful_votes'] ?? [],
        );
      }).toList();

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Awareness Feed')),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
          ? const Center(child: Text('No posts yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: posts.length,

              itemBuilder: (context, index) {
                final post = posts[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),

                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(post: post),
                        ),
                      );
                    },

                    child: PostCard(post: post),
                  ),
                );
              },
            ),
    );
  }
}
