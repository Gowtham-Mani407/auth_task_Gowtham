import 'dart:io';
import 'package:auth_task_firebase/bloc/file_upload/upload_bloc.dart';
import 'package:auth_task_firebase/bloc/file_upload/upload_event.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Color green = Colors.green;

Future<File> resizeImage(
  File file, {
  int width = 800,
  int height = 600,
  int quality = 80,
}) async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return file;
  }

  final targetPath =
      '${file.parent.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';

  final XFile? result = await FlutterImageCompress.compressAndGetFile(
    file.path,
    targetPath,
    minWidth: width,
    minHeight: height,
    quality: quality,
  );

  return result != null ? File(result.path) : file;
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

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    int sdkVersion = 30;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      sdkVersion = androidInfo.version.sdkInt;
    } catch (e) {
      debugPrint("Error fetching device info: $e");
    }

    PermissionStatus status;
    if (sdkVersion >= 33) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      return true;
    } else {
      debugPrint('Permission not granted. Status: $status');
      return false;
    }
  } else {
    return true;
  }
}

Future<void> showImagePreview(BuildContext context, String url) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(child: CircularProgressIndicator(color: green)),
  );

  try {
    final response = await http.get(Uri.parse(url));

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/preview.jpg');
    await tempFile.writeAsBytes(response.bodyBytes);

    final resizedFile = await resizeImage(tempFile);

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.file(resizedFile, fit: BoxFit.contain),
        ),
      ),
    );
  } catch (e) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Failed to load image: $e")));
  }
}

Future<void> downloadFile(
  String url,
  String fileName,
  BuildContext context,
) async {
  try {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      debugPrint("Storage permission denied");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to download files.')),
      );
      return;
    }

    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }
    
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // 4. Download the file
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      debugPrint("File saved to: ${file.path}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File stored in ${file.path}')),
      );
    } else {
      debugPrint("Download failed: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed with status code: ${response.statusCode}')),
      );
    }
  } catch (e) {
    debugPrint("Download error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download error: $e')),
    );
  }
}

