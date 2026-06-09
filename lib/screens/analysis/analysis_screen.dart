import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/analysis_model.dart';

class AnalysisScreen extends StatelessWidget {
  final String fileName;
  final AnalysisModel analysis;

  const AnalysisScreen({
    required this.fileName,
    required this.analysis,
    super.key,
  });

  Color _getScoreColor(int score) {
    if (score >= 75) return AppColors.primary; // NVIDIA green
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 75) return 'Good Match';
    if (score >= 50) return 'Needs Improvement';
    return 'Low Match Rate';
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(analysis.atsScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ATS Report',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Meta Details
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // ATS Score Gauge Card
                Card(
                  color: AppColors.card,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        // Circular Gauge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: analysis.atsScore / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${analysis.atsScore}',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor,
                                  ),
                                ),
                                const Text(
                                  '/ 100',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getScoreLabel(analysis.atsScore),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Overall ATS Compatibility Rating',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Executive Summary Card
                _buildSectionCard(
                  title: 'Executive Summary',
                  icon: Icons.notes_outlined,
                  iconColor: Colors.blue,
                  child: Text(
                    analysis.summary,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Strengths Card
                _buildSectionCard(
                  title: 'Key Strengths',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.primary,
                  child: Column(
                    children: analysis.strengths
                        .map((s) => _buildBulletRow(s, Icons.check, AppColors.primary))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Weaknesses Card
                _buildSectionCard(
                  title: 'Areas for Improvement',
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.orange,
                  child: Column(
                    children: analysis.weaknesses
                        .map((w) => _buildBulletRow(w, Icons.close, Colors.orange))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Recommendations Card
                _buildSectionCard(
                  title: 'Actionable Recommendations',
                  icon: Icons.lightbulb_outline,
                  iconColor: Colors.amber[800]!,
                  child: Column(
                    children: analysis.recommendations
                        .map((r) => _buildBulletRow(r, Icons.star_border, Colors.amber[800]!))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Missing Keywords Card
                _buildSectionCard(
                  title: 'Missing Keywords & Skills',
                  icon: Icons.label_off_outlined,
                  iconColor: Colors.red,
                  child: analysis.missingKeywords.isEmpty
                      ? const Text(
                          'No missing keywords detected. Great job matching the core criteria!',
                          style: TextStyle(color: AppColors.textSecondary),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: analysis.missingKeywords
                              .map((kw) => Chip(
                                    label: Text(kw),
                                    backgroundColor: Colors.red[50],
                                    labelStyle: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    side: BorderSide(color: Colors.red[100]!),
                                  ))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Card(
      color: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBulletRow(String text, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.top(2.0),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
