class AnalysisModel {
  final int atsScore;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> missingKeywords;
  final List<String> recommendations;

  AnalysisModel({
    required this.atsScore,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.missingKeywords,
    required this.recommendations,
  });

  factory AnalysisModel.fromMap(Map<String, dynamic> map) {
    return AnalysisModel(
      atsScore: map['atsScore'] as int? ?? 0,
      summary: map['summary'] as String? ?? '',
      strengths: List<String>.from(map['strengths'] ?? []),
      weaknesses: List<String>.from(map['weaknesses'] ?? []),
      missingKeywords: List<String>.from(map['missingKeywords'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'atsScore': atsScore,
      'summary': summary,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'missingKeywords': missingKeywords,
      'recommendations': recommendations,
    };
  }
}
