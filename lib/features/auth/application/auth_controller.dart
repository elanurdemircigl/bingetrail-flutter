import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._client) {
    _user = _client.auth.currentUser;
    _subscription = _client.auth.onAuthStateChange.listen((state) {
      _user = state.session?.user;
      notifyListeners();
    });
  }

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _subscription;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    final normalizedName = displayName.trim();
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: normalizedName.isEmpty ? null : {'display_name': normalizedName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
