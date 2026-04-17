import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_siri_shortcuts/flutter_siri_shortcuts.dart';
import 'package:finwise/core/router/app_router.dart';

final assistantListenerServiceProvider = Provider((ref) => AssistantListenerService(ref));

class AssistantListenerService {
  final Ref _ref;

  AssistantListenerService(this._ref);

  void initialize() {
    try {
      /* O pacote flutter_siri_shortcuts (0.0.1) atual não suporta .instance.configure().
       * A escuta real das intenções da Siri no Flutter atualmente é feita de duas maneiras:
       * 1. Via MethodChannel escrito manualmente em Runner/AppDelegate.swift
       * 2. Tratando NSUserActivity como um DeepLink, capturado na raiz do App/GoRouter.
       * Deixaremos esta lógica documentada caso o AppDelegated faça callMethod('onListen').
       */
    } catch (_) {
      // Falha ao incializar siri shortcuts em plataformas sem suporte nativo
    }
  }
}
