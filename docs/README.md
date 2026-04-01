# FinWise — Gestão de Orçamento Doméstico
## Plano de Desenvolvimento Completo

> **Versão do documento:** 1.0  
> **Arquiteto:** Senior Software & Data Engineer  
> **Stack principal:** Flutter (Dart)  
> **IDE:** Google Antigravity (Linux) + Android Studio  

---

## Índice

| Arquivo | Descrição |
|--------|-----------|
| [README.md](./README.md) | Este documento — visão geral e decisão tecnológica |
| [01-decisao-tecnologica.md](./01-decisao-tecnologica.md) | Análise React Native vs Flutter + justificativa |
| [02-arquitetura-software.md](./02-arquitetura-software.md) | Arquitetura geral, camadas e padrões |
| [03-arquitetura-pastas.md](./03-arquitetura-pastas.md) | Estrutura de pastas com contextos detalhados |
| [04-mvp-plano.md](./04-mvp-plano.md) | MVP — chave embutida, funcionalidades e etapas |
| [05-v1-plano.md](./05-v1-plano.md) | V1 — servidor backend seguro, deploy nas lojas |
| [06-prompts-agente-ia.md](./06-prompts-agente-ia.md) | Blocos de prompts na 1ª pessoa para o agente IA |

---

## Resumo Executivo

**FinWise** é um aplicativo móvel multiplataforma (Android + iOS) de gestão de orçamento doméstico com:

- ✅ Entrada de despesas por **comando de voz** (Google Assistant / Siri)
- ✅ Sincronização automática com **Google Sheets**
- ✅ Login com **conta Google** (OAuth 2.0)
- ✅ **Gráficos interativos** de entradas e saídas por categoria
- ✅ Categorias com **sub-categorias configuráveis**
- ✅ Entrada **manual** com UX moderna para telas verticais
- ✅ **Processamento de linguagem natural** para variações de voz e sotaques

---

## Decisão de Framework: Flutter ✅

Após análise detalhada (ver `01-decisao-tecnologica.md`), **Flutter foi escolhido** como framework principal.

**Resumo da decisão:**

| Critério | React Native | Flutter |
|----------|-------------|---------|
| Performance gráfica (gráficos) | ⚠️ Bridge JS-Native | ✅ Renderização própria (Skia) |
| Integração Siri / Google Assistant | ✅ Bom | ✅ Excelente via plugins |
| UI consistente Android + iOS | ⚠️ Depende de libs nativas | ✅ Pixel-perfect em ambos |
| NLP / speech_to_text | ✅ OK | ✅ Maduro e estável |
| Comunidade para Google APIs | ✅ Boa | ✅ Excelente |
| Curva de aprendizado (Dart) | — | Moderada, tipagem forte |
| **Veredicto** | Segunda opção | ✅ **Escolhido** |

---

## Visão das Duas Etapas

```
MVP (Opção 1)                          V1 (Opção 2)
─────────────────────                  ─────────────────────────────
App Flutter                            App Flutter
  │                                      │
  ├── Google OAuth (login)               ├── Google OAuth (login)
  ├── Google Sheets API ◄── API Key      ├── Backend Node.js (Railway/Render)
  ├── OpenAI Whisper/GPT ◄── API Key     │     ├── Google Sheets API
  ├── Speech-to-Text local              │     ├── OpenAI API
  └── Charts (fl_chart)                 │     └── Auth middleware
                                        ├── Speech-to-Text local
  ⚠️ API Keys embutidas no código        └── Charts (fl_chart)
     (apenas uso pessoal/teste)
                                         ✅ Pronta para publicação
                                            Google Play + App Store
```
