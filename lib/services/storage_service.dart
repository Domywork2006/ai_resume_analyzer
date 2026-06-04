import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadPdfFile(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final fileName = file.path.split(Platform.pathSeparator).last;
    final storageRef = _storage.ref().child('users/${user.uid}/resumes/$fileName');

    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('resumes')
        .doc();

    await docRef.set({
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }
}
