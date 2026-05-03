# Frontend and Backend Contract

Este documento define a fronteira entre o app Flutter, Supabase e Stripe. Use como referencia para evolucao por times diferentes sem quebrar autenticacao, sync ou monetizacao.

## Responsabilidades do frontend

O app Flutter e responsavel por:

- Inicializar Supabase com `SUPABASE_URL` e `SUPABASE_ANON_KEY`.
- Autenticar usuarios com Supabase Auth via email e senha.
- Manter a experiencia offline-first usando Hive.
- Gravar despesas e receitas primeiro no Hive.
- Marcar registros locais pendentes com `synced=false`.
- Enviar pendencias para Supabase via `SyncQueueService`.
- Buscar alteracoes remotas via `SyncPullService`.
- Aplicar merge local com regra Server Wins.
- Ler o plano do usuario via `PlanProvider`.
- Bloquear UX Free com `FeatureGate`.
- Abrir Stripe Payment Link com `client_reference_id=user_id`.

Arquivos principais:

- `lib/main.dart`
- `lib/features/auth/data/datasources/supabase_auth_datasource.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/features/expenses/data/datasources/local/expense_hive_datasource.dart`
- `lib/features/expenses/data/datasources/remote/supabase_datasource.dart`
- `lib/features/expenses/data/repositories/expense_repository_impl.dart`
- `lib/core/services/sync_queue_service.dart`
- `lib/core/services/sync_pull_service.dart`
- `lib/core/services/sync_metadata_service.dart`
- `lib/features/subscription/presentation/providers/plan_provider.dart`
- `lib/core/widgets/feature_gate.dart`
- `lib/features/account/presentation/screens/subscription_screen.dart`

## Responsabilidades do backend

Supabase e servicos server-side sao responsaveis por:

- Persistir dados remotos em PostgreSQL.
- Proteger dados com RLS por `user_id`.
- Aceitar upsert idempotente em `expenses`.
- Expor leitura incremental por `updated_at`.
- Guardar assinaturas em `subscriptions`.
- Receber eventos Stripe em uma Edge Function ou webhook server-side.
- Validar assinatura do webhook Stripe com `STRIPE_WEBHOOK_SECRET`.
- Usar credenciais server-side para escrever em `subscriptions`.

O backend nao deve depender de estado local do dispositivo. A fonte remota de verdade para dados sincronizados e Supabase; a fonte de verdade para plano pago e a tabela `subscriptions`, atualizada pelo webhook.

## Contrato de autenticacao

Frontend:

- Chama `signInWithPassword(email, password)`.
- Chama `signUp(email, password)`.
- Observa `authStateChanges`.
- Usa `currentUser.id` como `user_id` em dados remotos.

Backend:

- Emite e valida sessoes Supabase.
- Aplica RLS usando `auth.uid()`.
- Nunca deve confiar em `user_id` enviado pelo cliente sem RLS.

Estados esperados no app:

- `AuthStatus.loading`
- `AuthStatus.authenticated`
- `AuthStatus.unauthenticated`

## Contrato da tabela expenses

Payload enviado pelo app:

```json
{
  "id": "string",
  "user_id": "supabase-user-id",
  "date": "ISO-8601 UTC",
  "category_id": "string",
  "category_name": "string",
  "subcategory": "string|null",
  "description": "string|null",
  "amount": 0.0,
  "type": "expense|income",
  "origin": "manual|voice",
  "created_at": "ISO-8601 UTC",
  "updated_at": "ISO-8601 UTC",
  "deleted_at": "ISO-8601 UTC|null"
}
```

Regras:

- `id` deve ser unico e usado como conflito no upsert.
- `user_id` e obrigatorio.
- `updated_at` e obrigatorio para sync incremental.
- `deleted_at != null` representa tombstone remoto.
- Datas devem ser armazenadas como `timestamptz`.

Resposta esperada pelo app:

- Mesmos campos em snake_case.
- `amount` numerico.
- Registros deletados podem voltar no pull para limpar Hive local.

## Contrato de sync

### Push

Frontend:

1. Le registros Hive com `synced=false`.
2. Faz upsert em `expenses` com `onConflict: id`.
3. Se sucesso e registro ativo, marca `synced=true`.
4. Se sucesso e registro deletado, remove do Hive.

Backend:

- Deve aceitar upsert idempotente por `id`.
- Deve restringir operacao ao dono via RLS.
- Deve preservar `updated_at` recebido do cliente, salvo se houver uma regra explicita diferente.

### Pull

Frontend:

1. Le `lastSyncAt`.
2. Busca `expenses` do usuario com `updated_at > lastSyncAt`.
3. Aplica merge no Hive.
4. Atualiza `lastSyncAt`.

Backend:

- Deve permitir select por usuario autenticado.
- Deve suportar filtro por `updated_at`.
- Deve retornar tombstones com `deleted_at`.

### Conflito

A regra atual e Server Wins:

- Se remoto for mais recente, substitui local.
- Se remoto estiver deletado, remove local.
- Se local for mais recente e ainda pendente, push posterior deve enviar a versao local.

## Contrato da tabela subscriptions

Payload esperado pelo app:

```json
{
  "user_id": "supabase-user-id",
  "plan": "free|premium",
  "current_period_end": "ISO-8601 UTC|null"
}
```

Regras:

- Deve existir no maximo uma assinatura ativa por `user_id`.
- `plan=premium` libera recursos quando `current_period_end` esta ausente ou no futuro.
- Se `current_period_end` estiver no passado, o app trata como Free.
- Escrita deve ser server-side. O cliente deve apenas ler.

## Contrato Stripe

Frontend:

- Le `STRIPE_PAYMENT_LINK`.
- Abre URL externa.
- Envia `client_reference_id` com `user.id`.
- Envia `prefilled_email` com `user.email`.
- Ao retornar, chama `refreshSubscription()`.

Webhook server-side:

- Valida assinatura com `STRIPE_WEBHOOK_SECRET`.
- Usa `client_reference_id` para identificar `user_id`.
- Atualiza `subscriptions.plan`.
- Atualiza `subscriptions.current_period_end`.
- Usa chave server-side, nunca a anon key do app, para escrever assinatura.

## Variaveis por camada

Frontend:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `STRIPE_PAYMENT_LINK`

Backend ou Edge Function:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`

## Checklist para mudancas futuras

Antes de alterar sync, auth ou monetizacao:

- Atualizar este contrato.
- Validar que `expenses.user_id` continua obrigatorio.
- Validar RLS em `expenses` e `subscriptions`.
- Confirmar que `updated_at` continua sustentando pull incremental.
- Confirmar que tombstones continuam usando `deleted_at`.
- Confirmar que Stripe continua enviando `client_reference_id=user_id`.
- Confirmar que `PlanProvider` ainda consegue ler `subscriptions`.
