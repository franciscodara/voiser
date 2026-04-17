import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finwise/core/services/sync_queue_service.dart';
import 'package:finwise/core/services/assistant_listener_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await Hive.initFlutter();
  
  final container = ProviderContainer();
  container.read(syncQueueServiceProvider).startConnectivityListener();
  container.read(assistantListenerServiceProvider).initialize();
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FinwiseApp(),
    ),
  );
}
