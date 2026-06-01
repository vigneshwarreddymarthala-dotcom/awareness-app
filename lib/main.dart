import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/navigation/main_navigation.dart';
import 'core/services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dzosorsbqqzazsoxdnwt.supabase.co',
    anonKey: 'sb_publishable_9yhOZKG1o0mh1_3WB84rYQ_ktfm7Q7F',
  );

  await SessionService.loadSession();

  runApp(const AwarenessApp());
}

class AwarenessApp extends StatelessWidget {
  const AwarenessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Awareness App',

      theme: ThemeData(primarySwatch: Colors.blue),

      home: const MainNavigation(),
    );
  }
}
