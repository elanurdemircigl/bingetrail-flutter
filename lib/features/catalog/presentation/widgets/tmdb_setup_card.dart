import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class TmdbSetupCard extends StatelessWidget {
  const TmdbSetupCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.violet.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.key_rounded, color: AppTheme.violet, size: 34),
          const SizedBox(height: 12),
          Text(
            'Connect the TMDB catalog',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            const Text(
              'Copy config/dev.example.json to config/dev.json, add your API Read Access Token, then restart with:',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedText),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SelectableText(
                'flutter run -d chrome --dart-define-from-file=config/dev.json',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
