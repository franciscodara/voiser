import 'package:finwise/core/services/speech_to_text_service.dart';
import 'package:finwise/features/expenses/domain/entities/voice_command_result.dart';
import 'package:finwise/features/expenses/domain/use_cases/parse_voice_command.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_input_provider.g.dart';

enum VoiceInputStateStatus {
  idle,
  requestingPermission,
  listening,
  processing,
  confirming,
  manualFallback,
  confirmed,
  error
}

const _voiceInputSentinel = Object();

class VoiceInputState {
  final VoiceInputStateStatus status;
  final String currentText;
  final VoiceCommandResult? result;
  final String? errorMessage;

  const VoiceInputState({
    this.status = VoiceInputStateStatus.idle,
    this.currentText = '',
    this.result,
    this.errorMessage,
  });

  VoiceInputState copyWith({
    VoiceInputStateStatus? status,
    String? currentText,
    Object? result = _voiceInputSentinel,
    Object? errorMessage = _voiceInputSentinel,
  }) {
    return VoiceInputState(
      status: status ?? this.status,
      currentText: currentText ?? this.currentText,
      result: identical(result, _voiceInputSentinel) ? this.result : result as VoiceCommandResult?,
      errorMessage: identical(errorMessage, _voiceInputSentinel) ? this.errorMessage : errorMessage as String?,
    );
  }
}

@riverpod
class VoiceInputNotifier extends _$VoiceInputNotifier {
  @override
  VoiceInputState build() {
    return const VoiceInputState();
  }

  Future<void> startListening() async {
    state = state.copyWith(
      status: VoiceInputStateStatus.requestingPermission,
      errorMessage: null,
    );

    final sttService = ref.read(speechToTextServiceProvider);
    final hasPermission = await sttService.requestPermission();

    if (!hasPermission) {
      state = state.copyWith(
        status: VoiceInputStateStatus.error,
        errorMessage: 'Permissão de microfone negada.',
      );
      return;
    }

    state = state.copyWith(
      status: VoiceInputStateStatus.listening,
      currentText: 'Estou te ouvindo...',
    );

    sttService.startListening().listen(
      (text) {
        state = state.copyWith(currentText: text);
      },
      onDone: () async {
        if (state.currentText.isNotEmpty && state.currentText != 'Estou te ouvindo...') {
          await _processText(state.currentText);
        } else {
          state = state.copyWith(status: VoiceInputStateStatus.idle);
        }
      },
      onError: (Object e) {
        state = state.copyWith(
          status: VoiceInputStateStatus.error,
          errorMessage: e.toString(),
        );
      },
      cancelOnError: true,
    );
  }

  Future<void> stopAndProcess() async {
    final sttService = ref.read(speechToTextServiceProvider);
    await sttService.stopListening();
  }

  Future<void> _processText(String text) async {
    state = state.copyWith(
      status: VoiceInputStateStatus.processing,
      errorMessage: null,
      result: null,
    );

    try {
      final useCase = ref.read(parseVoiceCommandUseCaseProvider);
      final result = await useCase.call(text);

      if (result.needsManualReview && result.type == 'expense') {
        state = state.copyWith(
          status: VoiceInputStateStatus.manualFallback,
          result: result,
        );
        return;
      }

      state = state.copyWith(
        status: VoiceInputStateStatus.confirming,
        result: result,
      );
    } on VoiceCommandParseException catch (e) {
      state = state.copyWith(
        status: VoiceInputStateStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (_) {
      state = state.copyWith(
        status: VoiceInputStateStatus.error,
        errorMessage: 'Não consegui entender esse lançamento. Tente falar valor e categoria.',
      );
    }
  }

  Future<void> processDirectText(String text) async {
    state = state.copyWith(status: VoiceInputStateStatus.listening, currentText: text);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _processText(text);
  }

  void confirm() {
    state = state.copyWith(status: VoiceInputStateStatus.confirmed);
  }

  void consumeManualFallback() {
    state = state.copyWith(
      status: VoiceInputStateStatus.idle,
      result: null,
      errorMessage: null,
    );
  }

  Future<void> cancel() async {
    final sttService = ref.read(speechToTextServiceProvider);
    await sttService.stopListening();
    state = const VoiceInputState();
  }
}
