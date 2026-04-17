# 07 - Checklist de Status dos Blocos

> Atualizado em 2026-04-15 com base na leitura dos arquivos em `docs/`, `lib/`, `android/`, `ios/` e `test/`.
>
> Critério usado:
> - `[x] Implementado`: existe código consistente cobrindo o objetivo principal do bloco.
> - `[x] Implementado`: existe implementação relevante, mas ainda faltam peças importantes para considerar o bloco fechado.
> - `[ ] Não implementado`: não há implementação suficiente no repositório.
>
> Observação: esta análise foi feita por inspeção estática dos arquivos. A validação por `flutter analyze` e `flutter test` não foi concluída nesta rodada.

## Resumo Geral

| Bloco | Tema | Status |
|---|---|---|
| 0 | Setup inicial do projeto | `[x]` |
| 1 | Tema e design system | `[x]` |
| 2 | Autenticação com Google | `[x]` |
| 3 | Criação automática da planilha no Google Sheets | `[~]` |
| 4 | Tela de adição de despesa manual | `[x]` |
| 5 | Sincronização com Google Sheets | `[~]` |
| 6 | Entrada por voz + NLP | `[x]` |
| 7 | Google Assistant e Siri | `[~]` |
| 8 | Dashboard com gráficos | `[~]` |
| 9 | HomeScreen e listagem de despesas | `[~]` |
| 10 | Polimento final e testes | `[ ]` |
| 11 | Migração para V1 com backend seguro | `[ ]` |
| 12 | Publicação nas lojas | `[ ]` |

## Leitura Rápida

- A sua suspeita estava quase certa: os blocos `0` a `8` existem no código, mas nem todos estão fechados.
- Os blocos mais sólidos hoje são `0`, `1`, `2`, `4` e `6`.
- Os blocos `3`, `5`, `7` e `8` têm implementação real, mas ainda com lacunas importantes.
- O bloco `9` começou a ser feito, porém ainda não corresponde ao escopo completo descrito no plano.
- Os blocos `10`, `11` e `12` ainda não foram implementados.

---

## Bloco 0 - Setup Inicial do Projeto

- Status: `[x] Implementado`
- Evidências:
  - Estrutura base do app criada.
  - `Riverpod` inicializado.
  - `go_router` configurado.
  - tema global ligado no app.
  - dependências principais adicionadas ao `pubspec.yaml`.
- Pendências relevantes:
  - Nenhuma estrutural crítica para considerar o bloco concluído.

### Árvore de arquivos

```text
analysis_options.yaml
pubspec.yaml
lib/
  app.dart
  main.dart
  core/
    constants/
      api_constants.dart
      app_colors.dart
      constants_example.dart
      default_categories.dart
    errors/
      errors_example.dart
    extensions/
      extensions_example.dart
    network/
      google_auth_client.dart
      network_example.dart
    router/
      app_router.dart
      app_router.g.dart
      router_example.dart
    services/
      assistant_listener_service.dart
      services_example.dart
      speech_to_text_service.dart
      speech_to_text_service.g.dart
      sync_queue_service.dart
      sync_queue_service.g.dart
    theme/
      app_text_styles.dart
      app_theme.dart
      theme_example.dart
    widgets/
      amount_input_field.dart
      finwise_button.dart
      sync_status_badge.dart
      widgets_example.dart
  features/
    auth/
    categories/
    dashboard/
    expenses/
    home/
    income/
    settings/
```

---

## Bloco 1 - Tema e Design System

- Status: `[x] Implementado`
- Evidências:
  - temas `light` e `dark` em `lib/core/theme/app_theme.dart`.
  - persistência de `ThemeMode` via `SharedPreferences`.
  - tipografia em `lib/core/theme/app_text_styles.dart`.
  - paleta em `lib/core/constants/app_colors.dart`.
  - componentes de UI reutilizáveis como `FinwiseButton` e `AmountInputField`.
- Pendências relevantes:
  - Não encontrei uma camada de design tokens mais ampla além do necessário para o MVP.

### Árvore de arquivos

