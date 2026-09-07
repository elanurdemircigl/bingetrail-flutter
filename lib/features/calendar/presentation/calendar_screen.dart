import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        children: [
          Text('Calendar', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text(
            'Upcoming episodes from your shows.',
            style: TextStyle(color: AppTheme.mutedText, fontSize: 16),
          ),
          const SizedBox(height: 30),
          const _DayLabel(label: 'TODAY'),
          const SizedBox(height: 12),
          const _EpisodeTile(
            time: '21:00',
            show: 'Silo',
            episode: 'S02 E07 · The Dive',
            color: Color(0xFF6D5D52),
          ),
          const SizedBox(height: 24),
          const _DayLabel(label: 'FRIDAY · SEP 11'),
          const SizedBox(height: 12),
          const _EpisodeTile(
            time: '03:00',
            show: 'Severance',
            episode: 'S03 E02 · The Map',
            color: Color(0xFF37637B),
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.coral,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        fontSize: 12,
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.time,
    required this.show,
    required this.episode,
    required this.color,
  });

  final String time;
  final String show;
  final String episode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 68,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.play_circle_outline_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(show, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 5),
                  Text(
                    episode,
                    style: const TextStyle(color: AppTheme.mutedText),
                  ),
                ],
              ),
            ),
            Text(time, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
