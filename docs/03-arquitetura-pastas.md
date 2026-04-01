# 03 — Arquitetura de Pastas

## Estrutura Completa do Projeto

```
finwise/
├── android/                          # Configurações Android nativas
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml   # Permissões: microfone, internet
│   │   │   └── res/xml/
│   │   │       └── shortcuts.xml     # App Actions (Google Assistant)
│   │   └── build.gradle
│   └── build.gradle
│
├── ios/                              # Configurações iOS nativas
│   ├── Runner/
│   │   ├── Info.plist                # NSMicrophoneUsageDescription, Siri
│   │   └── Intents/                  # SiriKit Intent definitions
│   └── Podfile
│
├── docs/                             # ← VOCÊ ESTÁ AQUI
│   ├── README.md
│   ├── 01-decisao-tecnologica.md
│   ├── 02-arquitetura-software.md
│   ├── 03-arquitetura-pastas.md
│   ├── 04-mvp-plano.md
│   ├── 05-v1-plano.md
│   └── 06-prompts-agente-ia.md
│
├── lib/                              # Código Dart principal
│   ├── main.dart                     # Entry point, inicialização Riverpod
│   ├── app.dart                      # MaterialApp, ThemeData, GoRouter
│   │
│   ├── core/                         # Código compartilhado entre features
│   │   ├── constants/
│   │   │   ├── app_colors.dart       # Paleta de cores do app
│   │   │   ├── app_strings.dart      # Strings localizadas pt-BR
│   │   │   └── api_constants.dart    # Endpoints, sheet IDs (MVP: API keys aqui)
│   │   │
│   │   ├── errors/
│   │   │   ├── failures.dart         # Tipos de falha (NetworkFailure, etc.)
│   │   │   └── exceptions.dart       # Exceções customizadas
│   │   │
│   │   ├── extensions/
│   │   │   ├── currency_extension.dart    # double.toCurrency() → "R$ 356,85"
│   │   │   ├── datetime_extension.dart    # DateTime.toLabel() → "Hoje, 14:32"
│   │   │   └── string_extension.dart      # Utilitários de string
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart            # Configuração base do Dio (headers, interceptors)
│   │   │   └── connectivity_service.dart  # Detecta conexão para sync offline
│   │   │
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter — todas as rotas do app
│   │   │
│   │   ├── services/
│   │   │   ├── speech_to_text_service.dart  # Abstração do plugin speech_to_text
│   │   │   ├── sync_queue_service.dart      # Fila de sync offline-first
│   │   │   └── notification_service.dart    # Notificações locais (lembrete de registro)
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # ThemeData light + dark
│   │   │   └── app_text_styles.dart  # Estilos tipográficos padronizados
│   │   │
│   │   └── widgets/                  # Widgets reutilizáveis globais
│   │       ├── finwise_button.dart
│   │       ├── finwise_text_field.dart
│   │       ├── amount_input_field.dart    # Campo especial para valor monetário
│   │       ├── category_chip.dart
│   │       ├── sync_status_badge.dart    # Indicador ✅ 🔄 ❌
│   │       └── loading_overlay.dart
│   │
│   ├── features/                     # Organização por domínio de negócio
│   │   │
│   │   ├── auth/                     # Autenticação com Google
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── google_auth_datasource.dart   # google_sign_in
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart               # DTO do usuário Google
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.dart                     # Entidade de domínio
│   │   │   │   ├── repositories/
│   │   │   │   │   └── i_auth_repository.dart        # Interface
│   │   │   │   └── use_cases/
│   │   │   │       ├── sign_in_with_google.dart
│   │   │   │       ├── sign_out.dart
│   │   │   │       └── get_current_user.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart            # Riverpod AuthNotifier
│   │   │       ├── screens/
│   │   │       │   └── login_screen.dart             # Tela de login
│   │   │       └── widgets/
│   │   │           └── google_sign_in_button.dart
│   │   │
│   │   ├── expenses/                 # Feature principal — despesas
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── remote/
│   │   │   │   │   │   ├── google_sheets_datasource.dart   # CRUD na planilha
│   │   │   │   │   │   └── openai_datasource.dart          # NLP das frases de voz
│   │   │   │   │   └── local/
│   │   │   │   │       └── expense_hive_datasource.dart    # Cache offline
│   │   │   │   ├── models/
│   │   │   │   │   ├── expense_model.dart            # freezed + json_serializable
│   │   │   │   │   └── category_model.dart
│   │   │   │   ├── mappers/
│   │   │   │   │   └── expense_mapper.dart           # Model ↔ Entity
│   │   │   │   └── repositories/
│   │   │   │       └── expense_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── expense.dart                  # Entidade Expense (freezed)
│   │   │   │   │   ├── category.dart                 # Categoria + sub-categorias
│   │   │   │   │   └── voice_command_result.dart     # Resultado do NLP
│   │   │   │   ├── repositories/
│   │   │   │   │   └── i_expense_repository.dart
│   │   │   │   └── use_cases/
│   │   │   │       ├── add_expense.dart
│   │   │   │       ├── get_expenses.dart             # com filtros por mês/categoria
│   │   │   │       ├── delete_expense.dart
│   │   │   │       ├── parse_voice_command.dart      # Chama OpenAI para NLP
│   │   │   │       └── sync_pending_expenses.dart    # Sincroniza fila offline
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   ├── expense_provider.dart         # Lista de despesas
│   │   │       │   ├── voice_input_provider.dart     # Estado do mic (ouvindo/parado)
│   │   │       │   └── category_provider.dart        # Categorias disponíveis
│   │   │       ├── screens/
│   │   │       │   ├── add_expense_screen.dart       # Formulário manual (tela vertical)
│   │   │       │   ├── voice_entry_screen.dart       # Interface de voz (animação mic)
│   │   │       │   └── expense_list_screen.dart      # Histórico com filtros
│   │   │       └── widgets/
│   │   │           ├── expense_card.dart
│   │   │           ├── category_selector.dart        # Grid de categorias com ícones
│   │   │           ├── subcategory_selector.dart
│   │   │           ├── voice_animation_widget.dart   # Animação Lottie do microfone
│   │   │           └── expense_confirmation_card.dart # Preview antes de confirmar
│   │   │
│   │   ├── income/                   # Feature — entradas/receitas
│   │   │   ├── data/  [mesma estrutura de expenses/]
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── income.dart                   # Salário, aluguel, etc.
│   │   │   │   └── use_cases/
│   │   │   │       ├── add_income.dart
│   │   │   │       └── get_incomes.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── add_income_screen.dart
│   │   │       └── widgets/
│   │   │           └── income_card.dart
│   │   │
│   │   ├── dashboard/                # Feature — gráficos e resumos
│   │   │   ├── data/
│   │   │   │   └── datasources/
│   │   │   │       └── sheets_report_datasource.dart  # Lê aba Dashboard do Sheets
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── monthly_summary.dart
│   │   │   │   │   └── category_total.dart
│   │   │   │   └── use_cases/
│   │   │   │       └── get_monthly_report.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── dashboard_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── dashboard_screen.dart
│   │   │       └── widgets/
│   │   │           ├── expenses_pie_chart.dart       # fl_chart pizza por categoria
│   │   │           ├── income_bar_chart.dart         # fl_chart barras mensais
│   │   │           ├── balance_card.dart             # Saldo do mês
│   │   │           └── monthly_comparison_chart.dart
│   │   │
│   │   ├── categories/               # Feature — gestão de categorias
│   │   │   ├── data/ [...]
│   │   │   ├── domain/
│   │   │   │   └── use_cases/
│   │   │   │       ├── get_categories.dart
│   │   │   │       ├── create_category.dart
│   │   │   │       └── add_subcategory.dart
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── manage_categories_screen.dart
│   │   │
│   │   └── settings/                 # Feature — configurações
│   │       └── presentation/
│   │           └── screens/
│   │               └── settings_screen.dart         # Tema, conta, planilha
│   │
│   └── l10n/                         # Internacionalização (pt-BR)
│       └── app_pt.arb
│
├── test/                             # Testes
│   ├── unit/
│   │   ├── use_cases/
│   │   └── repositories/
│   ├── widget/
│   └── integration/
│
├── assets/
│   ├── animations/                   # Arquivos Lottie (.json)
│   │   ├── mic_listening.json
│   │   ├── success_check.json
│   │   └── loading.json
│   ├── icons/                        # Ícones de categoria (SVG)
│   └── images/
│
├── pubspec.yaml                      # Dependências do projeto
├── analysis_options.yaml             # Regras de lint (very_good_analysis)
└── .env.example                      # Template de variáveis (sem valores reais)
```

