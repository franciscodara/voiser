# 06 — Blocos de Prompts para o Agente IA

---

## 🧱 BLOCO 0 — Setup Inicial do Projeto

```
Sou um desenvolvedor usando Google Antigravity no windows com Android Studio instalado para testes.

Preciso criar um projeto Flutter chamado "finwise" do zero. Por favor:

1. Me dê o comando exato para criar o projeto Flutter com o package name correto:
   flutter create finwise --org com.meudominio --platforms android,ios

2. Crie a estrutura completa de pastas conforme descrito no arquivo docs/03-arquitetura-pastas.md que já está no projeto. A estrutura deve ter:
   - lib/core/ com as subpastas: constants, errors, extensions, network, router, services, theme, widgets
   - lib/features/ com as subpastas: auth, expenses, income, dashboard, categories, settings
   - Dentro de cada feature: data/, domain/, presentation/
   - Criar arquivos .dart vazios (com comentários de contexto) em cada pasta

3. Configure o pubspec.yaml com todas as dependências listadas em docs/03-arquitetura-pastas.md

4. Crie o analysis_options.yaml com very_good_analysis

5. Configure o main.dart com ProviderScope do Riverpod e MaterialApp básico

Me mostre cada arquivo criado e confirme que flutter pub get funciona sem erros.
```

---

## 🎨 BLOCO 1 — Tema e Design System

```
Agora vamos criar o design system do FinWise. O app deve ter um visual moderno, limpo e financeiro — inspirado em apps como Nubank e Mobills, mas com identidade própria.

1. Crie lib/core/theme/app_theme.dart com:
   - ThemeData light e dark usando Material Design 3
   - Paleta de cores primária: verde-esmeralda (#10B981) para positivo, vermelho-coral (#EF4444) para negativo, fundo escuro elegante (#0F172A) no dark mode
   - ThemeMode dinâmico via Riverpod (salvo em SharedPreferences)

2. Crie lib/core/theme/app_text_styles.dart com:
   - Hierarquia tipográfica completa (display, headline, title, body, label)
   - Fonte: Poppins (Google Fonts) para títulos, Inter para corpo de texto

3. Crie lib/core/constants/app_colors.dart com todas as cores do app incluindo cores por categoria (supermercado=azul, combustível=laranja, alimentação=verde, bar=roxo, contas=cinza)

4. Crie lib/core/widgets/finwise_button.dart — botão primário com animação de press

5. Crie lib/core/widgets/amount_input_field.dart — campo especial para entrada de valor monetário em R$, com formatação automática enquanto o usuário digita (ex: digita "35685" → exibe "R$ 356,85")

6. Configure o app.dart para usar os temas criados e testá-los

Me mostre o resultado visual descrevendo como cada componente ficará na tela.
```

---

## 🔐 BLOCO 2 — Autenticação com Google

```
Preciso implementar o login com Google (OAuth 2.0) no FinWise.

Contexto: Estou no Linux com Android Studio. O projeto já tem google_sign_in no pubspec.yaml.

Antes de começar, me explique o que preciso configurar no Google Cloud Console (passo a passo para Linux/Android), incluindo:
- Como gerar o SHA-1 do keystore de debug no Linux
- Como baixar o google-services.json e onde colocar

Depois implemente:

1. lib/features/auth/data/datasources/google_auth_datasource.dart
   - Método signIn() retorna UserModel com nome, email, foto e accessToken
   - Método signOut()
   - Método getStoredUser() — verifica se já logado

2. lib/features/auth/domain/entities/user.dart (freezed)

3. lib/features/auth/domain/use_cases/sign_in_with_google.dart

4. lib/features/auth/presentation/providers/auth_provider.dart
   - AsyncNotifier com estados: loading, authenticated(User), unauthenticated

5. lib/features/auth/presentation/screens/login_screen.dart
   - Layout elegante com logo do FinWise, tagline e botão "Entrar com Google"
   - Animação de entrada (flutter_animate)

6. lib/core/router/app_router.dart
   - Rota /login e /home
   - Redirect automático baseado no estado de auth

Após o login, o app deve navegar automaticamente para a HomeScreen (que por enquanto pode ser só um placeholder com o email do usuário logado).
```

---

## 📊 BLOCO 3 — Google Sheets: Criação da Planilha

