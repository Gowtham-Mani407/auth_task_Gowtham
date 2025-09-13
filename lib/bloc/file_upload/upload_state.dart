import 'package:auth_task_firebase/model/filemodel.dart';
import 'package:equatable/equatable.dart';

class FileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileInitial extends FileState {}

class FileLoading extends FileState {
  final List<FileModel>? previousFiles; // optional previous list

  FileLoading({this.previousFiles});

  @override
  List<Object?> get props => [previousFiles];
}

class FileLoaded extends FileState {
  final List<FileModel> files;

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
