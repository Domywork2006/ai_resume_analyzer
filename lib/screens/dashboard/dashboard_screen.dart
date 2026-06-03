import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/info_card.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/action_button.dart';
import '../../widgets/section_header.dart';
import '../auth/login_screen.dart';

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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        debugPrint('📊 DashboardScreen rebuilt - user: ${user?.email ?? "null"}');

        if (user == null) {
          debugPrint('❌ DashboardScreen: user is null!');
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
                  Text(
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

        debugPrint('✓ DashboardScreen: User authenticated: ${user.email}');
        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar with Profile Header
              SliverAppBar(
                expandedHeight: 220,
                floating: false,
                pinned: true,
                elevation: _showElevation ? 8 : 0,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeader(user: user),
                ),
              ),
              // Main Content
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Stats Section
                      SectionHeader(
                        title: 'Your Stats',
                        subtitle: 'Track your resume activity',
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
                              label: 'Resumes',
                              value: '0',
                              icon: Icons.description,
                              accentColor: AppColors.secondary,
                            ),
                            StatsCard(
                              label: 'Analyses',
                              value: '0',
                              icon: Icons.analytics,
                              accentColor: Colors.blue,
                            ),
                            StatsCard(
                              label: 'Avg Score',
                              value: 'N/A',
                              subtitle: 'ATS Score',
                              icon: Icons.trending_up,
                              accentColor: Colors.green,
                            ),
                            StatsCard(
                              label: 'Last Review',
                              value: 'Today',
                              icon: Icons.calendar_today,
                              accentColor: Colors.purple,
                            ),
                          ],
                        ),
                      ),

                      // Account Information Section
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Account',
                        subtitle: 'Your account details',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            InfoCard(
                              title: 'Email Address',
                              value: user.email ?? 'N/A',
                              icon: Icons.email,
                              iconColor: AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            InfoCard(
                              title: 'Account Status',
                              value: user.emailVerified
                                  ? 'Verified'
                                  : 'Unverified',
                              icon: user.emailVerified
                                  ? Icons.verified
                                  : Icons.info,
                              iconColor: user.emailVerified
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            InfoCard(
                              title: 'User ID',
                              value: user.uid,
                              icon: Icons.person,
                              iconColor: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),

                      // Quick Actions Section
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Quick Actions',
                        subtitle: 'Get started',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ActionButton(
                              label: 'Upload Resume',
                              icon: Icons.upload_file,
                              onPressed: () {
                                debugPrint('📤 Upload Resume tapped');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Upload feature coming soon'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            ActionButton(
                              label: 'View My Resumes',
                              icon: Icons.file_present,
                              backgroundColor: AppColors.secondary,
                              onPressed: () {
                                debugPrint('👀 View Resumes tapped');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('My Resumes page coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Session Section
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Session',
                        subtitle: 'Manage your account',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            ActionButton(
                              label: 'Logout',
                              icon: Icons.logout,
                              isOutlined: true,
                              onPressed: () async {
                                debugPrint('🔓 Logout tapped');
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
                                  debugPrint('❌ Logout error: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Logout failed: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
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
