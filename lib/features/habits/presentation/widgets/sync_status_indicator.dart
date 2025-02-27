import 'package:flutter/material.dart';
import 'package:habit_tracker/core/services/service_locator.dart';
import 'package:habit_tracker/features/habits/data/repositories/local_storage_repository.dart';

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  bool _isOnline = false;
  int _pendingItems = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _checkPendingItems();
    _setupListeners();
  }

  void _setupListeners() {
    ServiceLocator.connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
        });
        if (isConnected) {
          _checkPendingItems();
        }
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await ServiceLocator.connectivityService.isConnected();
    if (mounted) {
      setState(() {
        _isOnline = isConnected;
      });
    }
  }

  Future<void> _checkPendingItems() async {
    final pendingItems = await LocalStorageRepository.instance.getSyncQueue();
    if (mounted) {
      setState(() {
        _pendingItems = pendingItems.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: _isOnline
          ? _pendingItems > 0
              ? '$_pendingItems items pending sync'
              : 'All data synced'
          : 'Offline mode',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _isOnline
              ? _pendingItems > 0
                  ? colorScheme.primaryContainer
                  : colorScheme.secondaryContainer
              : colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isOnline
                  ? _pendingItems > 0
                      ? Icons.sync
                      : Icons.cloud_done
                  : Icons.cloud_off,
              size: 16,
              color: _isOnline
                  ? _pendingItems > 0
                      ? colorScheme.primary
                      : colorScheme.secondary
                  : colorScheme.error,
            ),
            if (_pendingItems > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$_pendingItems',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
