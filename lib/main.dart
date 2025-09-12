import 'package:auth_task_firebase/bloc/auth/auth_bloc.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_bloc.dart';
import 'package:auth_task_firebase/engine/app.dart';
import 'package:auth_task_firebase/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(
          create: (_) => FileBloc(
            FirebaseStorage.instance,
            FirebaseFirestore.instance,
            FirebaseAuth.instance,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}
