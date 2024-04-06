import 'package:catalog_1/pages/chatpage.dart';
import 'package:catalog_1/pages/forgotpassword.dart';
import 'package:catalog_1/pages/home.dart';
import 'package:catalog_1/pages/sign-in.dart';
import 'package:catalog_1/pages/sign-up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      home: FirebaseAuth.instance.currentUser != null ? HomePage() : SignIn(),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color.fromARGB(255, 26, 98, 149),
      ),
    );
  }
}
