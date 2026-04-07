import 'package:flutter/material.dart';

class SyncStatusBadge extends StatelessWidget {
  final bool synced;

  const SyncStatusBadge({super.key, required this.synced});

  @override
  Widget build(BuildContext context) {
    if (synced) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.cloud_done, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text('Sincronizado', style: TextStyle(fontSize: 10, color: Colors.green)),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.cloud_upload, color: Colors.orange, size: 16),
          SizedBox(width: 4),
          Text('Pendente', style: TextStyle(fontSize: 10, color: Colors.orange)),
        ],
      );
    }
  }
}
