import 'package:flutter/material.dart';

import '../../../models/post_model.dart';
import '../services/post_service.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(widget.post.category),
                ),

                const Spacer(),

                Row(
                  children: [
                    const Icon(Icons.location_city, size: 18),

                    const SizedBox(width: 4),

                    Text(widget.post.city),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              widget.post.title,

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loading
                        ? null
                        : () async {
                            setState(() {
                              loading = true;
                            });

                            await PostService.voteUseful(widget.post);

                            setState(() {
                              widget.post.usefulCount + 1;

                              loading = false;
                            });
                          },

                    icon: const Icon(Icons.thumb_up),

                    label: Text('Useful (${widget.post.usefulCount})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
