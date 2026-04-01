# 04 — Plano MVP (Opção 1)

## Conceito
O MVP é a versão de uso pessoal do FinWise. A chave da OpenAI API e as credenciais do Google Cloud são embutidas diretamente no código no momento da compilação.

**⚠️ Importante:** Esta abordagem é segura para uso pessoal (app instalado apenas no seu celular), mas não deve ser publicada nas lojas. Para publicação, avançar para a V1.

---

## Funcionalidades do MVP

| # | Funcionalidade | Prioridade |
|---|---------------|-----------|
| 1 | Login com Google (OAuth) | 🔴 Crítico |
| 2 | Criar planilha no Google Sheets automaticamente | 🔴 Crítico |
| 3 | Registro manual de despesa (formulário) | 🔴 Crítico |
| 4 | Categorias + sub-categorias (pré-definidas) | 🔴 Crítico |
| 5 | Sincronização com Google Sheets | 🔴 Crítico |
| 6 | Entrada por voz (speech-to-text + NLP) | 🟡 Alta |
| 7 | Integração Siri / Google Assistant | 🟡 Alta |
| 8 | Listagem de despesas com filtro de mês | 🟡 Alta |
| 9 | Registro de entradas (receitas) | 🟡 Alta |
| 10 | Gráficos (pizza por categoria + barras mensais) | 🟢 Média |
| 11 | Modo escuro / claro | 🟢 Média |
| 12 | Cache offline (Hive) | 🟢 Média |

---

## Etapas de Desenvolvimento — MVP

### Etapa 0 — Setup do Projeto (Dia 1-2)
- [ ] Criar projeto Flutter: `flutter create finwise --org com.seudominio`
- [ ] Configurar `analysis_options.yaml` (very_good_analysis)
- [ ] Adicionar todas as dependências no `pubspec.yaml`
- [ ] Criar estrutura de pastas conforme `03-arquitetura-pastas.md`
- [ ] Configurar `go_router` com rotas base
- [ ] Configurar `Riverpod` (ProviderScope no main.dart)
- [ ] Criar `AppTheme` com Material Design 3 (light + dark)

**Resultado:** App abre com tela em branco estilizada ✅

---

### Etapa 1 — Google Auth + Planilha (Dia 3-5)

