import 'package:face_recognition/signup_login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC68etew1p6LwtAKZRY0C3j04CUYdEIUns",
      appId: "1:170691460886:android:b48d7955f18050d30d9a37",
      messagingSenderId: "170691460886",
      projectId: "fyp1-43120",
    ),
  );
  await FaceCamera.initialize();
  _deleteCacheDir();
  runApp(MyApp());
}

Future<void> _deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();
  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogIn(),
    );
  }
}
