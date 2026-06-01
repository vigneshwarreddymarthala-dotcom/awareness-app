import 'package:flutter/material.dart';

import '../../../core/services/session_service.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../models/post_model.dart';
import '../services/post_service.dart';
import '../../profile/screens/user_profile_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool loading = false;

  static const _categoryColors = {
    'Health': Color(0xFF4CAF50),
    'Safety': Color(0xFFF44336),
    'Environment': Color(0xFF00BCD4),
    'Community': Color(0xFF9C27B0),
    'Finance': Color(0xFFFF9800),
    'Education': Color(0xFF2196F3),
    'Technology': Color(0xFF3F51B5),
    'Food': Color(0xFFE91E63),
  };

  Color get _categoryColor =>
      _categoryColors[widget.post.category] ?? const Color(0xFF6C63FF);

  void _openProfile(BuildContext context) {
    if (!SessionService.isLoggedIn()) {
      showAuthDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userEmail: widget.post.userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored accent bar at top
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip + city
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          30,
                          color.r.toInt(),
                          color.g.toInt(),
                          color.b.toInt(),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.post.category,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.post.city,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Color(0xFF1A1A2E),
                  ),
                ),

                const SizedBox(height: 8),

                // Story preview
                Text(
                  widget.post.story,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 14),

                // Footer: tappable author + vote button
                Row(
                  children: [
                    // Author — tappable → profile
                    GestureDetector(
                      onTap: () => _openProfile(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Color.fromARGB(
                              40,
                              color.r.toInt(),
                              color.g.toInt(),
                              color.b.toInt(),
                            ),
                            child: Text(
                              widget.post.userEmail.isNotEmpty
                                  ? widget.post.userEmail[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              widget.post.userEmail,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Vote button
                    GestureDetector(
                      onTap: loading
                          ? null
                          : () async {
                              if (!SessionService.isLoggedIn()) {
                                showAuthDialog(context);
                                return;
                              }
                              setState(() => loading = true);
                              await PostService.voteUseful(widget.post);
                              setState(() => loading = false);
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: loading
                              ? Colors.grey.shade100
                              : const Color(0xFFEEECFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: loading
                                ? Colors.grey.shade300
                                : const Color(0xFFB0ACFF),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 14,
                              color: loading
                                  ? Colors.grey
                                  : const Color(0xFF6C63FF),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.post.usefulCount}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: loading
                                    ? Colors.grey
                                    : const Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
