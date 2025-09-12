import 'dart:async';

import 'package:auth_task_firebase/bloc/auth/auth_event.dart';
import 'package:auth_task_firebase/bloc/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequesteve>(onLoginRequest);
    on<SignUpRequesteve>(onSignUpRequest);
    on<LogoutRequesteve>(onLogoutRequest);
  }

  Future<void> onLoginRequest(event, emit) async {
    emit(AuthLoading());
    try {
      await auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "Login Failed"));
      emit(Unauthenticated());
    }
  }

  Future<void> onSignUpRequest(event, emit) async {
    emit(AuthLoading());
    try {
      await auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "Signup Failed"));
      emit(Unauthenticated());
    }
  }

  Future<void> onLogoutRequest(event, emit) async {
    await auth.signOut();
    emit(Unauthenticated());
  }
}
