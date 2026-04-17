import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'speech_to_text_service.g.dart';

@Riverpod(keepAlive: true)
SpeechToTextService speechToTextService(SpeechToTextServiceRef ref) {
  return SpeechToTextService();
}

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  // Mantém referência ao StreamController ativo para que o status
  // listener registrado no initialize() possa fechá-lo
  StreamController<String>? _activeController;

  Future<bool> requestPermission() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        // onStatus é registrado no initialize() — única API suportada
        onStatus: (String status) {
          debugPrint('STT Status: $status');
          // Quando o engine para (pauseFor expirou, stop() chamado, timeout),
          // fechamos o stream para disparar o onDone no VoiceInputProvider
          if (status == stt.SpeechToText.doneStatus ||
              status == stt.SpeechToText.notListeningStatus) {
            final ctrl = _activeController;
            if (ctrl != null && !ctrl.isClosed) {
              ctrl.close();
              _activeController = null;
            }
          }
        },
      );
    }
    return _isInitialized;
  }

  /// Retorna um Stream com os fragmentos do que o usuário está falando.
  /// O Stream é fechado quando o resultado final chega ou o engine para,
  /// disparando o callback [onDone] no VoiceInputProvider para avançar para NLP.
  Stream<String> startListening() {
    final controller = StreamController<String>();
    _activeController = controller;

    if (!_isInitialized) {
      controller.addError(Exception('Microfone não inicializado / Sem Permissão'));
      controller.close();
      _activeController = null;
      return controller.stream;
    }

    // No v7.3.0: cancelOnError/partialResults/listenMode → SpeechListenOptions
    // localeId/listenFor/pauseFor → parâmetros diretos do listen()
    final listenOptions = stt.SpeechListenOptions(
      cancelOnError: true,
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
    );

    _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        // Atualiza o texto parcial na UI enquanto o usuário fala
        if (!controller.isClosed) {
          controller.add(result.recognizedWords);
        }
        // Resultado definitivo → fecha o stream → dispara onDone no provider
        if (result.finalResult && !controller.isClosed) {
          controller.close();
          _activeController = null;
        }
      },
      localeId: 'pt_BR',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      listenOptions: listenOptions,
    );

    return controller.stream;
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      // O onStatus no initialize() cuidará de fechar o controller
    }
  }

  bool get isListening => _speech.isListening;
}
