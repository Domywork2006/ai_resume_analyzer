import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/analysis_model.dart';
import '../services/pdf_service.dart';
import '../services/gemini_service.dart';
import '../services/firebase_service.dart';

class ResumeProvider extends ChangeNotifier {
  final PdfService _pdfService = PdfService();
  final GeminiService _geminiService = GeminiService();
  final FirebaseService _firebaseService = FirebaseService();

  File? selectedFile;
  String extractedText = '';
  int atsScore = 0;
  List<String> strengths = [];
  List<String> weaknesses = [];
  List<String> recommendations = [];
  List<String> missingKeywords = [];
  String summary = '';

  bool isLoading = false;
  String statusMessage = '';
  String? error;

  List<Map<String, dynamic>> analyses = [];
  
  int get analysisCount => analyses.length;
  
  int get highestAtsScore {
    if (analyses.isEmpty) return 0;
    return analyses
        .map((a) => a['atsScore'] as int? ?? 0)
        .reduce((max, val) => val > max ? val : max);
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  ResumeProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _sub?.cancel();
      if (user != null) {
        _startListening(user.uid);
      } else {
        analyses = [];
        resetState();
        notifyListeners();
      }
    });
  }

  void _startListening(String uid) {
    _sub = _firebaseService.getAnalysesStream(uid).listen((snapshot) {
      analyses = snapshot.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint('❌ ResumeProvider listen error: $e');
    });
  }

  /// Reset current analysis state (used before a new upload)
  void resetState() {
    selectedFile = null;
    extractedText = '';
    atsScore = 0;
    strengths = [];
    weaknesses = [];
    recommendations = [];
    missingKeywords = [];
    summary = '';
    error = null;
    statusMessage = '';
    notifyListeners();
  }

  /// Exposes standard load history. Handled automatically via Firestore subscription.
  Future<void> loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _startListening(user.uid);
    }
  }

  /// Picks a PDF and resets previous state
  Future<void> pickResume() async {
    try {
      error = null;
      isLoading = true;
      statusMessage = 'Selecting PDF...';
      notifyListeners();

      final file = await _pdfService.pickPdf();
      if (file != null) {
        resetState();
        selectedFile = file;
        statusMessage = 'PDF Selected: ${file.path.split(Platform.pathSeparator).last}';
      } else {
        statusMessage = '';
      }
    } catch (e) {
      error = e.toString();
      statusMessage = 'Picking file failed.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Extracts text from the selected PDF
  Future<void> extractResumeText() async {
    if (selectedFile == null) {
      error = 'No file selected';
      notifyListeners();
      return;
    }
    
    try {
      error = null;
      isLoading = true;
      statusMessage = 'Extracting text from PDF...';
      notifyListeners();

      extractedText = await _pdfService.extractText(selectedFile!);
      statusMessage = 'Text extracted successfully.';
    } catch (e) {
      error = e.toString();
      statusMessage = 'Text extraction failed.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Processes local extraction and analyses with Gemini, then saves to Firestore
  Future<void> analyzeResume(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      error = 'Gemini API key is required. Please check your settings.';
      notifyListeners();
      return;
    }

    if (selectedFile == null) {
      error = 'Please select a PDF file first.';
      notifyListeners();
      return;
    }

    try {
      error = null;
      isLoading = true;

      // Step 1: Extract PDF text if not already done
      if (extractedText.isEmpty) {
        statusMessage = 'Reading and extracting text locally...';
        notifyListeners();
        extractedText = await _pdfService.extractText(selectedFile!);
      }

      // Step 2: Send extracted text to Gemini
      statusMessage = 'Analyzing with Gemini AI (this may take a few seconds)...';
      notifyListeners();
      
      final AnalysisModel result = await _geminiService.analyzeResume(extractedText, apiKey);
      
      atsScore = result.atsScore;
      strengths = result.strengths;
      weaknesses = result.weaknesses;
      recommendations = result.recommendations;
      missingKeywords = result.missingKeywords;
      summary = result.summary;

      // Step 3: Save to Firestore analyses subcollection
      statusMessage = 'Saving analysis results to Firestore...';
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final fileName = selectedFile!.path.split(Platform.pathSeparator).last;
      await _firebaseService.saveAnalysis(
        uid: user.uid,
        fileName: fileName,
        analysis: result,
      );

      statusMessage = 'Success! Resume analyzed.';
    } catch (e) {
      error = e.toString();
      statusMessage = 'Analysis failed.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a historical analysis from Firestore
  Future<void> deleteAnalysis(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firebaseService.deleteAnalysis(uid: user.uid, docId: docId);
    } catch (e) {
      debugPrint('❌ Error deleting analysis: $e');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
