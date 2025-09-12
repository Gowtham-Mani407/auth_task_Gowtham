import 'package:equatable/equatable.dart';

class FileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FileLoaded extends FileState {
  final List<Map<String, dynamic>> files;

  FileLoaded(this.files);

  @override
  List<Object?> get props => [files];
}

class FileError extends FileState {
  final String message;

  FileError(this.message);

  @override
  List<Object?> get props => [message];
}

class FileUploaded extends FileState {}