```text
lib/app.dart
lib/core/constants/
  app_colors.dart
lib/core/theme/
  app_text_styles.dart
  app_theme.dart
lib/core/widgets/
  amount_input_field.dart
  finwise_button.dart
```

---

## Bloco 2 - Autenticação com Google

- Status: `[x] Implementado`
- Evidências:
  - datasource de login Google.
  - repositório de auth.
  - entidade `User`.
  - use case `SignInWithGoogle`.
  - provider de autenticação com estados assíncronos.
  - `LoginScreen`.
  - rotas `/login` e `/home` com redirect.
- Pendências relevantes:
  - A documentação operacional de Google Cloud pedida no prompt não está materializada no repositório.
  - A robustez final depende da configuração real de credenciais nativas fora do código.

### Árvore de arquivos

```text
lib/features/auth/data/
  datasources/
    google_auth_datasource.dart
    google_auth_datasource.g.dart
  models/
    user_model.dart
    user_model.freezed.dart
    user_model.g.dart
  repositories/
    auth_repository_impl.dart
    auth_repository_impl.g.dart
lib/features/auth/domain/
  entities/
    user.dart
    user.freezed.dart
  repositories/
    i_auth_repository.dart
  use_cases/
    sign_in_with_google.dart
    sign_in_with_google.g.dart
lib/features/auth/presentation/
  providers/
    auth_provider.dart
    auth_provider.g.dart
  screens/
    login_screen.dart
lib/core/router/
  app_router.dart
  app_router.g.dart
lib/features/home/presentation/screens/
  home_screen.dart
```

---

## Bloco 3 - Criação da Planilha no Google Sheets

- Status: `[x] Implementado`
- Evidências:
  - datasource para criar a planilha e abas.
  - integração com o fluxo de login.
  - armazenamento local do `spreadsheetId`.
  - cabeçalhos iniciais sendo criados.
- O que já está pronto:
  - criação da planilha.
  - criação das abas `Transações`, `Entradas`, `Categorias`, `Dashboard`.
  - log do link da planilha no fluxo de login.
- O que falta para fechar o bloco:
  - o prompt pedia `SharedPreferences`, mas a implementação usa `FlutterSecureStorage`.
  - não encontrei política explícita de retry com feedback de UI para falta de conexão.
  - não encontrei reautenticação automática específica para token expirado dentro desse fluxo.

### Árvore de arquivos

```text
lib/features/auth/data/datasources/
  google_sheets_setup_datasource.dart
  google_sheets_setup_datasource.g.dart
lib/features/auth/presentation/providers/
  auth_provider.dart
  auth_provider.g.dart
lib/core/network/
  google_auth_client.dart
```

---

## Bloco 4 - Tela de Adição de Despesa Manual

- Status: `[x] Implementado`
- Evidências:
  - entidades `Expense` e `Category`.
  - categorias padrão definidas.
  - `AddExpenseScreen` robusta.
  - `CategorySelector`.
  - provider para adicionar despesa.
  - snackbar com desfazer.
- Pendências relevantes:
  - Há diferenças de detalhe entre o prompt e a implementação, mas o objetivo principal do bloco está atendido.

### Árvore de arquivos

```text
lib/core/constants/
  default_categories.dart
lib/core/widgets/
  amount_input_field.dart
  finwise_button.dart
lib/features/expenses/domain/entities/
  category.dart
  category.freezed.dart
  expense.dart
  expense.freezed.dart
  expense.g.dart
lib/features/expenses/presentation/providers/
  expense_provider.dart
  expense_provider.g.dart
lib/features/expenses/presentation/screens/
  add_expense_screen.dart
lib/features/expenses/presentation/widgets/
  category_selector.dart
```

---

## Bloco 5 - Sincronização com Google Sheets

- Status: `[x] Implementado`
- Evidências:
  - datasource remoto do Sheets.
  - datasource local com Hive.
  - fila de sincronização.
  - repositório offline-first.
  - badge de status criada.
- O que já está pronto:
  - salvar primeiro localmente.
  - sincronizar em background.
  - marcar pendências.
  - deletar remotamente por ID.
