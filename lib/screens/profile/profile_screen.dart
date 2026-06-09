import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final SettingsService _settingsService = SettingsService();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isSaving = false;
  bool _isLoadingKey = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // 1. Try loading from local storage first
    try {
      final localKey = await _settingsService.getLocalApiKey();
      if (localKey != null && localKey.isNotEmpty && mounted) {
        _apiKeyController.text = localKey;
        setState(() {
          _isLoadingKey = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Local API key load error: $e');
    }

    // 2. Load from Firestore in parallel to sync
    if (user != null) {
      try {
        final firestoreKey = await _firebaseService.getUserApiKey(user.uid);
        if (firestoreKey != null && firestoreKey.isNotEmpty && mounted) {
          if (_apiKeyController.text != firestoreKey) {
            _apiKeyController.text = firestoreKey;
            await _settingsService.saveLocalApiKey(firestoreKey);
          }
        }
      } catch (e) {
        debugPrint('❌ Cloud API key load error: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoadingKey = false;
      });
    }
  }

  Future<void> _saveApiKey() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // 1. Save locally (guaranteed to succeed)
    await _settingsService.saveLocalApiKey(apiKey);

    // 2. Try syncing to Firestore
    bool syncedToCloud = false;
    if (user != null) {
      try {
        await _firebaseService.saveUserApiKey(
          uid: user.uid,
          apiKey: apiKey,
        );
        syncedToCloud = true;
      } catch (e) {
        debugPrint('⚠️ Cloud sync failed (saved locally only): $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(syncedToCloud
              ? 'Gemini API Key saved and synced to cloud!'
              : 'Gemini API Key saved locally on this device!'),
          backgroundColor: AppColors.primary,
        ),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: user == null
          ? const Center(child: Text('Please log in.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Info Card
                      Card(
                        color: AppColors.card,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user.photoURL == null
                                    ? const Icon(Icons.person, size: 45, color: AppColors.secondary)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.displayName ?? 'Resume Analyzer User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user.email ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gemini Configuration Card
                      Card(
                        color: AppColors.card,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.vpn_key, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Gemini API Settings',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              const Text(
                                'To analyze resumes, this app uses the Gemini API. Please enter your Gemini API Key. '
                                'The key is saved securely under your personal account profile in Firestore.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _isLoadingKey
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                        ),
                                      ),
                                    )
                                  : TextField(
                                      controller: _apiKeyController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Gemini API Key',
                                        hintText: 'AIzaSy...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        prefixIcon: const Icon(Icons.key_outlined),
                                      ),
                                    ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isSaving || _isLoadingKey ? null : _saveApiKey,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Save Key',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
