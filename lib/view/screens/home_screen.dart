import 'dart:io';

import 'package:auth_task_firebase/bloc/auth/auth_bloc.dart';
import 'package:auth_task_firebase/bloc/auth/auth_event.dart';
import 'package:auth_task_firebase/bloc/auth/auth_state.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_bloc.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_event.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_state.dart';
import 'package:auth_task_firebase/model/filemodel.dart';
import 'package:auth_task_firebase/view/screens/pdfviewer.dart';
import 'package:auth_task_firebase/view/screens/support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context.read<FileBloc>().add(LoadFilesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, "/login");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("upload Files"),
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(LogoutRequesteve());
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        body: BlocBuilder<FileBloc, FileState>(
          builder: (context, state) {
            List<FileModel> files = [];
            bool isLoading = false;

            if (state is FileLoaded) {
              files = state.files;
            } else if (state is FileLoading) {
              // Preserve old files if available
              if (state.previousFiles != null) {
                files = state.previousFiles!;
              }
              isLoading = true;
            } else if (state is FileError) {
              return Center(child: Text(state.message));
            }

            return Stack(
              children: [
                files.isEmpty
                    ? const Center(child: Text("No file uploaded yet"))
                    : ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final file = files[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: file.type == "pdf"
                                        ? Colors.red[100]
                                        : Colors.blue[100],
                                    child: Icon(
                                      file.type == "pdf"
                                          ? Icons.picture_as_pdf
                                          : Icons.image,
                                      color: file.type == "pdf"
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      file.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.preview,
                                          color: Colors.green,
                                        ),
                                        onPressed: () async {
                                          if (file.type == "image") {
                                            showImagePreview(context, file.url);
                                          } else {
                                            debugPrint(
                                              "file url : ${file.url}",
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfWebViewScreen(
                                                      pdfUrl: file.url,
                                                    ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.download,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () {
                                          downloadFile(
                                            file.url,
                                            file.name,
                                            context,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: showUploadOptions,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Upload PDF"),
                onTap: () {
                  Navigator.pop(context);
                  pickFile(context, "pdf");
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text("Upload Image"),
                onTap: () {
                  Navigator.pop(context);
                  pickFile(context, "image");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