- O que falta para fechar o bloco:
  - o plano falava em interface `IExpenseRepository`, mas a implementação atual usa uma classe concreta.
  - o badge de sincronização existe, mas a listagem completa com `ExpenseCard` ainda não está pronta.
  - parte da experiência descrita depende do bloco `9`, que ainda está incompleto.

### Árvore de arquivos

```text
lib/features/expenses/data/datasources/local/
  expense_hive_datasource.dart
  expense_hive_datasource.g.dart
lib/features/expenses/data/datasources/remote/
  google_sheets_datasource.dart
  google_sheets_datasource.g.dart
lib/features/expenses/data/repositories/
  expense_repository_impl.dart
  expense_repository_impl.g.dart
lib/features/expenses/presentation/providers/
  expense_provider.dart
  expense_provider.g.dart
lib/core/services/
  sync_queue_service.dart
  sync_queue_service.g.dart
lib/core/widgets/
  sync_status_badge.dart
```

---

## Bloco 6 - Entrada por Voz + NLP

- Status: `[x] Implementado`
- Evidências:
  - serviço de `speech-to-text`.
  - datasource OpenAI com parsing de voz.
  - entidade `VoiceCommandResult`.
  - use case de parsing.
  - provider de fluxo de voz.
  - tela `VoiceEntryScreen`.
- Pendências relevantes:
  - a chave OpenAI continua hardcoded para MVP em `api_constants.dart`, o que está coerente com o bloco MVP, mas não com a V1.
  - o uso de animação Lottie descrito no prompt foi substituído por UI custom; funcionalmente o fluxo existe.

### Árvore de arquivos

```text
lib/core/constants/
  api_constants.dart
lib/core/services/
  speech_to_text_service.dart
  speech_to_text_service.g.dart
lib/features/expenses/data/datasources/remote/
  openai_datasource.dart
  openai_datasource.g.dart
lib/features/expenses/domain/entities/
  voice_command_result.dart
  voice_command_result.freezed.dart
  voice_command_result.g.dart
lib/features/expenses/domain/use_cases/
  parse_voice_command.dart
  parse_voice_command.g.dart
lib/features/expenses/presentation/providers/
  voice_input_provider.dart
  voice_input_provider.g.dart
lib/features/expenses/presentation/screens/
  voice_entry_screen.dart
```

---

## Bloco 7 - Integração com Google Assistant e Siri

- Status: `[x] Implementado`
- Evidências:
  - `shortcuts.xml` existe no Android.
  - `AndroidManifest.xml` registra shortcut e deep link.
  - há um serviço para escutar assistentes.
  - `Info.plist` recebeu chaves relacionadas a Siri/microfone.
- O que já está pronto:
  - caminho Android por deep link está montado.
  - rota para abrir `VoiceEntryScreen` com query existe.
- O que falta para fechar o bloco:
  - a integração Siri em `assistant_listener_service.dart` está comentada.
  - não encontrei `Intent Definition File` nativo do iOS.
  - não vi implementação completa de callback com `flutter_siri_shortcuts`.
  - o fluxo de teste guiado para Android/iOS não foi documentado nem automatizado.

### Árvore de arquivos

```text
android/app/src/main/
  AndroidManifest.xml
  res/xml/
    shortcuts.xml
ios/Runner/
  Info.plist
  AppDelegate.swift
  SceneDelegate.swift
lib/core/services/
  assistant_listener_service.dart
lib/core/router/
  app_router.dart
  app_router.g.dart
lib/features/expenses/presentation/screens/
  voice_entry_screen.dart
```

---

## Bloco 8 - Dashboard com Gráficos

- Status: `[x] Implementado`
- Evidências:
  - datasource para leitura e agregação.
  - entidades de resumo mensal.
  - provider de dashboard.
  - tela de dashboard grande e funcional com gráficos.
- O que já está pronto:
  - resumo mensal.
  - gráficos de pizza e barras.
  - seletor de mês.
  - navegação para o dashboard.