---

## Arquivos de Contexto por Feature

Cada feature possui um arquivo `CONTEXT.md` interno (para uso com agentes IA):

### `lib/features/expenses/CONTEXT.md`
```markdown
# Contexto: Feature Expenses

## Responsabilidade
Gerenciar todo o ciclo de vida de despesas: criação (voz + manual),
listagem, edição, exclusão e sincronização com Google Sheets.

## Use Cases
- AddExpense: valida, salva local (Hive), enfileira sync com Sheets
- GetExpenses: lê do Hive (cache) + Sheets se conectado
- ParseVoiceCommand: envia texto para OpenAI → retorna JSON estruturado
- SyncPendingExpenses: processa fila de itens sem sync

## Dependências externas
- Google Sheets API v4 (autenticado via OAuth token do AuthFeature)
- OpenAI GPT-4o-mini (chave em api_constants.dart no MVP)
- speech_to_text plugin

## Estados de UI
- idle: formulário vazio
- listening: microfone ativo, animação Lottie
- processing: spinner (NLP em andamento)
- confirming: card de confirmação (3s para cancelar)
- saving: otimistic update aplicado
- error: snackbar com mensagem amigável
```

---

## Arquivo `core/constants/api_constants.dart` (MVP)

```dart
// ⚠️ MVP APENAS — Remover antes de publicar nas lojas
// Na V1, esses valores vêm do backend seguro

class ApiConstants {
  // Google Sheets
  static const String sheetsApiBaseUrl =
      'https://sheets.googleapis.com/v4/spreadsheets';

  // OpenAI
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiModel = 'gpt-4o-mini';

  // ⚠️ Substituir pelos valores reais antes de compilar (MVP)
  static const String openAiApiKey = 'sk-COLE_SUA_CHAVE_AQUI';
}
```

---

## Arquivo `pubspec.yaml` (referência)

```yaml
name: finwise
description: Gestão de orçamento doméstico com voz e Google Sheets
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter

  # Auth & Google APIs
  google_sign_in: ^6.2.1
  googleapis: ^13.2.0
  gsheets: ^0.4.0

  # Estado
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navegação
  go_router: ^14.2.7

  # HTTP
  dio: ^5.4.3+1

  # Armazenamento local
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.3.1

  # Voz
  speech_to_text: ^6.6.2
  flutter_siri_shortcuts: ^0.1.2
  android_intent_plus: ^4.0.3

  # UI & Gráficos
  fl_chart: ^0.68.0
  flutter_animate: ^4.5.0
  lottie: ^3.1.2
  cached_network_image: ^3.3.1

  # Utilitários
  intl: ^0.19.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  dartz: ^0.10.1       # Either type para error handling

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  mocktail: ^1.0.3
  very_good_analysis: ^6.0.0
```
