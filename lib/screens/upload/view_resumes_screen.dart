import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/resume_provider.dart';
import '../../models/analysis_model.dart';
import '../analysis/analysis_screen.dart';

class ViewResumesScreen extends StatelessWidget {
  const ViewResumesScreen({super.key});

  Color _getScoreColor(int score) {
    if (score >= 75) return AppColors.primary; // NVIDIA Green
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  void _showDeleteDialog(BuildContext context, ResumeProvider rp, String docId, String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Evaluation?'),
        content: Text('Are you sure you want to permanently delete the analysis for "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await rp.deleteAnalysis(docId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted analysis for "$fileName"')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Evaluation History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: Consumer<ResumeProvider>(
        builder: (context, rp, _) {
          if (rp.analyses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_edu_outlined,
                    size: 80,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No evaluations found.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload a resume to begin AI analysis.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rp.analyses.length,
            itemBuilder: (context, index) {
              final item = rp.analyses[index];
              final docId = item['id'] as String;
              final fileName = item['fileName'] as String? ?? 'Unnamed Resume';
              final score = item['atsScore'] as int? ?? 0;
              final summaryText = item['summary'] as String? ?? '';
              final ts = item['createdAt'];

              String dateString = 'Unknown Date';
              if (ts is Timestamp) {
                final dt = ts.toDate();
                dateString = '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }

              final scoreColor = _getScoreColor(score);

              return Card(
                color: AppColors.card,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1.5,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Reconstruct model to display
                    final analysis = AnalysisModel(
                      atsScore: score,
                      summary: summaryText,
                      strengths: List<String>.from(item['strengths'] ?? []),
                      weaknesses: List<String>.from(item['weaknesses'] ?? []),
                      missingKeywords: List<String>.from(item['missingKeywords'] ?? []),
                      recommendations: List<String>.from(item['recommendations'] ?? []),
                    );

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AnalysisScreen(
                          fileName: fileName,
                          analysis: analysis,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        // Score Ring Badge
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: scoreColor, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              '$score',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Resume info metadata
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateString,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Deletion Trash Action
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'Delete Evaluation',
                          onPressed: () => _showDeleteDialog(context, rp, docId, fileName),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
