import 'package:flutter/material.dart';

import '../../features/feed/screens/feed_screen.dart';
import '../../features/posts/screens/create_post_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../core/services/session_service.dart';
import '../../core/utils/auth_guard.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      FeedScreen(key: UniqueKey()),

      CreatePostScreen(key: UniqueKey()),

      ProfileScreen(key: UniqueKey()),
    ];

    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          if (index != 0 && !SessionService.isLoggedIn()) {
            showAuthDialog(context);
            return;
          }
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),

          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Create'),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
