import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sync_metadata_service.g.dart';

@Riverpod(keepAlive: true)
SyncMetadataService syncMetadataService(SyncMetadataServiceRef ref) {
  return SyncMetadataService();
}

class SyncMetadataService {
  static const _lastSyncKey = 'last_sync_at';

  Future<DateTime?> getLastSyncAt() async {
    final prefs = await SharedPreferences.getInstance();
    final isoString = prefs.getString(_lastSyncKey);
    if (isoString == null) return null;
    return DateTime.tryParse(isoString);
  }

  Future<void> setLastSyncAt(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, date.toUtc().toIso8601String());
  }
}
