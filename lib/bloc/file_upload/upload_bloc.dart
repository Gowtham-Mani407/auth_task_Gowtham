import 'dart:async';
import 'dart:io';

import 'package:auth_task_firebase/bloc/file_upload/upload_event.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_state.dart';
import 'package:auth_task_firebase/model/filemodel.dart';
import 'package:auth_task_firebase/view/screens/support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final FirebaseStorage storage;
  FirebaseFirestore firestore;
  final FirebaseAuth auth;
  FileBloc(this.storage, this.firestore, this.auth) : super(FileInitial()) {
    on<LoadFilesEvent>(onLoadFiles);
    on<UploadFileEvent>(onUploadFile);
  }

  Future<void> onLoadFiles(event, emit) async {
    List<FileModel> currentFiles = [];

    if (state is FileLoaded) {
      currentFiles = (state as FileLoaded).files;
    }
    emit(FileLoading(previousFiles: currentFiles));

    try {
      final user = auth.currentUser!;
      final snapshot = await firestore
          .collection("user_uploads")
          .doc(user.uid)
          .collection("files")
          .orderBy("uploadedAt", descending: true)
          .get();

      final files = snapshot.docs.map((doc) => FileModel.fromDoc(doc)).toList();

      emit(FileLoaded(files));
    } catch (e) {
      emit(FileError("Failed to load files: $e"));
    }
  }

  Future<void> onUploadFile(event, emit) async {
    List<FileModel> currentFiles = [];
    if (state is FileLoaded) {
      currentFiles = (state as FileLoaded).files;
    }

    emit(FileLoading(previousFiles: currentFiles));
    try {
      final user = auth.currentUser!;
      final safeFileName = event.fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
      final ref = storage.ref().child("user_uploads/${user.uid}/$safeFileName");

      debugPrint("Uploading file to: ${ref.fullPath}");
      debugPrint("Local file exists: ${event.file.existsSync()}");

      File fileToUpload = event.file;

      if (event.type == "image") {
        fileToUpload = await resizeImage(event.file);
      }

      final uploadTask = await ref.putFile(fileToUpload);
      debugPrint("Upload complete!");

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint("Download URL: $downloadUrl");

      final docRef = firestore
          .collection("user_uploads")
          .doc(user.uid)
          .collection("files")
          .doc();

      final newFile = FileModel(
        id: docRef.id,
        name: safeFileName,
        url: downloadUrl,
        type: event.type,
        path: ref.fullPath,
        uploadedAt: DateTime.now(),
      );

      await docRef.set(newFile.toMap());

      add(LoadFilesEvent());
    } catch (e) {
      print("Upload error: $e");
      emit(FileError("Upload failed: $e"));
    }
  }
}


      // final files = snapshot.docs
      //     .map((doc) => {...doc.data(), "id": doc.id})
      //     .toList();

      //   await firestore
      // .collection("user_uploads")
      // .doc(user.uid)
      // .collection("files")
      // .add({
      //   "name": safeFileName,
      //   "url": downloadUrl,
      //   "type": event.type,
      //   "path": ref.fullPath,
      //   "uploadedAt": FieldValue.serverTimestamp(),
      // });