import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  final String id;
  final String name;
  final String url;
  final String type;
  final String path;
  final DateTime? uploadedAt;

  FileModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.path,
    required this.uploadedAt,
  });

  factory FileModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FileModel(
      id: doc.id,
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      type: data['type'] ?? '',
      path: data['path'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "url": url,
      "type": type,
      "path": path,
      "uploadedAt": uploadedAt != null
          ? Timestamp.fromDate(uploadedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
