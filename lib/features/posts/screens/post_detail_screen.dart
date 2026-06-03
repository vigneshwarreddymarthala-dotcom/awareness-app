import 'package:flutter/material.dart';

import '../../../core/services/session_service.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../models/post_model.dart';
import '../services/post_service.dart';
import '../../profile/screens/user_profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostModel _post;
  bool _voting = false;

  static const _categoryColors = <String, Color>{
    'health': Color(0xFF4CAF50),
    'safety': Color(0xFFF44336),
    'environment': Color(0xFF00BCD4),
    'community': Color(0xFF9C27B0),
    'finance': Color(0xFFFF9800),
    'education': Color(0xFF2196F3),
    'technology': Color(0xFF3F51B5),
    'food': Color(0xFFE91E63),
    'police': Color(0xFF5C6BC0),
    'transport': Color(0xFF00897B),
  };

  Color get _catColor =>
      _categoryColors[_post.category.toLowerCase()] ?? const Color(0xFF6C63FF);

  static String _maskedName(String email) {
    final prefix = email.split('@').first;
    if (prefix.isEmpty) return 'Anonymous';
    final visible =
        prefix.length >= 3 ? prefix.substring(0, 2) : prefix.substring(0, 1);
    return '${visible.toLowerCase()}****';
  }

  static String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    if (d.inDays < 30) return '${(d.inDays / 7).floor()}w ago';
    if (d.inDays < 365) return '${(d.inDays / 30).floor()}mo ago';
    return '${(d.inDays / 365).floor()}y ago';
  }

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  bool get _hasVoted =>
      _post.usefulVotes.contains(SessionService.currentUserEmail);

  Future<void> _vote() async {
    if (!SessionService.isLoggedIn()) {
      showAuthDialog(context);
      return;
    }
    if (_hasVoted || _voting) return;
    setState(() => _voting = true);
    await PostService.voteUseful(_post);
    if (!mounted) return;
    // Optimistic update — avoids a second round-trip
    setState(() {
      _post = PostModel(
        id: _post.id,
        title: _post.title,
        city: _post.city,
        category: _post.category,
        story: _post.story,
        userEmail: _post.userEmail,
        usefulCount: _post.usefulCount + 1,
        usefulVotes: [..._post.usefulVotes, SessionService.currentUserEmail!],
        createdAt: _post.createdAt,
      );
      _voting = false;
    });
  }

  void _goToProfile() {
    if (!SessionService.isLoggedIn()) {
      showAuthDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userEmail: _post.userEmail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor;
    final masked = _maskedName(_post.userEmail);
    final initial = _post.userEmail.isNotEmpty
        ? _post.userEmail[0].toUpperCase()
        : '?';
    final time = _relativeTime(_post.createdAt);
    final voted = _hasVoted;
    final usefulLabel =
        '${_post.usefulCount} ${_post.usefulCount == 1 ? 'person' : 'people'} found this useful';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      // ── App bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: color,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Post',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _post.category,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Main post card ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Author row ────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar — tappable
                      GestureDetector(
                        onTap: _goToProfile,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name + meta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _goToProfile,
                              child: Text(
                                masked,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                if (time.isNotEmpty) ...[
                                  Icon(Icons.access_time_rounded,
                                      size: 11,
                                      color: Colors.grey.shade400),
                                  const SizedBox(width: 3),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('·',
                                      style: TextStyle(
                                          color: Colors.grey.shade400)),
                                  const SizedBox(width: 8),
                                ],
                                Icon(Icons.location_on_outlined,
                                    size: 11,
                                    color: Colors.grey.shade400),
                                const SizedBox(width: 2),
                                Text(
                                  _post.city,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // View profile link (right side)
                      GestureDetector(
                        onTap: _goToProfile,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Profile',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.arrow_forward_ios,
                                size: 10, color: color),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Title ─────────────────────────────────────────────────
                  Text(
                    _post.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade100, thickness: 1.5),
                  const SizedBox(height: 20),

                  // ── Story ──────────────────────────────────────────────────
                  Text(
                    _post.story,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.85,
                      color: Color(0xFF3A3A5C),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade100, thickness: 1.5),
                  const SizedBox(height: 14),

                  // ── Useful count ───────────────────────────────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up_alt_rounded,
                        size: 15,
                        color: voted
                            ? const Color(0xFF6C63FF)
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        usefulLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 1),

            // ── Action bar ────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Mark useful
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (voted || _voting) ? null : _vote,
                      icon: _voting
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: voted
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              voted
                                  ? Icons.thumb_up_alt_rounded
                                  : Icons.thumb_up_alt_outlined,
                              size: 15,
                            ),
                      label: Text(
                        voted ? 'Useful ✓' : 'Mark Useful',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: voted
                            ? const Color(0xFF6C63FF)
                            : Colors.grey.shade700,
                        side: BorderSide(
                          color: voted
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Author profile
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _goToProfile,
                      icon: const Icon(Icons.person_outline, size: 15),
                      label: const Text(
                        'Author Profile',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 1),

            // ── Context strip ─────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  _MetaBadge(
                    icon: Icons.label_outline,
                    label: _post.category,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  _MetaBadge(
                    icon: Icons.location_on_outlined,
                    label: _post.city,
                    color: Colors.grey.shade600,
                    bgColor: Colors.grey.shade100,
                    textColor: Colors.grey.shade700,
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

// ─── Small meta badge ─────────────────────────────────────────────────────────

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? bgColor;
  final Color? textColor;

  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.color,
    this.bgColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = bgColor ?? color.withValues(alpha: 0.1);
    final text = textColor ?? color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
