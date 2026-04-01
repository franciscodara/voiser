# 05 — Plano V1 (Opção 2)

## Conceito

A V1 evolui o **MVP já funcional** para uma arquitetura segura com backend intermediário. As chaves de API saem do app e ficam em um servidor na nuvem. O app passa a conversar com esse servidor, que é o único que conhece as credenciais.

**Esta é a versão pronta para publicação nas lojas.**

---

## Diferença Arquitetural MVP → V1

```
MVP                                    V1
──────────────────────────────         ──────────────────────────────────────
App Flutter                            App Flutter
  │                                      │
  ├─[sk-KEY]──► OpenAI API               ├──► https://api.finwise.app
  └─[OAuth]───► Google Sheets API             │
                                             ├──[sk-KEY]──► OpenAI API
  ⚠️ Chave exposta no código APK           └──[OAuth]───► Google Sheets API

                                         ✅ Chaves apenas no servidor
                                         ✅ APK não contém segredos
```

---

## Stack do Backend (V1)

| Tecnologia | Escolha | Justificativa |
|-----------|---------|---------------|
| Runtime | Node.js 20 LTS | Ecosistema maduro, integração Google APIs |
| Framework | Express.js | Leve, amplamente conhecido |
| Autenticação | Google OAuth + JWT | Valida que o usuário do app é legítimo |
| Hospedagem | Railway.app | Gratuito até $5/mês, deploy simples via GitHub |
| Alternativa | Render.com | Free tier com spin-up (delay de ~30s na 1ª req) |
| Variáveis secretas | `.env` no servidor | Nunca no repositório |
| HTTPS | Automático (Railway/Render) | Certificado SSL incluso |

---

## Arquitetura do Backend

```
finwise-backend/
├── src/
│   ├── middleware/
│   │   ├── auth.middleware.js      # Valida JWT do Google
│   │   └── rate-limit.middleware.js # Protege contra abuso
│   │
│   ├── routes/
│   │   ├── expenses.routes.js      # POST /expenses, GET /expenses
│   │   ├── sheets.routes.js        # GET /sheets/report
│   │   └── nlp.routes.js           # POST /nlp/parse-voice
│   │
│   ├── services/
│   │   ├── google-sheets.service.js  # CRUD Google Sheets API
│   │   ├── openai.service.js         # Chamadas OpenAI GPT
│   │   └── google-auth.service.js    # Validação tokens Google
│   │
│   ├── app.js                        # Express config
│   └── server.js                     # Entry point
│
├── .env.example                      # Template (sem valores reais)
├── .env                              # ← NUNCA NO GIT (.gitignore)
├── package.json
└── README.md
```

---

## Fluxo de Segurança (V1)

```
1. App abre → usuário já logado com Google (token salvo seguro)

2. App registra despesa por voz:
   App ──[POST /nlp/parse-voice]──► Backend
        Headers: { Authorization: "Bearer {google_id_token}" }
        Body: { text: "anotar mercado 356 reais" }

3. Backend valida o token:
   Backend ──[verify]──► Google Auth API
   Se inválido: retorna 401 Unauthorized

4. Backend processa NLP (com chave segura):
   Backend ──[sk-KEY]──► OpenAI API
   Retorno: { amount: 356, category: "supermercado" }

5. Backend salva no Sheets:
   Backend ──[OAuth]──► Google Sheets API
   Adiciona linha na planilha do usuário

6. Backend retorna confirmação:
   Backend ──► App: { success: true, expense: {...} }

7. App exibe confirmação ao usuário ✅
```

---

## Etapas de Migração MVP → V1

### Etapa V1.1 — Backend Setup (Semana 1)

- [ ] Criar repositório `finwise-backend` no GitHub
- [ ] Inicializar projeto Node.js: `npm init -y`
- [ ] Instalar dependências:
  ```bash
  npm install express googleapis openai jsonwebtoken
                google-auth-library dotenv cors helmet
                express-rate-limit
  ```
- [ ] Criar `.env` com:
  ```
  OPENAI_API_KEY=sk-...
  GOOGLE_CLIENT_ID=...
  GOOGLE_CLIENT_SECRET=...
  JWT_SECRET=...
  PORT=3000
  ```
- [ ] Implementar `auth.middleware.js` — valida Google ID Token
- [ ] Implementar `POST /nlp/parse-voice` — substitui chamada direta do app
- [ ] Implementar `POST /expenses` — salva no Sheets via backend
- [ ] Implementar `GET /sheets/report` — lê dados para gráficos
- [ ] Testar localmente com Postman / curl
- [ ] Deploy no Railway: `railway up`

