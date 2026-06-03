import 'package:flutter/material.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/auth_guard.dart';
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
              createdAt: post['created_at'] != null
                  ? DateTime.tryParse(post['created_at'].toString())
                  : null,
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
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF),
                    ),
                  )
                : posts.isEmpty
                    ? _EmptyState()
                    : RefreshIndicator(
                        color: const Color(0xFF6C63FF),
                        onRefresh: loadPosts,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: GestureDetector(
                                onTap: () {
                                  if (!SessionService.isLoggedIn()) {
                                    showAuthDialog(context);
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PostDetailScreen(post: post),
                                    ),
                                  );
                                },
                                child: PostCard(post: post),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF48C6EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Awareness Feed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Real stories from real people',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share an experience',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
