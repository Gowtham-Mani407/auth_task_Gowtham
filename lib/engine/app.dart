import 'package:auth_task_firebase/view/screens/home_screen.dart';
import 'package:auth_task_firebase/view/screens/login_screen.dart';
import 'package:auth_task_firebase/view/screens/signup_screen.dart';
import 'package:flutter/material.dart';

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
      initialRoute: "/login",
      routes: {
        "/login": (_) => LoginScreen(),
        "/signup": (_) => SignupScreen(),
        "/home": (_) => HomeScreen(),
      },
    );
  }
}
