import '../../../core/services/session_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../models/post_model.dart';

class PostService {
  static Future<void> addPost(PostModel post) async {
    await SupabaseService.client.from('posts').insert({
      'title': post.title,
      'city': post.city,
      'category': post.category,
      'story': post.story,
      'user_email': post.userEmail,

      'useful_count': 0,
      'useful_votes': [],
    });
  }

  static Future<List<PostModel>> getPosts() async {
    final response = await SupabaseService.client
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    return response.map<PostModel>((post) {
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
  }

  static Future<void> voteUseful(PostModel post) async {
    final currentUser = SessionService.currentUserEmail;

    if (currentUser == null) return;

    if (post.usefulVotes.contains(currentUser)) {
      return;
    }

    final updatedVotes = [...post.usefulVotes, currentUser];

    await SupabaseService.client
        .from('posts')
        .update({
          'useful_count': post.usefulCount + 1,

          'useful_votes': updatedVotes,
        })
        .eq('id', post.id);
  }
}
