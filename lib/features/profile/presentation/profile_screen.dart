import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import '../../progress/application/episode_progress_controller.dart';
import '../../sync/application/cloud_sync_controller.dart';
import '../../watchlist/application/watchlist_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.watchlist,
    required this.episodeProgress,
    required this.auth,
    required this.cloudSync,
    super.key,
  });

  final WatchlistController watchlist;
  final EpisodeProgressController episodeProgress;
  final AuthController? auth;
  final CloudSyncController? cloudSync;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        watchlist,
        episodeProgress,
        ?auth,
        ?cloudSync,
      ]),
      builder: (context, _) {
        final user = auth?.user;
        final watchedEpisodes = episodeProgress.entries.fold<int>(
          0,
          (total, entry) => total + entry.watchedEpisodeKeys.length,
        );

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
                    child: Text(
                      _initials(user?.email),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user == null ? 'Your Trail' : 'Trail synced',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          user?.email ?? 'The journey has just begun.',
                          style: const TextStyle(color: AppTheme.mutedText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${watchlist.items.length}',
                      label: 'Saved',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: '$watchedEpisodes',
                      label: 'Episodes',
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _StatCard(value: '—', label: 'Watched'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Account & sync',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (auth == null)
                const _CloudNotConfiguredCard()
              else if (user == null)
                _AuthCard(auth: auth!)
              else
                _SignedInCard(
                  cloudSync: cloudSync!,
                  email: user.email ?? 'Signed-in user',
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
              Text(
                'Data source',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
      },
    );
  }

  static String _initials(String? email) {
    if (email == null || email.isEmpty) {
      return 'BT';
    }
    return email.substring(0, 1).toUpperCase();
  }
}

class _AuthCard extends StatefulWidget {
  const _AuthCard({required this.auth});

  final AuthController auth;

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _signUp = false;
  bool _working = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _working = true;
      _error = null;
    });

    try {
      if (_signUp) {
        final response = await widget.auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
        );
        if (mounted && response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check your email to confirm your account.'),
            ),
          );
        }
      } else {
        await widget.auth.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } on Object {
      if (mounted) {
        setState(() => _error = 'Could not reach Supabase. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _signUp ? 'Create your account' : 'Sign in to BingeTrail',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              const Text(
                'Sync your watchlist and episodes across devices.',
                style: TextStyle(color: AppTheme.mutedText),
              ),
              if (_signUp) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    final length = value?.trim().length ?? 0;
                    return length < 1 || length > 40
                        ? 'Enter a name between 1 and 40 characters.'
                        : null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  return email.contains('@') ? null : 'Enter a valid email.';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) => (value?.length ?? 0) < 6
                    ? 'Password must contain at least 6 characters.'
                    : null,
              ),
              if (_error case final error?) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: AppTheme.coral)),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _working ? null : _submit,
                child: Text(
                  _working
                      ? 'Please wait…'
                      : _signUp
                      ? 'Create account'
                      : 'Sign in',
                ),
              ),
              TextButton(
                onPressed: _working
                    ? null
                    : () => setState(() {
                        _signUp = !_signUp;
                        _error = null;
                      }),
                child: Text(
                  _signUp
                      ? 'Already have an account? Sign in'
                      : 'New to BingeTrail? Create an account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({required this.cloudSync, required this.email});

  final CloudSyncController cloudSync;
  final String email;

  @override
  Widget build(BuildContext context) {
    final status = switch (cloudSync.status) {
      CloudSyncStatus.idle => 'Waiting to sync',
      CloudSyncStatus.syncing => 'Syncing…',
      CloudSyncStatus.synced => 'Your trail is synced',
      CloudSyncStatus.failed => 'Sync failed — try again',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                cloudSync.status == CloudSyncStatus.failed
                    ? Icons.cloud_off_rounded
                    : Icons.cloud_done_outlined,
                color: cloudSync.status == CloudSyncStatus.failed
                    ? AppTheme.coral
                    : AppTheme.violet,
              ),
              title: Text(email),
              subtitle: Text(status),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: cloudSync.status == CloudSyncStatus.syncing
                        ? null
                        : cloudSync.syncNow,
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Sync now'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton.icon(
                    onPressed: cloudSync.status == CloudSyncStatus.syncing
                        ? null
                        : () async {
                            try {
                              await cloudSync.signOut();
                            } on Object {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not sync before signing out.',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CloudNotConfiguredCard extends StatelessWidget {
  const _CloudNotConfiguredCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(18),
        leading: Icon(Icons.cloud_off_outlined, color: AppTheme.mutedText),
        title: Text('Cloud sync is not configured'),
        subtitle: Text(
          'Add your Supabase URL and publishable key to config/dev.json.',
        ),
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
