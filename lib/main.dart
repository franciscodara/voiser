import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finwise/core/services/sync_queue_service.dart';
import 'package:finwise/core/services/assistant_listener_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await Hive.initFlutter();
  
  // Carregar variáveis de ambiente do .env
  await dotenv.load(fileName: ".env");

  // Inicializar o Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
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
