import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:finwise/core/constants/api_constants.dart';
import 'package:finwise/core/constants/default_categories.dart';
import 'package:finwise/features/expenses/domain/entities/category.dart';
import 'package:finwise/features/expenses/domain/entities/voice_command_result.dart';
import 'package:finwise/features/expenses/domain/use_cases/parse_voice_command.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'openai_datasource.g.dart';

@Riverpod(keepAlive: true)
OpenAiDatasource openAiDatasource(OpenAiDatasourceRef ref) {
  return OpenAiDatasource();
}

class OpenAiDatasource {
  final Dio _dio = Dio();

  Future<VoiceCommandResult> parseVoiceCommand(String text) async {
    final trimmedText = text.trim();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiConstants.openAiApiKey}',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
        data: {
          'model': 'gpt-4o-mini',
          'response_format': {'type': 'json_object'},
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': 'Texto reconhecido: "$trimmedText"'},
          ],
          'temperature': 0.1,
        },
      );

      final data = response.data;
      final responseBody = data?['choices']?[0]?['message']?['content'];
      final payload = _decodePayload(responseBody);
      return _normalizeResult(payload, originalText: trimmedText);
    } on DioException catch (e) {
      final fallback = _heuristicParse(trimmedText);
      if (fallback != null) {
        return fallback;
      }

      throw VoiceCommandParseException(
        userMessage: 'Não consegui falar com a IA agora. Tente novamente em instantes.',
        debugMessage: 'Falha de rede/timeout comunicando com o GPT: ${e.message}',
      );
    } on VoiceCommandParseException {
      rethrow;
    } catch (e) {
      final fallback = _heuristicParse(trimmedText);
      if (fallback != null) {
        return fallback;
      }

      throw VoiceCommandParseException(
        userMessage: 'Não consegui interpretar o lançamento por voz.',
        debugMessage: 'Falha processando resposta da OpenAI: $e',
      );
    }
  }

  Map<String, dynamic> _decodePayload(dynamic rawContent) {
    final content = rawContent?.toString().trim() ?? '';
    if (content.isEmpty) {
      throw const VoiceCommandParseException(
        userMessage: 'A resposta da IA veio vazia.',
        debugMessage: 'Conteúdo vazio retornado pela API.',
      );
    }

    var cleaned = content;
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    final candidate = _extractJsonObject(cleaned.trim());

    try {
      final decoded = jsonDecode(candidate);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      // Continua para erro semântico abaixo.
    }

    throw VoiceCommandParseException(
      userMessage: 'A resposta da IA não veio em JSON válido.',
      debugMessage: 'Payload inválido: $candidate',
    );
  }

  String _extractJsonObject(String content) {
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');

    if (start >= 0 && end > start) {
      return content.substring(start, end + 1);
    }

    return content;
  }

  VoiceCommandResult _normalizeResult(
    Map<String, dynamic> payload, {
    required String originalText,
  }) {
    final inferredType = _normalizeType(payload['type']?.toString(), originalText);
    final inferredAmount = _parseAmount(payload['amount']) ?? _extractAmount(originalText) ?? 0;
    final inferredCategoryData = _inferCategoryData(
      type: inferredType,
      suggestedCategory: payload['category']?.toString(),
      suggestedSubcategory: payload['subcategory']?.toString(),
      originalText: originalText,
    );

    final description =
        _normalizeString(payload['description']?.toString()) ?? originalText.trim();
    final needsManualReview = _parseBool(payload['needs_manual_review']) ||
        _parseBool(payload['needsManualReview']) ||
        inferredAmount <= 0 ||
        inferredCategoryData.needsManualReview;

    return VoiceCommandResult(
      type: inferredType,
      amount: inferredAmount,
      category: inferredCategoryData.category,
      subcategory: inferredCategoryData.subcategory,
      description: description,
      needsManualReview: needsManualReview,
    );
  }

  VoiceCommandResult? _heuristicParse(String text) {
    final normalizedText = _normalizeText(text);
    if (normalizedText.isEmpty) {
      return null;
    }

    final type = _normalizeType(null, text);
    final amount = _extractAmount(text) ?? 0;
    final categoryData = _inferCategoryData(
      type: type,
      suggestedCategory: null,
      suggestedSubcategory: null,
      originalText: text,
    );

    if (amount <= 0 && categoryData.category == 'Outros') {
      return null;
    }

    return VoiceCommandResult(
      type: type,
      amount: amount,
      category: categoryData.category,
      subcategory: categoryData.subcategory,
      description: text.trim(),
      needsManualReview: amount <= 0 || categoryData.needsManualReview,
    );
  }

  String _normalizeType(String? rawType, String originalText) {
    final normalized = _normalizeText(rawType ?? '');
    final text = _normalizeText(originalText);

    if (normalized == 'income' || normalized == 'receita') {
      return 'income';
    }

    if (text.contains('recebi') ||
        text.contains('ganhei') ||
        text.contains('salario') ||
        text.contains('pix recebido')) {
      return 'income';
    }

    return 'expense';
  }

  double? _parseAmount(dynamic rawAmount) {
    if (rawAmount == null) {
      return null;
    }

    if (rawAmount is num) {
      return rawAmount.toDouble();
    }

    if (rawAmount is String) {
      return _extractAmount(rawAmount);
    }

    return null;
  }

  double? _extractAmount(String text) {
    final normalized = text.replaceAll(RegExp(r'(?<=\d)\.(?=\d{3}\b)'), '').replaceAll(',', '.');
    final match = RegExp(r'(\d+(?:\.\d{1,2})?)').firstMatch(normalized);
    if (match == null) {
      return null;
    }

    return double.tryParse(match.group(1)!);
  }

  _InferredCategoryData _inferCategoryData({
    required String type,
    required String? suggestedCategory,
    required String? suggestedSubcategory,
    required String originalText,
  }) {
    if (type == 'income') {
      final normalizedText = _normalizeText(originalText);
      final incomeSubcategory = normalizedText.contains('salario')
          ? 'Salário'
          : _normalizeString(suggestedSubcategory);

      return _InferredCategoryData(
        category: 'Receita',
        subcategory: incomeSubcategory,
        needsManualReview: false,
      );
    }

    final normalizedText = _normalizeText(originalText);
    final normalizedCategory = _normalizeString(suggestedCategory);
    final normalizedSubcategory = _normalizeString(suggestedSubcategory);

    if (normalizedText.contains('gasolina') ||
        normalizedText.contains('combustivel') ||
        normalizedText.contains('etanol') ||
        normalizedText.contains('posto')) {
      return const _InferredCategoryData(
        category: 'Combustível',
        subcategory: 'Gasolina',
        needsManualReview: false,
      );
    }

    if (normalizedText.contains('uber') ||
        normalizedText.contains('99') ||
        normalizedText.contains('taxi')) {
      return const _InferredCategoryData(
        category: 'Transporte',
        subcategory: 'Uber/99',
        needsManualReview: false,
      );
    }

    if (normalizedText.contains('mercado') ||
        normalizedText.contains('supermercado') ||
        normalizedText.contains('feira')) {
      return const _InferredCategoryData(
        category: 'Supermercado',
        subcategory: 'Alimentos',
        needsManualReview: false,
      );
    }

    if (normalizedText.contains('restaurante') ||
        normalizedText.contains('almoco') ||
        normalizedText.contains('jantar') ||
        normalizedText.contains('lanche')) {
      return const _InferredCategoryData(
        category: 'Alimentação',
        subcategory: 'Lanche',
        needsManualReview: false,
      );
    }

    final canonicalCategory = _canonicalExpenseCategory(normalizedCategory);
    final category = canonicalCategory ?? 'Outros';
    final categoryDefinition = DefaultCategories.findByName(category);
    final subcategory = _canonicalSubcategory(
      categoryDefinition: categoryDefinition,
      rawSubcategory: normalizedSubcategory,
    );

    return _InferredCategoryData(
      category: category,
      subcategory: subcategory,
      needsManualReview: canonicalCategory == null,
    );
  }

  String? _canonicalExpenseCategory(String? rawCategory) {
    if (rawCategory == null || rawCategory.isEmpty) {
      return null;
    }

    final normalized = _normalizeText(rawCategory);
    const aliases = <String, String>{
      'supermercado': 'Supermercado',
      'mercado': 'Supermercado',
      'combustivel': 'Combustível',
      'alimentacao': 'Alimentação',
      'bar / lazer': 'Bar / Lazer',
      'bar/lazer': 'Bar / Lazer',
      'lazer': 'Bar / Lazer',
      'contas': 'Contas',
      'contas/utilidades': 'Contas',
      'saude': 'Saúde',
      'transporte': 'Transporte',
      'educacao': 'Educação',
      'outros': 'Outros',
      'outro': 'Outros',
    };

    return aliases[normalized] ?? DefaultCategories.findByName(rawCategory)?.name;
  }

  String? _canonicalSubcategory({
    required String? rawSubcategory,
    required Category? categoryDefinition,
  }) {
    if (rawSubcategory == null || categoryDefinition == null) {
      return null;
    }

    for (final option in categoryDefinition.subcategories) {
      if (_normalizeText(option) == _normalizeText(rawSubcategory)) {
        return option;
      }
    }

    if (_normalizeText(rawSubcategory).contains('uber')) {
      return 'Uber/99';
    }

    if (_normalizeText(rawSubcategory).contains('gasolina')) {
      return 'Gasolina';
    }

    return null;
  }

  bool _parseBool(dynamic rawValue) {
    if (rawValue is bool) {
      return rawValue;
    }
    if (rawValue is String) {
      return rawValue.toLowerCase() == 'true';
    }
    return false;
  }

  String? _normalizeString(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return null;
    }

    return trimmed;
  }

  String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}

