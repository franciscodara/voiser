# 02 — Arquitetura de Software

## Padrão Arquitetural: Clean Architecture + Feature-First

O FinWise adota **Clean Architecture** combinada com organização **Feature-First** de pastas. Essa combinação oferece:

- **Separação de responsabilidades** — UI não conhece regras de negócio
- **Testabilidade** — cada camada é testável de forma independente
- **Escalabilidade** — novas features adicionadas sem quebrar existentes
- **Manutenibilidade** — fácil localização de código por domínio

---

## Visão das Camadas

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                     │
│         (Widgets, Screens, Controllers/Notifiers)       │
│                Riverpod StateNotifiers                  │
└────────────────────────┬────────────────────────────────┘
                         │ chama
┌────────────────────────▼────────────────────────────────┐
│                   DOMAIN LAYER                          │
│         (Use Cases, Entities, Repository Interfaces)    │
│              Lógica de negócio pura em Dart             │
└────────────────────────┬────────────────────────────────┘
                         │ implementa
┌────────────────────────▼────────────────────────────────┐
│                    DATA LAYER                           │
│      (Repository Impl, Data Sources, DTOs, Models)     │
│   Google Sheets API │ OpenAI API │ Cache Local (Hive)  │
└─────────────────────────────────────────────────────────┘
```

---

## Camadas em Detalhe

### 1. Presentation Layer

**Responsabilidade:** Renderizar UI, capturar eventos do usuário, exibir estado.

**Componentes:**
- `screens/` — telas completas (HomeScreen, AddExpenseScreen, etc.)
- `widgets/` — componentes reutilizáveis (ExpenseCard, CategoryChip, etc.)
- `providers/` — Riverpod Notifiers que expõem estado para a UI
- `controllers/` — lógica de apresentação (form validation, etc.)

**Regra:** Nunca acessa APIs, banco de dados ou lógica de negócio diretamente.

---

### 2. Domain Layer

**Responsabilidade:** Regras de negócio puras, independentes de framework.

**Componentes:**
- `entities/` — objetos de domínio (Expense, Category, Income, User)
- `use_cases/` — casos de uso (AddExpense, FetchMonthlyReport, ParseVoiceCommand)
- `repositories/` — interfaces abstratas (contratos que a camada Data implementa)
- `failures/` — tipos de erro de domínio (NetworkFailure, AuthFailure, etc.)

**Regra:** Zero dependência de Flutter, pacotes externos ou implementações concretas.

---

### 3. Data Layer

**Responsabilidade:** Implementar repositórios, acessar dados externos e locais.

**Componentes:**
- `repositories/` — implementações concretas dos contratos de Domain
- `datasources/remote/` — Google Sheets API, OpenAI API
- `datasources/local/` — Hive (cache offline)
- `models/` — DTOs com serialização JSON (gerados via `freezed` + `json_serializable`)
- `mappers/` — conversão entre Models (Data) ↔ Entities (Domain)

---

## Fluxo de Dados — Registro de Despesa por Voz

```
Usuário fala
     │
     ▼
[SpeechToTextService]          ← speech_to_text plugin
     │ texto bruto: "anotar compra mercado 356 reais"
     ▼
[ParseVoiceCommandUseCase]
     │ envia para OpenAI GPT-4o-mini
     ▼
[OpenAIDataSource]             ← OpenAI API
     │ retorna JSON:
     │ { category: "supermercado", amount: 356.00, subcategory: null }
     ▼
[AddExpenseUseCase]
     │
     ├──► [HiveLocalDataSource]    ← salva cache local imediatamente
     │
     └──► [GoogleSheetsDataSource] ← sincroniza com planilha
               │
               ▼
         Google Sheets API v4
```

---

## Fluxo de Dados — Entrada Manual de Despesa

```
Usuário preenche formulário
     │
     ▼
[AddExpenseScreen]
     │ chama
     ▼
[ExpenseNotifier] (Riverpod)
     │ chama
     ▼
[AddExpenseUseCase]
     │
     ├──► [HiveLocalDataSource]    ← otimistic update (UI instantânea)
     │
     └──► [GoogleSheetsDataSource] ← sync background
```

---

## Fluxo de Autenticação

```
App abre
     │
     ▼
