import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';

class PdfService {
  /// Picks a PDF file using FilePicker
  Future<File?> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('ℹ️ File picker cancelled or returned no files.');
        return null;
      }

      final path = result.files.single.path;
      if (path == null) {
        throw Exception('Selected file path is null');
      }

      return File(path);
    } catch (e) {
      debugPrint('❌ Error picking PDF: $e');
      rethrow;
    }
  }

  /// Extracts all text from a PDF file using Syncfusion PDF Extractor
  Future<String> extractText(File file) async {
    try {
      debugPrint('📄 Starting text extraction for: ${file.path}');
      final bytes = await file.readAsBytes();
      
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      
      document.dispose();
      debugPrint('✓ Text extraction completed. Length: ${text.length} characters');
      return text;
    } catch (e) {
      debugPrint('❌ Error extracting text from PDF: $e');
      throw Exception('Failed to extract text from PDF: $e');
    }
  }
}