**Resultado:** Backend rodando em `https://finwise-backend.up.railway.app` ✅

---

### Etapa V1.2 — Migração do App Flutter (Semana 2)

No código do MVP, as mudanças são **mínimas e localizadas**:

#### Remover do app:
- [ ] `api_constants.dart` — deletar a `openAiApiKey`
- [ ] `OpenAIDataSource` — não mais necessário no app
- [ ] Dependência direta de `googleapis` para salvar expenses

#### Adicionar ao app:
- [ ] `lib/core/constants/api_constants.dart` — apenas a URL do backend:
  ```dart
  class ApiConstants {
    static const String backendBaseUrl = 'https://finwise-backend.up.railway.app';
  }
  ```
- [ ] `FinWiseApiDataSource` — substitui chamadas diretas:
  ```dart
  // Antes (MVP):
  await openAiDataSource.parseVoiceCommand(text);
  await googleSheetsDataSource.appendExpense(expense);

  // Depois (V1):
  await finWiseApiDataSource.parseVoiceCommand(text);    // chama backend
  await finWiseApiDataSource.addExpense(expense);        // chama backend
  ```
- [ ] Interceptor Dio para adicionar Google ID Token em todos os requests

**Resultado:** App Flutter agora sem nenhuma chave sensível ✅

---

### Etapa V1.3 — Preparação para Publicação (Semana 3)

#### Google Play (Android)
- [ ] Criar conta Google Play Developer ($25 taxa única)
- [ ] Gerar keystore de assinatura: `keytool -genkey ...`
- [ ] Configurar `key.properties` e `build.gradle` para release
- [ ] `flutter build appbundle --release`
- [ ] Preencher fichas do app: descrição, screenshots, categorias
- [ ] Revisar política de privacidade (obrigatória — mencionar uso de microfone)
- [ ] Criar política de privacidade (pode ser página simples no GitHub Pages)
- [ ] Submeter para revisão (prazo: 3-7 dias)

#### App Store (iOS)
- [ ] Conta Apple Developer ($99/ano)
- [ ] Configurar certificados e provisioning profiles no Xcode
- [ ] `flutter build ipa --release`
- [ ] Preencher fichas no App Store Connect
- [ ] Screenshots para todos os tamanhos de tela exigidos
- [ ] Submeter para revisão (prazo: 1-3 dias)

#### Ambos
- [ ] Atualizar `pubspec.yaml`: `version: 1.0.0+1`
- [ ] Testar build de release em dispositivo físico (Android + iOS)
- [ ] Testar fluxo completo end-to-end: voz → backend → Sheets → gráfico

**Resultado:** App publicado nas lojas ✅

---

### Etapa V1.4 — Monitoramento e Melhorias (Contínuo)

- [ ] **Firebase Crashlytics** — rastrear crashes em produção
- [ ] **Firebase Analytics** — uso de features (quais categorias mais usadas)
- [ ] **Push Notifications** — lembrete diário para registrar gastos
  - "Você gastou hoje? Registre agora!"
- [ ] **Widget de tela inicial** (Android/iOS) — saldo do mês visível sem abrir o app
- [ ] **Backup automático** — exportar Sheets para PDF mensalmente
- [ ] **Multi-usuário** — compartilhar planilha com cônjuge/família
- [ ] **Metas por categoria** — alertar quando ultrapassar orçamento definido

---

## Estimativa de Tempo — V1

| Etapa | Dias Úteis |
|-------|-----------|
| V1.1 Backend | 5 |
| V1.2 Migração Flutter | 3 |
| V1.3 Publicação lojas | 7 |
| V1.4 Monitoramento | 3 |
| **Total após MVP** | **~18 dias úteis** |
| **Total acumulado** | **~41 dias úteis** |

---

## Custos Estimados (V1 em produção)

| Serviço | Custo |
|---------|-------|
| Railway (backend) | Grátis até $5/mês |
| OpenAI GPT-4o-mini | ~$0.15 por 1M tokens |
| Google APIs (Sheets) | Grátis (cota pessoal) |
| Google Play (1x) | $25 |
| Apple Developer (anual) | $99/ano |
| **Total 1º ano** | **~$124 + consumo OpenAI** |

> Para uso pessoal (~50 registros/mês de voz), o custo OpenAI estimado é **menos de $0,10/mês**.