class _InferredCategoryData {
  final String category;
  final String? subcategory;
  final bool needsManualReview;

  const _InferredCategoryData({
    required this.category,
    required this.subcategory,
    required this.needsManualReview,
  });
}

const String _systemPrompt = '''
Você é um extrator de lançamentos financeiros pessoais em português do Brasil.
Responda somente com JSON válido, sem markdown, sem comentários e sem texto extra.

Schema obrigatório:
{
  "type": "expense" | "income",
  "amount": number,
  "category": string,
  "subcategory": string | null,
  "description": string | null,
  "needs_manual_review": boolean
}

Regras:
- Classifique como "expense" para gastos e "income" para entradas de dinheiro.
- Para despesas, use apenas estas categorias canônicas:
  "Supermercado", "Combustível", "Alimentação", "Bar / Lazer", "Contas", "Saúde", "Transporte", "Educação", "Outros".
- Para receitas, use categoria "Receita" e subcategoria quando fizer sentido, como "Salário".
- Detecte e normalize linguagem natural do Brasil:
  gasolina/combustível/posto -> "Combustível"
  uber/99/táxi -> "Transporte" com subcategoria "Uber/99"
  mercado/supermercado -> "Supermercado"
  recebi/salário/pagamento -> "income", categoria "Receita"
- Se o valor não estiver claro, retorne amount = 0 e needs_manual_review = true.
- Se a categoria não estiver clara, use "Outros" e needs_manual_review = true.

Exemplos:
Entrada: "gastei 50 reais de gasolina"
Saída: {"type":"expense","amount":50,"category":"Combustível","subcategory":"Gasolina","description":"gasolina","needs_manual_review":false}

Entrada: "mercado 200 reais"
Saída: {"type":"expense","amount":200,"category":"Supermercado","subcategory":"Alimentos","description":"mercado","needs_manual_review":false}

Entrada: "uber 30 reais"
Saída: {"type":"expense","amount":30,"category":"Transporte","subcategory":"Uber/99","description":"uber","needs_manual_review":false}

Entrada: "recebi 1500 de salário"
Saída: {"type":"income","amount":1500,"category":"Receita","subcategory":"Salário","description":"salário","needs_manual_review":false}
''';
