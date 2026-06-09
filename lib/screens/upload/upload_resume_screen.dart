import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resume_provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/action_button.dart';
import '../../models/analysis_model.dart';
import '../profile/profile_screen.dart';
import '../analysis/analysis_screen.dart';

class UploadResumeScreen extends StatefulWidget {
  const UploadResumeScreen({super.key});

  @override
  State<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? _apiKey;
  bool _isLoadingKey = true;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
    
    // Reset any previous state in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResumeProvider>(context, listen: false).resetState();
    });
  }

  Future<void> _checkApiKey() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      try {
        final key = await _firebaseService.getUserApiKey(auth.user!.uid);
        if (mounted) {
          setState(() {
            _apiKey = key;
            _isLoadingKey = false;
          });
        }
      } catch (e) {
        debugPrint('❌ Error checking API key: $e');
        if (mounted) {
          setState(() {
            _isLoadingKey = false;
          });
        }
      }
    }
  }

  Future<void> _startAnalysis(ResumeProvider rp) async {
    if (_apiKey == null || _apiKey!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure your Gemini API Key first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await rp.analyzeResume(_apiKey!);

    if (!mounted) return;

    if (rp.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: ${rp.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis Completed!'),
          backgroundColor: AppColors.primary,
        ),
      );

      // Create model from completed state
      final analysis = AnalysisModel(
        atsScore: rp.atsScore,
        summary: rp.summary,
        strengths: rp.strengths,
        weaknesses: rp.weaknesses,
        missingKeywords: rp.missingKeywords,
        recommendations: rp.recommendations,
      );

      final fileName = rp.selectedFile != null
          ? rp.selectedFile!.path.split(Platform.pathSeparator).last
          : 'resume.pdf';

      // Navigate to detailed report screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AnalysisScreen(
            fileName: fileName,
            analysis: analysis,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rp = Provider.of<ResumeProvider>(context);

    final isApiKeyMissing = _apiKey == null || _apiKey!.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analyze Resume',
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // API Key Warning Banner if missing
                if (!_isLoadingKey && isApiKeyMissing)
                  Card(
                    color: Colors.orange[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.orange, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Gemini API Key Missing',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You need to configure your Gemini API Key in your profile settings before you can evaluate resumes.',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.settings, color: Colors.orange),
                            label: const Text('Go to Settings', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              );
                              _checkApiKey(); // re-check when back
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Upload Box / Picker Card
                Card(
                  color: AppColors.card,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 72,
                          color: rp.selectedFile != null ? AppColors.primary : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          rp.selectedFile != null
                              ? rp.selectedFile!.path.split(Platform.pathSeparator).last
                              : 'No resume selected',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: rp.selectedFile != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        if (rp.selectedFile != null) ...[
                          const SizedBox(height: 8),
                          FutureBuilder<int>(
                            future: rp.selectedFile!.length(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final kb = (snapshot.data! / 1024).toStringAsFixed(1);
                                return Text(
                                  '$kb KB • PDF Document',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.search),
                          label: Text(rp.selectedFile != null ? 'Change File' : 'Pick Resume PDF'),
                          onPressed: rp.isLoading || _isLoadingKey ? null : () => rp.pickResume(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Extraction / Analysis Status Logs
                if (rp.isLoading || rp.statusMessage.isNotEmpty)
                  Card(
                    color: AppColors.card,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (rp.isLoading) ...[
                            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            rp.statusMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Error Block
                if (rp.error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        rp.error!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Action Button to run the pipeline
                ActionButton(
                  label: 'Start AI Analysis',
                  icon: Icons.rocket_launch,
                  backgroundColor: AppColors.primary,
                  onPressed: rp.selectedFile == null || rp.isLoading || _isLoadingKey || isApiKeyMissing
                      ? () {}
                      : () => _startAnalysis(rp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
