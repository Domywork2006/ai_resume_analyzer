import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/action_button.dart';

class UploadResumeScreen extends StatefulWidget {
  const UploadResumeScreen({super.key});

  @override
  State<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> {
  File? _file;
  bool _isLoading = false;
  String? _error;

  final StorageService _storageService = StorageService();

  Future<void> _pickPdf() async {
    setState(() {
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) {
        throw Exception('Selected file path is null');
      }

      setState(() {
        _file = File(path);
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _upload() async {
    if (_file == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _storageService.uploadPdfFile(_file!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload successful'),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Resume'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Signed in as: ${auth.user?.email ?? 'Unknown'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Pick PDF'),
              onPressed: _isLoading ? null : _pickPdf,
            ),

            const SizedBox(height: 12),

            if (_file != null)
              Text(
                'Selected: ${_file!.path.split(Platform.pathSeparator).last}',
              ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const Spacer(),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (!_isLoading)
              ActionButton(
                label: 'Upload Resume',
                icon: Icons.cloud_upload,
                onPressed: _file == null
                    ? () {}
                    : () {
                        _upload();
                      },
              ),
          ],
        ),
      ),
    );
  }
}