- O que falta para fechar o bloco:
  - o plano dizia que os dados seriam lidos da aba `Dashboard`, mas a implementação lê `Transações` e calcula localmente.
  - não há `BottomNavigationBar` conforme especificado no bloco.
  - a modelagem de `CategoryTotal` não corresponde exatamente ao prompt original com `percentage` e `color`.

### Árvore de arquivos

```text
lib/features/dashboard/data/
  sheets_report_datasource.dart
  sheets_report_datasource.g.dart
lib/features/dashboard/domain/
  monthly_summary.dart
  monthly_summary.freezed.dart
lib/features/dashboard/presentation/
  dashboard_provider.dart
  dashboard_provider.g.dart
  dashboard_screen.dart
lib/core/router/
  app_router.dart
  app_router.g.dart
lib/features/home/presentation/screens/
  home_screen.dart
```

---

## Bloco 9 - HomeScreen e Listagem de Despesas

- Status: `[x] Implementado`
- Evidências:
  - existe `HomeScreen`.
  - existe resumo simples e atalhos rápidos.
  - existe integração com a lista local de despesas via provider.
- O que já está pronto:
  - tela inicial após login.
  - atalhos para manual, voz e dashboard.
  - resumo simples de quantidade de despesas.
- O que falta para fechar o bloco:
  - não existe `expense_list_screen.dart`.
  - não existem `expense_card.dart` e `expense_group_header.dart`.
  - não há agrupamento por data.
  - não há filtros, busca, swipe delete visual, pull-to-refresh nem FAB expandido.

### Árvore de arquivos

```text
lib/features/home/presentation/screens/
  home_screen.dart
lib/features/expenses/presentation/providers/
  expense_provider.dart
  expense_provider.g.dart
lib/features/expenses/data/repositories/
  expense_repository_impl.dart
  expense_repository_impl.g.dart
```

---

## Bloco 10 - Polimento Final e Testes

- Status: `[ ] Não implementado`
- Evidências:
  - o diretório `test/` contém apenas o teste padrão de contador do template Flutter.
  - esse teste ainda referencia `MyApp`, que nem corresponde ao app atual.
- O que falta:
  - testes unitários.
  - testes de widget reais.
  - revisão final de permissões e cenários.
  - validação end-to-end.

### Árvore de arquivos

```text
test/
  widget_test.dart
android/app/src/main/
  AndroidManifest.xml
ios/Runner/
  Info.plist
```

---

## Bloco 11 - Migração para V1 com Backend Seguro

- Status: `[ ] Não implementado`
- Evidências:
  - não existe projeto `finwise-backend/`.
  - o app ainda usa `ApiConstants.openAiApiKey` local.
  - não existe datasource HTTP para backend V1.
- O que falta:
  - backend Node.js.
  - endpoints seguros.
  - migração do app para API intermediária.
  - remoção das chaves do app.

### Árvore de arquivos esperados e ausentes

```text
finwise-backend/
  src/
    middleware/
    routes/
    services/
    app.js
    server.js
  package.json
  .env.example
```

---

## Bloco 12 - Publicação nas Lojas

- Status: `[ ] Não implementado`
- Evidências:
  - não encontrei configuração de release pronta para publicação.
  - não há política de privacidade no repositório.
  - não há evidências de bundle/app bundle/ipa gerados como entrega final de publicação.
- O que falta:
  - assinatura release.
  - bundle de produção.
  - política de privacidade.
  - checklist de submissão.

### Árvore de arquivos esperados e ausentes

```text
android/
  key.properties
  app/
    build.gradle.kts
ios/
  configurações de signing/release
docs/
  política de privacidade
```

---

## Conclusão

- Implementados: `0`, `1`, `2`, `4`, `6`
- Parciais: `3`, `5`, `7`, `8`, `9`
- Não implementados: `10`, `11`, `12`

### Resposta objetiva à dúvida inicial

- Não dá para afirmar que os blocos `0` a `8` estão todos concluídos.
- Dá para afirmar que os blocos `0` a `8` foram iniciados e que todos eles possuem código no repositório.
- Considerando fechamento real por escopo, hoje o projeto parece estar mais próximo de:
  - MVP base bem avançado
  - integrações de borda e acabamento ainda incompletos
