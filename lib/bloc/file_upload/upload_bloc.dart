import 'dart:async';

import 'package:auth_task_firebase/bloc/file_upload/upload_event.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final FirebaseStorage storage;
  FirebaseFirestore firestore;
  final FirebaseAuth auth;
  FileBloc(this.storage, this.firestore, this.auth) : super(FileInitial()) {
    on<LoadFilesEvent>(onLoadFiles);
    on<UploadFileEvent>(onUploadFile);
    on<DeleteFileEvent>(onDeleteFile);
  }

  Future<void> onLoadFiles(event, emit) async {
    emit(FileLoading());
    try {
      emit(FileLoading());

      final user = auth.currentUser!;
      final snapshot = await firestore
          .collection("user_uploads")
          .doc(user.uid)
          .collection("files")
          .orderBy("uploadedAt", descending: true)
          .get();

      final files = snapshot.docs
          .map((doc) => {...doc.data(), "id": doc.id})
          .toList();

      emit(FileLoaded(files));
    } catch (e) {
      emit(FileError("Failed to load files: $e"));
    }
  }

  Future<void> onUploadFile(event, emit) async {
    try {
      emit(FileLoading());
      final user = auth.currentUser!;
      final safeFileName = event.fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');

      // final storage = FirebaseStorage.instanceFor(
      //   bucket: 'all-apps-6cf99.firebasestorage.app',
      // );
      final ref = storage.ref().child("user_uploads/${user.uid}/$safeFileName");

      print("Uploading file to: ${ref.fullPath}");
      print("Local file exists: ${event.file.existsSync()}");

      final uploadTask = await ref.putFile(event.file);
      print("Upload complete!");

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print("Download URL: $downloadUrl");

      await firestore
          .collection("user_uploads")
          .doc(user.uid)
          .collection("files")
          .add({
            "name": safeFileName,
            "url": downloadUrl,
            "type": event.type,
            "path": ref.fullPath,
            "uploadedAt": FieldValue.serverTimestamp(),
          });

      add(LoadFilesEvent());
    } catch (e) {
      print("Upload error: $e");
      emit(FileError("Upload failed: $e"));
    }
  }

  Future<void> onDeleteFile(event, emit) async {
    try {
      emit(FileLoading());

      final user = auth.currentUser!;
      await storage.ref(event.storagePath).delete();

      await firestore
          .collection("user_uploads")
          .doc(user.uid)
          .collection("files")
          .doc(event.docId)
          .delete();

      add(LoadFilesEvent());
    } catch (e) {
      emit(FileError("Delete failed: $e"));
    }
  }
}
