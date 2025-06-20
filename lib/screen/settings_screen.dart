import 'package:flutter/material.dart';

import 'package:flt_keep/styles.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Flutter Keep v1.0.0'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Flutter Keep',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.note),
                  children: const [
                    Text('A simple note-taking app built with Flutter.'),
                    SizedBox(height: 16),
                    Text('Notes are stored locally on your device.'),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear All Notes'),
              subtitle: const Text('Delete all notes permanently'),
              onTap: () => _showClearAllDialog(context),
            ),
          ],
        ),
      );

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notes'),
        content: const Text(
          'Are you sure you want to delete all notes? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear all notes
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notes cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