```
Agora preciso implementar a criação automática da planilha no Google Sheets logo após o login.

1. Crie lib/features/auth/data/datasources/google_sheets_setup_datasource.dart com:
   - Método createFinWiseSpreadsheet(String accessToken) que:
     a) Cria uma planilha chamada "FinWise — Meu Orçamento {ano atual}"
     b) Cria 4 abas: "Transações", "Entradas", "Categorias", "Dashboard"
     c) Formata os cabeçalhos de cada aba com as colunas certas (ver docs/02-arquitetura-software.md)
     d) Retorna o spreadsheetId
   - Salva o spreadsheetId no SharedPreferences

2. Integre essa chamada no fluxo de login:
   - Após SignInWithGoogle ter sucesso, verificar se já existe um spreadsheetId salvo
   - Se não existe: criar a planilha e salvar o ID
   - Se já existe: pular a criação
   
3. Use o pacote googleapis (Dart) para as chamadas à Sheets API v4

4. Adicione tratamento de erro adequado:
   - Sem conexão: mostrar mensagem e tentar novamente
   - Token expirado: re-autenticar automaticamente

Me mostre o link da planilha criada no console (log) para eu verificar no Google Drive.
```

---

## 💳 BLOCO 4 — Tela de Adição de Despesa (Manual)

```
Vamos implementar a feature principal: registro manual de despesa.

Quero uma tela moderna para uso em modo retrato (vertical). A UX deve ser fluida — o usuário consegue registrar uma despesa em menos de 10 segundos.

1. Crie as entidades de domínio:
   - lib/features/expenses/domain/entities/expense.dart (freezed)
   - lib/features/expenses/domain/entities/category.dart (freezed)
   com os campos definidos em docs/02-arquitetura-software.md

2. Crie as categorias pré-definidas em lib/core/constants/default_categories.dart:
   Supermercado (subcats: açougue, bebidas, alimentos, limpeza, higiene, outros)
   Combustível (subcats: gasolina, etanol, diesel, GNV)
   Alimentação/Café (subcats: almoço, jantar, lanche, delivery)
   Bar/Lazer (subcats: bebidas, petiscos, show/evento, outros)
   Contas (subcats: água, luz, internet, telefone, gás)
   Cartão de Crédito (subcats: por bandeira)
   Saúde (subcats: farmácia, consulta, exame)
   Transporte (subcats: uber/99, estacionamento, pedágio)
   Outros

3. Crie lib/features/expenses/presentation/screens/add_expense_screen.dart
   Layout conforme descrito em docs/04-mvp-plano.md:
   - Campo de valor monetário grande e destacado no topo
   - Grid de categorias com ícones coloridos e animação de seleção
   - Dropdown de sub-categorias (aparece após selecionar categoria)
   - Seletor de data/hora (padrão: agora)
   - Campo de descrição opcional
   - Botão "Salvar" proeminente
   - Link "Usar voz" discreto na parte inferior

4. Crie lib/features/expenses/presentation/widgets/category_selector.dart
   - Grid 4 colunas, ícones grandes, fundo colorido, nome da categoria
   - Animação de bounce ao selecionar (flutter_animate)

5. Crie lib/features/expenses/presentation/providers/expense_provider.dart
   - AsyncNotifier para gerenciar adição de despesas

Por enquanto, ao salvar, apenas faça log do objeto Expense criado. Vamos conectar ao Sheets no próximo bloco.
```

---

## 📡 BLOCO 5 — Sincronização com Google Sheets

