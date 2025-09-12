import 'dart:io';

import 'package:auth_task_firebase/bloc/auth/auth_bloc.dart';
import 'package:auth_task_firebase/bloc/auth/auth_event.dart';
import 'package:auth_task_firebase/bloc/auth/auth_state.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_bloc.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_event.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            if (state is FileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FileLoaded) {
              if (state.files.isEmpty) {
                return const Center(child: Text("No file uploaded yet"));
              }
              return ListView.builder(
                itemCount: state.files.length,
                itemBuilder: (context, index) {
                  final file = state.files[index];
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
                          // File icon
                          CircleAvatar(
                            backgroundColor: file["type"] == "pdf"
                                ? Colors.red[100]
                                : Colors.blue[100],
                            child: Icon(
                              file["type"] == "pdf"
                                  ? Icons.picture_as_pdf
                                  : Icons.image,
                              color: file["type"] == "pdf"
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // File name (expand to take available space)
                          Expanded(
                            child: Text(
                              file["name"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Action buttons
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.preview,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  if (file["type"] == "image") {
                                    showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                        child: Image.network(
                                          file["url"],
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  } else {
                                    OpenFilex.open(file["url"]);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.black87,
                                ),
                                onPressed: () => OpenFilex.open(file["url"]),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  context.read<FileBloc>().add(
                                    DeleteFileEvent(file["id"], file["path"]),
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
              );
            } else if (state is FileError) {
              debugPrint("error : ${state.message}");
              return Center(child: Text(state.message));
            }
            return const Center(child: Text("No file uploaded yet"));
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

  Future<void> pickFile(BuildContext context, String type) async {
    final fileBloc = context.read<FileBloc>();
    final result = await FilePicker.platform.pickFiles(
      type: type == "pdf" ? FileType.custom : FileType.image,
      allowedExtensions: type == "pdf" ? ["pdf"] : null,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}";

      // if (!mounted) return;
      // context.read<FileBloc>().add(UploadFileEvent(file, type, fileName));
      fileBloc.add(UploadFileEvent(file, type, fileName)); 
    }
  }
}
