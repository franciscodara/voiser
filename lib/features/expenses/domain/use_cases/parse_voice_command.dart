import 'package:finwise/features/expenses/data/datasources/remote/openai_datasource.dart';
import 'package:finwise/features/expenses/domain/entities/voice_command_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parse_voice_command.g.dart';

@Riverpod(keepAlive: true)
ParseVoiceCommandUseCase parseVoiceCommandUseCase(ParseVoiceCommandUseCaseRef ref) {
  return ParseVoiceCommandUseCase(ref.read(openAiDatasourceProvider));
}

class ParseVoiceCommandUseCase {
  final OpenAiDatasource _openAiDatasource;

  ParseVoiceCommandUseCase(this._openAiDatasource);

  Future<VoiceCommandResult> call(String transcribedText) async {
    if (transcribedText.trim().isEmpty) {
      throw const VoiceCommandParseException(
        userMessage: 'Não ouvi nenhum comando. Tente falar o lançamento novamente.',
        debugMessage: 'Texto vazio recebido pelo fluxo de voz.',
      );
    }

    try {
      final result = await _openAiDatasource.parseVoiceCommand(transcribedText);

      if (result.category.trim().isEmpty) {
        throw const VoiceCommandParseException(
          userMessage: 'Não consegui identificar a categoria do lançamento.',
          debugMessage: 'Resultado sem categoria canônica.',
        );
      }

      if (result.amount <= 0 && !result.needsManualReview) {
        throw const VoiceCommandParseException(
          userMessage: 'Não consegui identificar o valor do lançamento.',
          debugMessage: 'Resultado inconsistente: valor ausente sem revisão manual.',
        );
      }

      if (result.type != 'expense' && result.type != 'income') {
        throw VoiceCommandParseException(
          userMessage: 'Não consegui classificar o lançamento em despesa ou receita.',
          debugMessage: 'Tipo inválido retornado: ${result.type}',
        );
      }

      return result;
    } on VoiceCommandParseException {
      rethrow;
    } catch (e) {
      throw VoiceCommandParseException(
        userMessage: 'Não consegui interpretar esse lançamento por voz.',
        debugMessage: 'Erro inesperado no use case: $e',
      );
    }
  }
}

class VoiceCommandParseException implements Exception {
  final String userMessage;
  final String debugMessage;

  const VoiceCommandParseException({
    required this.userMessage,
    required this.debugMessage,
  });

  @override
  String toString() => 'VoiceCommandParseException(userMessage: $userMessage, debugMessage: $debugMessage)';
}
