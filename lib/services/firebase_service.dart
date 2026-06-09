import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/analysis_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves the analysis results to Firestore under `/users/{uid}/analyses`.
  Future<void> saveAnalysis({
    required String uid,
    required String fileName,
    required AnalysisModel analysis,
  }) async {
    try {
      debugPrint('💾 Saving analysis for $fileName in Firestore...');
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('analyses')
          .doc();

      await docRef.set({
        'fileName': fileName,
        'atsScore': analysis.atsScore,
        'summary': analysis.summary,
        'strengths': analysis.strengths,
        'weaknesses': analysis.weaknesses,
        'missingKeywords': analysis.missingKeywords,
        'recommendations': analysis.recommendations,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✓ Analysis saved successfully. Doc ID: ${docRef.id}');
    } catch (e) {
      debugPrint('❌ Firestore saveAnalysis error: $e');
      throw Exception('Failed to save analysis: $e');
    }
  }

  /// Deletes a specific analysis document under `/users/{uid}/analyses/{docId}`.
  Future<void> deleteAnalysis({
    required String uid,
    required String docId,
  }) async {
    try {
      debugPrint('🗑️ Deleting analysis document: $docId');
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('analyses')
          .doc(docId)
          .delete();
      debugPrint('✓ Document deleted.');
    } catch (e) {
      debugPrint('❌ Firestore deleteAnalysis error: $e');
      throw Exception('Failed to delete analysis: $e');
    }
  }

  /// Streams the list of analysis results for the user.
  Stream<QuerySnapshot<Map<String, dynamic>>> getAnalysesStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('analyses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Saves the custom Gemini API key for the user under `/users/{uid}`.
  Future<void> saveUserApiKey({
    required String uid,
    required String apiKey,
  }) async {
    try {
      debugPrint('🔑 Saving custom Gemini API key for UID: $uid');
      await _firestore.collection('users').doc(uid).set({
        'geminiApiKey': apiKey,
      }, SetOptions(merge: true));
      debugPrint('✓ API key saved.');
    } catch (e) {
      debugPrint('❌ Firestore saveUserApiKey error: $e');
      throw Exception('Failed to save API key: $e');
    }
  }

  /// Fetches the custom Gemini API key for the user from `/users/{uid}`.
  Future<String?> getUserApiKey(String uid) async {
    try {
      debugPrint('🔑 Fetching custom Gemini API key for UID: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['geminiApiKey'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Firestore getUserApiKey error: $e');
      return null;
    }
  }
}
