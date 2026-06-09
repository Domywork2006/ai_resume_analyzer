import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/resume_provider.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/info_card.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/action_button.dart';
import '../../widgets/section_header.dart';
import '../auth/login_screen.dart';
import '../upload/upload_resume_screen.dart';
import '../upload/view_resumes_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ScrollController _scrollController;
  bool _showElevation = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 0;
    if (isScrolled != _showElevation) {
      setState(() => _showElevation = isScrolled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ResumeProvider>(
      builder: (context, authProvider, resumeProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No user logged in',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final recentAnalysisName = resumeProvider.analyses.isNotEmpty
            ? resumeProvider.analyses.first['fileName'] as String? ?? 'N/A'
            : 'None';

        final avgScore = resumeProvider.analyses.isEmpty
            ? 0
            : (resumeProvider.analyses
                        .map((a) => a['atsScore'] as int? ?? 0)
                        .fold<int>(0, (sum, score) => sum + score) /
                    resumeProvider.analyses.length)
                .round();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Pinned App Bar with Profile Header & Settings Action
              SliverAppBar(
                expandedHeight: 220,
                floating: false,
                pinned: true,
                elevation: _showElevation ? 4 : 0,
                backgroundColor: AppColors.secondary,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    tooltip: 'Settings & API Key',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeader(
                    user: user,
                    onEditProfile: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Dashboard content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      // Analytics Statistics Section
                      SectionHeader(
                        title: 'ATS Analytics',
                        subtitle: 'Overview of resume evaluations',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StatsCard(
                              label: 'Evaluations',
                              value: resumeProvider.analysisCount.toString(),
                              icon: Icons.analytics_outlined,
                              accentColor: AppColors.primary, // NVIDIA Green
                            ),
                            StatsCard(
                              label: 'Highest Score',
                              value: resumeProvider.analyses.isEmpty
                                  ? 'N/A'
                                  : '${resumeProvider.highestAtsScore}%',
                              icon: Icons.emoji_events_outlined,
                              accentColor: Colors.amber[700]!,
                            ),
                            StatsCard(
                              label: 'Avg Score',
                              value: resumeProvider.analyses.isEmpty
                                  ? 'N/A'
                                  : '$avgScore%',
                              subtitle: 'ATS Match Rate',
                              icon: Icons.trending_up,
                              accentColor: Colors.teal,
                            ),
                            StatsCard(
                              label: 'Recent Resume',
                              value: recentAnalysisName,
                              icon: Icons.history_outlined,
                              accentColor: Colors.blueGrey,
                            ),
                          ],
                        ),
                      ),

                      // Quick Actions Section
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Quick Actions',
                        subtitle: 'Evaluate or manage your resumes',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ActionButton(
                              label: 'Analyze New Resume',
                              icon: Icons.upload_file_outlined,
                              backgroundColor: AppColors.primary, // NVIDIA green accent
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const UploadResumeScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            ActionButton(
                              label: 'View Analysis History',
                              icon: Icons.history,
                              backgroundColor: AppColors.secondary,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ViewResumesScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Account details summary card
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'User Profile',
                        subtitle: 'Linked credentials',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          color: AppColors.card,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                InfoCard(
                                  title: 'Email Address',
                                  value: user.email ?? 'N/A',
                                  icon: Icons.email_outlined,
                                  iconColor: AppColors.primary,
                                ),
                                const Divider(height: 20),
                                InfoCard(
                                  title: 'Account Verification',
                                  value: user.emailVerified ? 'Verified' : 'Unverified',
                                  icon: user.emailVerified ? Icons.verified_user : Icons.gpp_maybe,
                                  iconColor: user.emailVerified ? AppColors.primary : Colors.orange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Session Controls
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ActionButton(
                          label: 'Sign Out',
                          icon: Icons.logout_outlined,
                          isOutlined: true,
                          onPressed: () async {
                            try {
                              await authProvider.logout();
                              if (context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Logout failed: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