[AuthNotifier] verifica token armazenado
     │
     ├── Token válido ──► HomeScreen
     │
     └── Sem token ──► LoginScreen
                           │
                           ▼
                   [google_sign_in]
                           │ OAuth 2.0
                           ▼
                   Google Authorization
                           │ access_token + refresh_token
                           ▼
                   [FlutterSecureStorage]
                           │ salva tokens
                           ▼
                   [GoogleSheetsDataSource]
                           │ cria planilha "FinWise - Meu Orçamento"
                           ▼
                   HomeScreen
```

---

## Gerenciamento de Estado: Riverpod 2.x

### Por que Riverpod?
- **Type-safe** — erros de provider detectados em compile time
- **Testável** — providers são facilmente mockados
- **Sem BuildContext** nos providers — lógica separada da UI
- **AsyncNotifier** — ideal para operações com APIs assíncronas

### Estrutura de Providers

```dart
// Hierarquia de dependências (simplificada)

googleSheetsDataSourceProvider
         ↓
expenseRepositoryProvider
         ↓
addExpenseUseCaseProvider
         ↓
expenseNotifierProvider  ←── HomeScreen assiste
         ↓
expenseListProvider      ←── ExpenseList widget assiste
```

---

## Estratégia de Sincronização Offline-First

O app opera em modo **offline-first**:

1. Toda despesa é salva no **Hive** (local) imediatamente
2. Uma fila de sincronização (`SyncQueue`) tenta enviar ao Sheets em background
3. Se sem conexão, a despesa fica marcada como `pendingSync: true`
4. Quando a conexão volta, o `ConnectivityService` dispara a sincronização
5. A UI mostra indicador visual para itens pendentes de sync

```
Estado de uma Expense:
  - synced: true      ✅ verde — sincronizado com Sheets
  - synced: false     🔄 amarelo — pendente de sync
  - error: true       ❌ vermelho — falha na sync (com retry manual)
```

---

## Integração com Google Sheets

### Estrutura da Planilha Criada Automaticamente

**Aba 1: Transações**
| Data | Hora | Categoria | Sub-categoria | Descrição | Valor | Tipo | Origem |
|------|------|-----------|---------------|-----------|-------|------|--------|
| 2024-01-15 | 14:32 | Supermercado | Bebidas | - | 356,85 | Saída | Voz |

**Aba 2: Categorias**
| ID | Nome | Tipo | Cor | Ícone | Sub-categorias |
|----|------|------|-----|-------|----------------|

**Aba 3: Entradas**
| Data | Fonte | Descrição | Valor |
|------|-------|-----------|-------|

**Aba 4: Dashboard (fórmulas)**
- Totais por mês e categoria (SUMIF, FILTER)
- Saldo atual
- Dados que o app lê para gráficos

---

## Integração NLP — Processamento de Voz

### Prompt enviado ao GPT-4o-mini

```
Sistema: "Você é um parser de despesas domésticas. 
Extraia informações de frases em português brasileiro.
Retorne APENAS JSON válido no formato:
{
  'amount': number,
  'category': string,
  'subcategory': string | null,
  'description': string | null
}

Categorias válidas: supermercado, combustível, alimentação, 
bar/lazer, contas/utilidades, cartão de crédito, saúde, 
transporte, educação, outros.

Para supermercado, subcategorias: açougue, bebidas, 
alimentos, limpeza, higiene, outros."

Usuário: "anotar compras de supermercado no valor de 
356,85 com bebidas"
```

### Resposta esperada:
```json
{
  "amount": 356.85,
  "category": "supermercado",
  "subcategory": "bebidas",
  "description": null
}
```

---

## Arquitetura da Integração com Assistentes de Voz

### iOS — Siri Shortcuts
1. Usuário cria um Shortcut nas configurações do iOS
2. Frase de ativação: "Anotar despesa" (customizável)
3. O Shortcut chama o app via `INIntent` customizado
4. O app recebe o texto, processa via NLP e registra

### Android — Google Assistant App Actions
1. Configuração via `shortcuts.xml` (App Actions)
2. Frase de ativação: "Anotar despesa no FinWise"
3. O Assistant extrai parâmetros e abre o app com `Intent`
4. O app processa e registra

### Fluxo unificado (ambos os SOs):
```
Assistente de voz
       ↓
Intent com texto transcrito
       ↓
VoiceEntryHandler (Dart)
       ↓
ParseVoiceCommandUseCase
       ↓
Confirmação na tela (3 segundos para cancelar)
       ↓
AddExpenseUseCase
```
