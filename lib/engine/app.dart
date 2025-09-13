import 'package:auth_task_firebase/view/screens/home_screen.dart';
import 'package:auth_task_firebase/view/screens/login_screen.dart';
import 'package:auth_task_firebase/view/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return HomeScreen(); 
          }
          return LoginScreen(); 
        },
      ),
      routes: {
        "/login": (_) => LoginScreen(),
        "/signup": (_) => SignupScreen(),
        "/home": (_) => HomeScreen(),
      },
    );
  }
}
