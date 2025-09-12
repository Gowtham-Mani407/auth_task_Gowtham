import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {}

class SignUpRequesteve extends AuthEvent  {
  final String email;
  final String password;

  SignUpRequesteve(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}

class LoginRequesteve extends AuthEvent {
  final String email;
  final String password;
  LoginRequesteve(this.email , this.password);
  
  @override
  List<Object?> get props => [email, password];
}

class LogoutRequesteve extends AuthEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}
