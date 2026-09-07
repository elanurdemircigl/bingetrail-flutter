import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../watchlist/application/watchlist_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.watchlist, super.key});

  final WatchlistController watchlist;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.coral, AppTheme.violet],
                  ),
                ),
                child: const Text(
                  'BT',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Trail',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text(
                      'The journey has just begun.',
                      style: TextStyle(color: AppTheme.mutedText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          AnimatedBuilder(
            animation: watchlist,
            builder: (context, _) {
              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${watchlist.items.length}',
                      label: 'Saved',
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _StatCard(value: '0', label: 'Episodes'),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _StatCard(value: '0h', label: 'Watched'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          Text('Your data', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export your trail'),
                  subtitle: const Text('Download your data as JSON or CSV'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Data source', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                style: TextStyle(color: AppTheme.mutedText, height: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
