import 'package:flutter/material.dart';

import '../../../core/services/session_service.dart';
import '../../../models/post_model.dart';
import '../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final titleController = TextEditingController();

  final cityController = TextEditingController();

  final categoryController = TextEditingController();

  final storyController = TextEditingController();

  bool loading = false;

  Future<void> createPost() async {
    if (titleController.text.isEmpty ||
        cityController.text.isEmpty ||
        categoryController.text.isEmpty ||
        storyController.text.isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    final post = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),

      title: titleController.text,

      city: cityController.text,

      category: categoryController.text,

      story: storyController.text,

      userEmail: SessionService.currentUserEmail!,

      usefulCount: 0,

      usefulVotes: [],
    );

    await PostService.addPost(post);

    titleController.clear();
    cityController.clear();
    categoryController.clear();
    storyController.clear();

    setState(() {
      loading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post created!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Awareness Post')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            TextField(
              controller: titleController,

              decoration: const InputDecoration(
                labelText: 'Hook Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: cityController,

              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: categoryController,

              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: storyController,

              maxLines: 8,

              decoration: const InputDecoration(
                labelText: 'What happened?',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: loading ? null : createPost,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Publish Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