```
Agora vamos conectar o formulário de despesas ao Google Sheets.

1. Crie lib/features/expenses/data/datasources/remote/google_sheets_datasource.dart com:
   - appendExpense(Expense expense, String spreadsheetId, String accessToken)
     → adiciona uma linha na aba "Transações"
   - getExpenses(String spreadsheetId, String accessToken, {int? month, int? year})
     → lê todas as linhas da aba "Transações" com filtro opcional
   - deleteExpense(String rowIndex, ...) → deleta uma linha específica

2. Crie lib/features/expenses/data/datasources/local/expense_hive_datasource.dart com:
   - saveExpense(ExpenseModel expense) → salva no Hive com synced: false
   - markAsSynced(String id)
   - getPendingExpenses() → retorna lista de despesas não sincronizadas

3. Crie lib/features/expenses/data/repositories/expense_repository_impl.dart
   implementando a interface IExpenseRepository com lógica offline-first:
   - Sempre salva no Hive primeiro (resposta imediata para UI)
   - Em background, tenta sincronizar com Sheets
   - Se falhar: mantém na fila (SyncQueue)

4. Crie lib/core/services/sync_queue_service.dart
   - Roda em background usando ConnectivityService
   - Quando detecta conexão, processa fila de pendentes

5. Adicione o widget lib/core/widgets/sync_status_badge.dart
   - Ícone verde ✅ (synced), amarelo 🔄 (pending), vermelho ❌ (error)
   - Visível em cada ExpenseCard

Conecte tudo ao AddExpenseScreen para que ao salvar:
1. A despesa apareça na lista imediatamente (otimistic update)
2. Seja sincronizada com o Google Sheets em background
3. Um snackbar apareça: "Despesa salva! ↩️ Desfazer (5s)"
```

---

## 🎤 BLOCO 6 — Entrada por Voz + NLP

```
Agora a feature mais importante do FinWise: entrada por voz com compreensão de linguagem natural em português brasileiro.

1. Crie lib/core/services/speech_to_text_service.dart
   - Abstração do plugin speech_to_text
   - Configurado para pt-BR
   - Método startListening() → Stream<String> de texto parcial
   - Método stopListening()
   - Solicitar permissão de microfone (Android + iOS)

2. Crie lib/features/expenses/data/datasources/remote/openai_datasource.dart
   - Método parseVoiceCommand(String text) → VoiceCommandResult
   - Usa GPT-4o-mini com o prompt definido em docs/02-arquitetura-software.md
   - Retorna: { amount, category, subcategory, description }
   - A API key vem de ApiConstants.openAiApiKey (MVP)
   - Tratar erros: JSON malformado, valor não encontrado, timeout

3. Crie lib/features/expenses/domain/entities/voice_command_result.dart (freezed)

4. Crie lib/features/expenses/domain/use_cases/parse_voice_command.dart

5. Crie lib/features/expenses/presentation/screens/voice_entry_screen.dart
   Layout descrito em docs/04-mvp-plano.md:
   - Animação Lottie do microfone pulsando enquanto ouve
   - Texto sendo transcrito em tempo real (typing effect)
   - Após NLP: card de confirmação com os dados extraídos
   - Timer regressivo de 3 segundos (auto-confirma)
   - Botões "Confirmar" e "Cancelar"
   - Se algum dado faltar (ex: valor não detectado), abrir formulário pré-preenchido

6. Crie lib/features/expenses/presentation/providers/voice_input_provider.dart
   - Estados: idle | requestingPermission | listening | processing | confirming | confirmed | error

Teste com as frases:
- "anotar despesa de 356,85 de supermercado"
- "anotar compras de supermercado no valor de 356,85 com bebidas"
- "gastei 50 reais de gasolina"
- "conta de luz 189 reais"
- "tomei um café, foi 15 conto"
```

---

## 🔊 BLOCO 7 — Integração com Google Assistant e Siri

```
Agora vamos permitir que o usuário acione o FinWise diretamente pelo assistente de voz do celular.

ANDROID — Google Assistant App Actions:

1. Crie android/app/src/main/res/xml/shortcuts.xml configurando um App Action para:
   - Capability: actions.intent.CREATE_TAXI_RESERVATION (adaptado para despesas)
   - Ou usar capability customizada se necessário
   - Parâmetro: o texto completo da frase do usuário

2. Registre o shortcut no AndroidManifest.xml

3. Em lib/, crie o handler para receber o Intent do Google Assistant:
   - Extrair o texto da Intent
   - Navegar direto para VoiceEntryScreen com o texto pré-preenchido
   - Processar o NLP automaticamente

iOS — Siri Shortcuts:

4. No Xcode (abrir ios/ do projeto): Criar um SiriKit Intent Definition File com:
   - Intent name: "AddExpenseIntent"
   - Parâmetro: texto da despesa (String)

5. Configure Info.plist com NSUserActivityTypes e permissão de microfone

6. Em Flutter, use flutter_siri_shortcuts para:
   - Registrar o shortcut "Anotar despesa" no Siri
   - Receber o callback quando o Siri acionar o app

7. Me guie pelo processo de teste:
   - Android: como testar App Actions no Android Studio
   - iOS: como testar Siri Shortcuts no simulador iOS

O fluxo final deve ser:
"Hey Google / Hey Siri, anotar despesa de R$50 no mercado"
→ App abre na VoiceEntryScreen com o texto já transcrito
→ NLP processa e mostra card de confirmação
→ Usuário confirma ou aguarda 3 segundos
→ Despesa salva ✅
```

