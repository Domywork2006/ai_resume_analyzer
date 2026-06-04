import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../providers/resume_provider.dart';

class ViewResumesScreen extends StatelessWidget {
  const ViewResumesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Resumes')),
      body: Consumer<ResumeProvider>(builder: (context, rp, _) {
        if (rp.resumes.isEmpty) {
          return const Center(child: Text('No resumes uploaded yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: rp.resumes.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = rp.resumes[index];
            final fileName = item['fileName'] as String? ?? 'Unknown';
            final downloadUrl = item['downloadUrl'] as String? ?? '';
            final ts = item['uploadedAt'];

            String subtitle = '';
            if (ts is Timestamp) {
              final dt = ts.toDate();
              subtitle = '${dt.toLocal()}';
            }

            return ListTile(
              title: Text(fileName),
              subtitle: Text(subtitle),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: downloadUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download URL copied')),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
