# Architecture

O FinWise e um aplicativo Flutter offline-first para controle financeiro pessoal. O app usa Riverpod para estado, GoRouter para navegacao, Hive para armazenamento local, Supabase como backend principal e Stripe para monetizacao.

## Visao geral

Fluxo principal:

1. O usuario autentica com email e senha via Supabase Auth.
2. A sessao Supabase fica disponivel no cliente Flutter.
3. As despesas e receitas sao gravadas primeiro no Hive.
4. A fila de sincronizacao envia alteracoes locais para o Supabase.
5. O pull incremental busca alteracoes remotas e faz merge no Hive.
6. A tela de assinatura abre um Stripe Payment Link.
7. O status Premium e lido da tabela `subscriptions`.

## Camadas

- `lib/main.dart`: inicializa Flutter, locale, Hive, `.env`, Supabase e listeners globais.
- `lib/core/router`: define rotas com GoRouter e redirecionamento por auth.
- `lib/core/services`: contem `SyncQueueService`, `SyncPullService` e `SyncMetadataService`.
- `lib/features/auth`: contem Supabase Auth e `AuthNotifier`.
- `lib/features/expenses`: contem entidade `Expense`, datasource Hive, datasource Supabase e repositorio offline-first.
- `lib/features/subscription`: contem `UserSubscription` e `PlanProvider`.
- `lib/core/widgets/feature_gate.dart`: aplica bloqueio visual e navegacao para assinatura.

## Backend oficial

Supabase e o backend oficial do sistema. O cliente usa:

- Supabase Auth para identidade.
- PostgreSQL via Supabase para `expenses` e `subscriptions`.
- RLS para garantir isolamento por `user_id`.
- Edge Function ou webhook server-side para receber eventos Stripe e atualizar `subscriptions`.

## Offline-first

Hive e a fonte imediata da experiencia do app. Criacoes e exclusoes nao dependem de rede para atualizar a UI. A sincronizacao roda em background e tambem e disparada quando a conectividade volta.

## Sync bidirecional

O sync tem dois lados:

- Push: `SyncQueueService` pega registros locais com `synced=false` e faz upsert no Supabase.
- Pull: `SyncPullService` busca registros remotos alterados desde `lastSyncAt` e aplica merge local.

A regra de conflito implementada no pull e Server Wins: quando o remoto tem `updated_at` mais recente que o local, o remoto substitui o registro no Hive.

## Monetizacao

O app abre um Stripe Payment Link definido por `STRIPE_PAYMENT_LINK`. O link recebe `client_reference_id` com o `user.id` do Supabase e `prefilled_email` com o email do usuario. A assinatura ativa deve ser persistida na tabela `subscriptions`, lida pelo `PlanProvider`.