---

## 📈 BLOCO 8 — Dashboard com Gráficos

```
Vamos implementar a tela de Dashboard com gráficos interativos.

Os dados serão lidos do Google Sheets (aba "Dashboard" que tem fórmulas de totais).

1. Crie lib/features/dashboard/data/datasources/sheets_report_datasource.dart
   - getMonthlySummary(month, year) → lê totais da aba Dashboard do Sheets
   - Retorna: { totalIncome, totalExpenses, balance, expensesByCategory[] }

2. Crie as entidades de domínio:
   - MonthlySummary (freezed)
   - CategoryTotal (freezed) com: category, amount, percentage, color

3. Crie lib/features/dashboard/presentation/screens/dashboard_screen.dart
   Layout com ScrollView vertical:
   
   Seção 1 — Seletor de mês (◀ Outubro 2024 ▶)
   
   Seção 2 — BalanceCard:
   - Entradas: R$ 8.500,00 (verde)
   - Saídas: R$ 5.230,85 (vermelho)  
   - Saldo: R$ 3.269,15 (cor dinâmica: verde se positivo, vermelho se negativo)
   - Animação de counter ao carregar os valores

   Seção 3 — Gráfico Pizza (fl_chart):
   - Despesas por categoria com cores por categoria
   - Legenda abaixo com percentuais
   - Toque na fatia para highlight e exibir valor

   Seção 4 — Gráfico de Barras (fl_chart):
   - Últimos 6 meses: barras de entradas (verde) vs saídas (vermelho)
   - Eixo Y formatado em R$

4. Crie lib/features/dashboard/presentation/providers/dashboard_provider.dart
   - AsyncNotifier com loading state
   - Recarrega ao mudar o mês selecionado

5. Adicione a navegação por Bottom Navigation Bar:
   - Home (lista de despesas recentes)
   - + Adicionar (AddExpenseScreen)
   - Dashboard (gráficos)
   - Configurações

O Bottom Nav deve ter animação de transição entre abas (flutter_animate).
```

---

## 🏠 BLOCO 9 — HomeScreen e Listagem de Despesas

```
Vamos criar a HomeScreen principal com a lista de despesas recentes.

1. Crie lib/features/expenses/presentation/screens/expense_list_screen.dart
   Layout:
   - Header com saldo do mês atual e mês anterior (setas para navegar)
   - Filtros rápidos por categoria (chips horizontais em scroll)
   - Lista de despesas agrupadas por data ("Hoje", "Ontem", "12 out", etc.)
   - Cada item: ícone da categoria, descrição, valor, horário, sync badge
   - Swipe para deletar (com confirmação)
   - FAB (Floating Action Button) com opções: "✍️ Manual" e "🎤 Voz"

2. Crie lib/features/expenses/presentation/widgets/expense_card.dart
   - Design de card com sombra sutil
   - Ícone colorido da categoria à esquerda
   - Nome da categoria + sub-categoria (se houver) + horário
   - Valor em vermelho à direita
   - Sync badge discreto

3. Crie lib/features/expenses/presentation/widgets/expense_group_header.dart
   - Header de data com total do dia

4. Implemente busca por texto (search bar no topo)

5. Implemente pull-to-refresh que sincroniza com Google Sheets

6. Configure o FAB expandido ao toque:
   - Animação de expansão revelando "Manual" e "Voz"
   - Fechar ao tocar fora

A HomeScreen deve ser a tela inicial após o login.
```

---

## ✅ BLOCO 10 — Polimento Final e Testes (MVP)

