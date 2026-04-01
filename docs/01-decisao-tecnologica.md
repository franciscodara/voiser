# 01 — Decisão Tecnológica: Flutter vs React Native

## Contexto da Análise

O app FinWise possui requisitos que influenciam diretamente a escolha do framework:

1. **Integração com assistentes de voz** (Siri e Google Assistant)
2. **Processamento de linguagem natural** com variações e sotaques brasileiros
3. **Gráficos interativos** (pizza, barras, linha do tempo)
4. **Google Sheets API** como backend de dados
5. **OAuth 2.0** com Google
6. **UI moderna** para telas verticais (scroll, cards, formulários)
7. **Publicação** nas duas lojas (Google Play + App Store)

---

## Análise Comparativa Detalhada

### 1. Performance e Renderização

**React Native**
- Utiliza uma ponte (bridge) entre JavaScript e código nativo
- Para gráficos pesados, pode haver lag perceptível no scroll e animações
- Lib mais popular: `react-native-chart-kit` (limitada) ou `Victory Native` (melhor)
- New Architecture (Fabric + JSI) melhora isso, mas adiciona complexidade de configuração

**Flutter** ✅
- Renderiza com motor gráfico próprio (Skia / Impeller no iOS)
- Animações e gráficos rodam a 60/120fps de forma nativa, sem bridge
- `fl_chart` é a biblioteca mais madura para gráficos em Flutter
- Resulta em UI pixel-perfect em Android e iOS sem ajustes por plataforma

**Veredito:** Flutter vence com margem confortável para um app focado em visualização de dados.

---

### 2. Integração com Assistentes de Voz

**Siri (iOS)**
- Requer `SiriKit` (Intents) — em React Native, feito via módulos nativos customizados (trabalhoso)
- Em Flutter: plugin `siri_shortcuts` + `flutter_siri_shortcuts` cobrem a integração
- Ambos exigem configuração de `App Intents` no Xcode para iOS 16+

**Google Assistant (Android)**
- Integração via `App Actions` (Google)
- React Native: `@assistant-ui/react` ou módulos nativos
- Flutter: `android_intent_plus` + configuração de `shortcuts.xml`
- Ambos são equivalentes; Flutter tem exemplos oficiais mais atualizados

**Speech-to-Text (processamento local/API)**
- `speech_to_text` no Flutter: plugin maduro, suporta pt-BR, múltiplos sotaques
- `@react-native-voice/voice` no React Native: equivalente funcional
- Para NLP (entender variações de frase): ambos delegam à **OpenAI GPT-4o-mini** via API

**Veredito:** Empate técnico, Flutter tem ecosistema de plugins mais organizado.

---

### 3. Google APIs (Sheets + OAuth)

**React Native**
- `@react-native-google-signin/google-signin` para OAuth
- `googleapis` (Node.js) para Sheets — precisa de backend ou chamadas REST diretas
- Funciona bem, mas requer mais boilerplate

**Flutter** ✅
- `google_sign_in` — plugin oficial do Google, amplamente mantido
- `googleapis` (pacote Dart) — acesso direto às APIs Google sem backend no MVP
- `gsheets` — wrapper simplificado para Google Sheets em Dart
- Integração mais fluida e com menos código

**Veredito:** Flutter vence — pacotes Dart oficiais do Google são mais completos.

---

### 4. UX/UI para Telas Verticais

**React Native**
- Depende de libs de terceiros para componentes avançados (bottom sheets, pickers)
- Estilização via StyleSheet — menos intuitiva para layouts complexos
- `react-native-paper` ou `NativeBase` para design system

**Flutter** ✅
- Material Design 3 nativo, altamente customizável
- `DraggableScrollableSheet`, `BottomNavigationBar`, `SliverAppBar` — tudo built-in
- `flutter_animate` para micro-interações modernas
- Suporte a theming dinâmico (modo escuro/claro) com `ThemeData`

**Veredito:** Flutter vence — mais recursos de UI prontos e customizáveis.

---

### 5. Curva de Aprendizado e Tooling

| Aspecto | React Native | Flutter |
|---------|-------------|---------|
| Linguagem | JavaScript/TypeScript | Dart |
| Tipagem | Opcional (TS) | Forte e obrigatória |
| Hot Reload | ✅ | ✅ |
| Debug tools | ✅ Flipper | ✅ DevTools |
| Documentação | ✅ Extensa | ✅ Excelente (dart.dev) |
| Comunidade BR | Maior | Crescendo rapidamente |

**Dart** tem curva inicial de 1-2 semanas para quem já conhece TypeScript/Java, mas a tipagem forte reduz bugs em produção.

---

## Stack Tecnológica Completa — Flutter

### Core
| Tecnologia | Versão | Uso |
|-----------|--------|-----|
| Flutter | 3.22+ | Framework principal |
| Dart | 3.4+ | Linguagem |
| Android Studio | Hedgehog+ | Emulador Android |

### Autenticação e APIs Google
| Pacote | Uso |
|--------|-----|
| `google_sign_in` | OAuth 2.0 com conta Google |
| `googleapis` | Acesso à Google Sheets API v4 |
| `gsheets` | Wrapper simplificado para Sheets |
| `flutter_secure_storage` | Armazenamento seguro de tokens |

### Voz e NLP
| Pacote/Serviço | Uso |
|----------------|-----|
| `speech_to_text` | Captura de áudio → texto (pt-BR) |
| `flutter_siri_shortcuts` | Integração com Siri (iOS) |
| `android_intent_plus` | Integração com Google Assistant |
| OpenAI GPT-4o-mini API | Interpretação NLP das frases |

### Armazenamento Local
| Pacote | Uso |
|--------|-----|
| `hive` + `hive_flutter` | Cache local de transações |
| `shared_preferences` | Configurações do usuário |
| `flutter_secure_storage` | Tokens OAuth |

### UI e Gráficos
| Pacote | Uso |
|--------|-----|
| `fl_chart` | Gráficos de pizza, barras e linha |
| `flutter_animate` | Animações e micro-interações |
| `lottie` | Animações de feedback (loading, sucesso) |
| `cached_network_image` | Avatares e imagens da conta Google |
| `intl` | Formatação de moeda (R$) e datas (pt-BR) |

### Estado e Arquitetura
| Pacote | Uso |
|--------|-----|
| `riverpod` (2.x) | Gerenciamento de estado reativo |
| `go_router` | Navegação declarativa |
| `dio` | HTTP client para APIs externas |
| `freezed` | Data classes imutáveis |
| `json_annotation` | Serialização/deserialização |

### Backend (apenas V1)
| Tecnologia | Uso |
|-----------|-----|
| Node.js + Express | Servidor seguro |
| Railway ou Render | Hospedagem cloud gratuita |
| `jsonwebtoken` | Validação de sessão |

### Testes
| Pacote | Uso |
|--------|-----|
| `flutter_test` | Testes unitários e de widget |
| `mocktail` | Mocking |
| `integration_test` | Testes E2E |
