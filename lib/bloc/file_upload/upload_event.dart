import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class FileEvent extends Equatable {
  const FileEvent();

  @override
  List<Object?> get props => [];
}

class LoadFilesEvent extends FileEvent {}

class UploadFileEvent extends FileEvent {
  final File file;
  final String type; 
  final String fileName;

  const UploadFileEvent(this.file, this.type, this.fileName);

  @override
  List<Object?> get props => [file, type, fileName];
}

class DeleteFileEvent extends FileEvent {
  final String docId; // Firestore document ID
  final String storagePath; // Firebase Storage path

  const DeleteFileEvent(this.docId, this.storagePath);

  @override
  List<Object?> get props => [docId, storagePath];
}