```
Chegamos na fase de polimento do MVP. Vamos testar e refinar tudo.

1. Testes unitários — crie testes para:
   - ParseVoiceCommandUseCase: teste com 10 variações de frases em pt-BR
   - AddExpenseUseCase: teste o fluxo offline-first
   - CurrencyExtension: teste a formatação R$

2. Testes de widget:
   - AddExpenseScreen: preencher formulário e verificar se salva
   - AmountInputField: verificar formatação automática

3. Verifique e corrija:
   - Todas as permissões no AndroidManifest.xml (microfone, internet, vibração)
   - Todas as permissões no Info.plist (microfone, Siri)
   - Comportamento com teclado aberto (não ocultar campos importantes)
   - Scroll funciona em telas menores (Android 5")
   - Modo escuro: todos os textos legíveis, ícones visíveis

4. Gere o APK de release para instalar no meu celular Android:
   flutter build apk --release
   Me dê os comandos para instalar via adb

5. Teste end-to-end completo:
   □ Login com Google
   □ Planilha criada no Drive
   □ Adicionar despesa manual → aparece na planilha em até 5s
   □ Adicionar despesa por voz → funciona com sotaque BR
   □ Gráficos carregam corretamente
   □ Funciona sem internet (modo offline) e sincroniza quando reconecta

Me reporte qualquer erro e me ajude a corrigir. Ao final, confirme que o MVP está completo e funcional.
```

---

## 🔒 BLOCO 11 — Migração para V1 (Backend Seguro)

```
O MVP está funcionando. Agora vamos evoluir para a V1 com backend seguro, conforme planejado em docs/05-v1-plano.md.

PARTE 1 — Criar o Backend Node.js:

1. Crie um novo projeto em uma pasta separada: finwise-backend/
2. Inicialize com npm init e instale as dependências listadas em docs/05-v1-plano.md
3. Crie a estrutura de pastas do backend
4. Implemente os endpoints:
   - POST /auth/validate — valida Google ID Token
   - POST /nlp/parse-voice — processa NLP com OpenAI (chave no .env)
   - POST /expenses — salva no Sheets (OAuth no .env)
   - GET /expenses — lista do Sheets
   - GET /report/monthly — dados para gráficos
5. Adicione rate limiting e helmet para segurança
6. Crie o .env.example (sem valores reais) e o .gitignore
7. Teste localmente: curl http://localhost:3000/health

PARTE 2 — Deploy no Railway:

8. Me guie para criar conta e projeto no Railway.app
9. Configurar variáveis de ambiente no painel Railway (OPENAI_API_KEY, etc.)
10. Deploy: railway up ou via GitHub

PARTE 3 — Migrar o App Flutter:

11. Em api_constants.dart: substituir OpenAI key pela URL do backend Railway
12. Criar lib/features/expenses/data/datasources/remote/finwise_api_datasource.dart
    que substitui openai_datasource.dart e chama o backend
13. Adicionar interceptor Dio para enviar Google ID Token em todo request
14. Remover a openAiApiKey do código
15. Testar que tudo funciona igual ao MVP, mas sem chaves no app

Confirme: flutter build apk --release gera um APK sem nenhuma chave de API.
```

---

## 🚀 BLOCO 12 — Publicação nas Lojas

```
Chegamos na etapa final: publicar o FinWise no Google Play e App Store.

GOOGLE PLAY (Android):

1. Me guie para gerar o keystore de produção no Linux:
   keytool -genkey -v -keystore finwise-release.jks ...
   (com as configurações exatas que preciso preencher)

2. Configure android/key.properties e android/app/build.gradle para release

3. Gere o App Bundle:
   flutter build appbundle --release

4. Crie uma política de privacidade simples (markdown → HTML) mencionando:
   - Uso do microfone (entrada por voz)
   - Acesso ao Google Drive/Sheets (armazenamento de dados)
   - Dados não são compartilhados com terceiros

5. Me oriente sobre as screenshots necessárias para o Google Play:
   - Quais tamanhos
   - Sugestões de telas para capturar

APP STORE (iOS):

6. Configure o Xcode para release:
   - Bundle ID, Version, Build number
   - Capabilities: Siri, Microphone

7. Gere o IPA:
   flutter build ipa --release

8. Me oriente sobre os certificados necessários (Apple Developer)

CHECKLIST FINAL:
□ Backend rodando em produção (Railway)
□ App sem API keys no código
□ Política de privacidade publicada
□ Screenshots preparadas
□ App Bundle / IPA gerados e testados
□ Submitted para revisão

Parabéns — o FinWise está nas lojas! 🎉
```
