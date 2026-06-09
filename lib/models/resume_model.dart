import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeModel {
  final String id;
  final String fileName;
  final String extractedText;
  final DateTime uploadedAt;

  ResumeModel({
    required this.id,
    required this.fileName,
    required this.extractedText,
    required this.uploadedAt,
  });

  factory ResumeModel.fromMap(Map<String, dynamic> map, String docId) {
    return ResumeModel(
      id: docId,
      fileName: map['fileName'] as String? ?? '',
      extractedText: map['extractedText'] as String? ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'extractedText': extractedText,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}
