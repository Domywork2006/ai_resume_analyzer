import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../models/analysis_model.dart';

class GeminiService {
  /// Analyzes the extracted resume text and returns the ATS Analysis results.
  Future<AnalysisModel> analyzeResume(String resumeText, String apiKey) async {
    try {
      debugPrint('🤖 Initiating Gemini Resume Analysis (using gemini-1.5-flash)...');
      
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
        systemInstruction: Content.system(
          'You are an expert ATS (Applicant Tracking System) reviewer, career coach, and professional resume writer. '
          'Analyze the provided resume text and return a detailed ATS analysis. '
          'You must respond ONLY with a valid JSON object matching this schema:\n'
          '{\n'
          '  "atsScore": 85, // integer 0 to 100 representing ATS match score\n'
          '  "summary": "A 2-3 sentence professional summary highlighting candidate experience and suitability...",\n'
          '  "strengths": ["Key strength 1", "Key strength 2", ...],\n'
          '  "weaknesses": ["Area of improvement 1", "Area of improvement 2", ...],\n'
          '  "missingKeywords": ["Missing skill/keyword 1", "Missing skill/keyword 2", ...],\n'
          '  "recommendations": ["Actionable improvement suggestion 1", "Actionable improvement suggestion 2", ...]\n'
          '}\n'
          'Do not include any other text, markdown headers, or surrounding text outside of this JSON.'
        ),
      );

      final content = [Content.text(resumeText)];
      final response = await model.generateContent(content);
      final jsonText = response.text;

      if (jsonText == null || jsonText.trim().isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      debugPrint('✓ Gemini analysis response received successfully.');
      
      // Sanitization step in case model returns markdown block wrappers
      String sanitized = jsonText.trim();
      if (sanitized.startsWith('```')) {
        final lines = sanitized.split('\n');
        if (lines.first.startsWith('```json')) {
          lines.removeAt(0);
        } else {
          lines.removeAt(0);
        }
        if (lines.last.endsWith('```')) {
          lines.removeLast();
        }
        sanitized = lines.join('\n').trim();
      }

      final Map<String, dynamic> parsedJson = jsonDecode(sanitized);
      return AnalysisModel.fromMap(parsedJson);
    } catch (e) {
      debugPrint('❌ Gemini Analysis Error: $e');
      throw Exception('Failed to analyze resume with Gemini: $e');
    }
  }
}
