import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Provider que expõe `true` quando o dispositivo está sem internet.
/// Usa `connectivity_plus` — já instalado no projeto.
@Riverpod(keepAlive: true)
Stream<bool> isOffline(IsOfflineRef ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.isEmpty || results.contains(ConnectivityResult.none),
  );
}
