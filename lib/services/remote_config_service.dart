import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Provides an abstraction for interacting with Firebase Remote Config.
///
/// This service manages Remote Config initialization, default values,
/// fetching, activation, parameter access, and real-time configuration updates.
///
/// It is independent of the application's state management solution.
class RemoteConfigService {
  /// Creates a service backed by the Firebase Remote Config singleton.
  RemoteConfigService({
    FirebaseRemoteConfig? remoteConfig,
  }) : _remoteConfig =
      remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  bool _isInitialized = false;

  /// Initializes Remote Config with default values and fetch settings.
  ///
  /// Default values ensure that the application has fallback configuration
  /// values when remote values are unavailable.
  ///
  /// This method does not fetch remote values. Call [fetchAndActivate]
  /// separately to retrieve and activate the latest available configuration.
  ///
  /// Throws an exception if initialization fails.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults(
      const <String, dynamic>{
        'show_promo_banner': false,
        'is_new_feature_enabled': false,
        'promo_banner_text': 'Welcome!',
      },
    );

    _isInitialized = true;
  }

  Future<void> setupRemoteConfig() async {
    await initialize();

    try {
      await fetchAndActivate();
    } catch (error, stackTrace) {
      // Log the error and continue using available defaults
      // or previously activated configuration values.
    }
  }

  /// Fetches the latest available configuration and activates it.
  ///
  /// Returns `true` if newly fetched values were activated, or `false`
  /// if no new configuration needed activation.
  ///
  /// The actual fetch behavior is subject to Firebase Remote Config's
  /// fetch settings and caching policies.
  ///
  /// Throws an exception if fetching or activation fails.
  Future<bool> fetchAndActivate() async {
    _ensureInitialized();

    return _remoteConfig.fetchAndActivate();
  }

  /// Returns the active Boolean value associated with [key].
  ///
  /// If no remote value is available, the configured default value
  /// or the SDK's fallback behavior is used.
  bool getBool(String key) {
    _ensureInitialized();

    return _remoteConfig.getBool(key);
  }

  /// Returns the active String value associated with [key].
  String getString(String key) {
    _ensureInitialized();

    return _remoteConfig.getString(key);
  }

  /// Returns the active integer value associated with [key].
  int getInt(String key) {
    _ensureInitialized();

    return _remoteConfig.getInt(key);
  }

  /// Returns the active double value associated with [key].
  double getDouble(String key) {
    _ensureInitialized();

    return _remoteConfig.getDouble(key);
  }

  /// Listens for real-time Remote Config updates.
  ///
  /// Firebase automatically fetches new configuration values when
  /// an update becomes available.
  ///
  /// Before emitting an update event, this stream activates the fetched
  /// configuration so that subsequent getter calls can read the new values.
  ///
  /// Each event contains the set of parameter keys associated with the update.
  ///
  /// Errors from the underlying stream or activation are forwarded to
  /// the stream listener and should be handled by the subscriber.
  ///
  /// The caller is responsible for managing and cancelling its subscription.
  Stream<Set<String>> get onConfigUpdated {
    _ensureInitialized();

    return _remoteConfig.onConfigUpdated.asyncMap((update) async {
      await _remoteConfig.activate();

      return update.updatedKeys;
    });
  }

  /// Ensures that Remote Config has been initialized before use.
  ///
  /// Throws a [StateError] if a public operation is called before
  /// [initialize] completes successfully.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'RemoteConfigService must be initialized before use.',
      );
    }
  }
}