#### 1.1 Google Cloud Console
- [ ] Criar projeto no [console.cloud.google.com](https://console.cloud.google.com)
- [ ] Ativar: Google Sheets API v4 e Google Drive API
- [ ] Criar OAuth 2.0 Client ID para Android e iOS
- [ ] Baixar `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)

#### 1.2 Código
- [ ] Implementar `GoogleAuthDataSource` com `google_sign_in`
- [ ] Implementar `AuthRepositoryImpl`
- [ ] Use case `SignInWithGoogle`
- [ ] `AuthNotifier` (Riverpod) — estados: `loading | authenticated | unauthenticated`
- [ ] `LoginScreen` com botão "Entrar com Google"
- [ ] Após login: chamar `GoogleSheetsDataSource.createSpreadsheet()`
  - Criar planilha "FinWise — Meu Orçamento"
  - Criar abas: Transações, Categorias, Entradas, Dashboard
  - Salvar spreadsheet ID no `SharedPreferences`

**Resultado:** Login funcional, planilha criada automaticamente no Drive ✅

---

### Etapa 2 — Feature Expenses: Manual (Dia 6-10)

#### 2.1 Domain Layer
- [ ] Entidades: `Expense`, `Category`, `SubCategory`
- [ ] Use cases: `AddExpense`, `GetExpenses`
- [ ] Interface: `IExpenseRepository`

#### 2.2 Data Layer
- [ ] `ExpenseModel` com freezed + json_serializable
- [ ] `ExpenseHiveDataSource` (cache local)
- [ ] `GoogleSheetsDataSource.appendExpense()` — adiciona linha na aba Transações
- [ ] `ExpenseRepositoryImpl`

#### 2.3 Presentation Layer — `AddExpenseScreen`
Layout para tela vertical (portrait):
```
┌─────────────────────────┐
│  ← Adicionar Despesa    │
├─────────────────────────┤
│  💰 Valor               │
│  ┌─────────────────┐   │
│  │   R$ 356,85     │   │  ← Teclado numérico customizado
│  └─────────────────┘   │
│                         │
│  📁 Categoria           │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐  │
│  │🛒│ │⛽│ │🍽️│ │🍺│  │  ← Grid de ícones
│  └──┘ └──┘ └──┘ └──┘  │
│                         │
│  📂 Sub-categoria       │
│  [Bebidas  ▼]           │
│                         │
│  📅 Data e Hora         │
│  [Hoje, 14:32  ▼]       │
│                         │
│  📝 Descrição (opcional)│
│  [________________________]│
│                         │
│  ┌─────────────────────┐│
│  │   💾 SALVAR         ││  ← Botão principal
│  └─────────────────────┘│
│                         │
│  🎤 Usar voz            │  ← Link para voice entry
└─────────────────────────┘
```

- [ ] Implementar `AddExpenseScreen` conforme layout
- [ ] `CategorySelector` widget — grid com ícones animados
- [ ] `SubcategorySelector` — dropdown dinâmico
- [ ] `AmountInputField` — formatação automática R$
- [ ] `ExpenseNotifier` (Riverpod AsyncNotifier)
- [ ] Snackbar de confirmação com undo (5s)

**Resultado:** Despesa salva local + Sheets pelo formulário manual ✅

---

### Etapa 3 — Feature Expenses: Voz (Dia 11-15)

#### 3.1 Speech-to-Text
- [ ] `SpeechToTextService` — abstração do plugin
- [ ] Solicitar permissão de microfone (Android + iOS)
- [ ] Configurar locale pt-BR
- [ ] Detectar silêncio → parar gravação automaticamente

#### 3.2 NLP com OpenAI
- [ ] `OpenAIDataSource.parseVoiceCommand(String text)` → `VoiceCommandResult`
- [ ] Prompt em português com exemplos de variações (ver `02-arquitetura-software.md`)
- [ ] `ParseVoiceCommandUseCase`
- [ ] Tratar erros: valor não encontrado, categoria ambígua

#### 3.3 Voice Entry Screen
```
┌─────────────────────────┐
│  🎤 Falar Despesa       │
├─────────────────────────┤
│                         │
│     [Animação Lottie    │
│      microfone pulsando]│
│                         │
│  "Estou ouvindo..."     │
│                         │
│  ┌─────────────────────┐│
│  │ "anotar compras de  ││  ← Texto sendo transcrito
│  │  supermercado 356..." ││    em tempo real
│  └─────────────────────┘│
│                         │
│  ─── Ou toque para ───  │
│  ─── digitar  ─────     │
└─────────────────────────┘

[Após processamento NLP:]

┌─────────────────────────┐
│  ✅ Entendido!          │
├─────────────────────────┤
│  🛒 Supermercado        │
│  🍺 Bebidas             │
│  💰 R$ 356,85           │
│  📅 Hoje, 14:32         │
│                         │
│  [Confirmar] [Cancelar] │
│  Confirmando em 3... 2..│
└─────────────────────────┘
```
- [ ] `VoiceEntryScreen` com animação Lottie
- [ ] `VoiceInputNotifier` (estados: idle → listening → processing → confirming)
- [ ] Card de confirmação com timer regressivo (3s auto-confirma)

#### 3.4 Integração com Assistentes de Voz
- [ ] **Android:** Configurar `shortcuts.xml` para App Actions
- [ ] **iOS:** Configurar SiriKit Intent no Xcode

**Resultado:** "Hey Google / Siri, anotar despesa de R$50 no mercado" funcional ✅

---

### Etapa 4 — Dashboard + Gráficos (Dia 16-19)

#### 4.1 Data
- [ ] `SheetsReportDataSource.getMonthlyReport()` — lê aba Dashboard
- [ ] Entidades: `MonthlySummary`, `CategoryTotal`
- [ ] `GetMonthlyReportUseCase`

#### 4.2 Dashboard Screen
```
┌─────────────────────────┐
│  📊 Outubro 2024    [<>]│
├─────────────────────────┤
│  ┌─────────────────────┐│
│  │ Saldo do Mês        ││
│  │ + R$ 8.500,00       ││  ← Entradas
│  │ - R$ 5.230,85       ││  ← Saídas
│  │ = R$ 3.269,15 ✅    ││  ← Saldo
│  └─────────────────────┘│
│                         │
│  Gastos por Categoria   │
│  [Gráfico Pizza fl_chart]│
│  🛒 Supermercado 34%    │
│  ⛽ Combustível  18%    │
│  ...                    │
│                         │
│  Entradas vs Saídas     │
│  [Gráfico Barras 6 meses]│
└─────────────────────────┘
```
- [ ] `DashboardScreen` com scroll
- [ ] `ExpensesPieChart` (fl_chart)
- [ ] `IncomeBarChart` (fl_chart)
- [ ] `BalanceCard` com formatação e cor (verde/vermelho)
- [ ] Navegação por mês (anterior / próximo)
- [ ] `DashboardProvider` com loading state

**Resultado:** Gráficos funcionais lendo dados do Google Sheets ✅

---

### Etapa 5 — Polimento e Testes (Dia 20-23)

- [ ] Implementar `SyncQueueService` (offline-first)
- [ ] Indicadores de sync status em cada despesa
- [ ] Testes unitários dos use cases principais
- [ ] Testes de widget para `AddExpenseScreen`
- [ ] Ajustes de UI: espaçamento, cores, tipografia
- [ ] Testes no emulador Android Studio (Android + iOS Simulator)
- [ ] Testar variações de voz com diferentes sotaques
- [ ] Revisar permissões (microfone, internet) em ambas as plataformas

**Resultado:** MVP funcional, testado, rodando no celular ✅

---

## Checklist de Configuração — MVP

### Google Cloud Console
```
□ Projeto criado
□ Google Sheets API ativada
□ Google Drive API ativada
□ OAuth 2.0 Client ID Android criado (SHA-1 configurado)
□ OAuth 2.0 Client ID iOS criado
□ google-services.json em android/app/
□ GoogleService-Info.plist em ios/Runner/
```

### OpenAI
```
□ Conta criada em platform.openai.com
□ API Key gerada
□ Chave colada em lib/core/constants/api_constants.dart
□ Limite de gasto configurado (ex: $5/mês para uso pessoal)
```

### Compilação e Teste
```
□ flutter pub get
□ flutter pub run build_runner build
□ flutter run (Android Studio emulador)
□ flutter run --release (teste no celular físico)
```

---

## Estimativa de Tempo — MVP

| Etapa | Dias |
|-------|------|
| 0. Setup | 2 |
| 1. Google Auth + Sheets | 3 |
| 2. Expenses Manual | 5 |
| 3. Voz + NLP + Assistentes | 5 |
| 4. Dashboard + Gráficos | 4 |
| 5. Polimento + Testes | 4 |
| **Total** | **~23 dias úteis** |
