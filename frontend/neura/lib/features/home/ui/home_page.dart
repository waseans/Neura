import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Fetch user data or default settings from backend if needed
    // Example: GET /user/profile or /settings

    return Scaffold(
      appBar: AppBar(
        title: const Text('PersonaFlex'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            _HomeTile(
              title: '🎙️ Transcribe Voice',
              subtitle: 'Start live speech transcription',
              onTap: () {
                Navigator.pushNamed(context, '/transcription');
              },
            ),

            _HomeTile(
              title: '🧠 Summarize Conversations',
              subtitle: 'Get summaries of previous sessions',
              onTap: () {
                Navigator.pushNamed(context, '/summary');
              },
            ),

            _HomeTile(
              title: '🧍 Switch Persona',
              subtitle: 'Choose professor, friend, or advisor',
              onTap: () {
                Navigator.pushNamed(context, '/personas');
              },
            ),

            _HomeTile(
              title: '📜 View History',
              subtitle: 'See all your transcripts & summaries',
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
