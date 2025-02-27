import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamController<bool> _connectionStatusController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _hasInitialized = false;

  ConnectivityService() {
    _connectionStatusController = StreamController<bool>.broadcast();
    // Always provide a default value
    _connectionStatusController.add(true);

    // Try to initialize, but don't block on it
    _safeInitialize();
  }

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  Future<void> _safeInitialize() async {
    try {
      if (kIsWeb) return; // Skip on web platforms

      // Listen for changes safely
      try {
        _connectivitySubscription =
            _connectivity.onConnectivityChanged.listen((result) {
          try {
            _updateConnectionStatus(result);
          } catch (e) {
            debugPrint('Error updating connection status: $e');
          }
        });
      } catch (e) {
        debugPrint('Could not listen to connectivity changes: $e');
      }

      // Check initial state safely
      await _safeCheckConnectivity();
      _hasInitialized = true;
    } catch (e) {
      debugPrint('Error during connectivity service initialization: $e');
    }
  }

  Future<void> _safeCheckConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    debugPrint('Connection status changed: $result');
    final isConnected = result != ConnectivityResult.none;
    _connectionStatusController.add(isConnected);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }

  Future<bool> isConnected() async {
    if (kIsWeb || !_hasInitialized)
      return true; // Assume connected on web or if not initialized

    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return true; // Assume connected on error
    }
  }
}
