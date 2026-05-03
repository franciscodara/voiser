# Sync

O Voiser usa sincronizacao offline-first com Hive local e Supabase remoto.

## Componentes

- `ExpenseHiveDatasource`: persiste despesas no box Hive `expenses_box`.
- `ExpenseRepositoryImpl`: salva e deleta sempre no Hive primeiro.
- `SyncQueueService`: processa a fila local e envia alteracoes para o Supabase.
- `SyncPullService`: busca alteracoes remotas e aplica merge local.
- `SyncMetadataService`: guarda `lastSyncAt` em `SharedPreferences`.
- `SupabaseDatasource`: faz upsert e fetch na tabela `expenses`.

## Fluxo completo

1. Usuario cria ou edita um dado.
2. O app grava no Hive com `synced=false`.
3. `SyncQueueService.processQueue()` roda em background.
4. Pendencias locais sao enviadas ao Supabase por upsert.
5. Registros enviados com sucesso sao marcados como `synced=true`.
6. Em seguida, `SyncPullService.pullAndMerge()` busca alteracoes remotas.
7. O merge atualiza o Hive com dados do servidor quando aplicavel.

## Push

`SyncQueueService` busca `getPendingExpenses()`, ou seja, registros locais com `synced=false`.

Para cada registro:

- Chama `SupabaseDatasource.upsertExpense(expense)`.
- Envia `user_id` com o ID do usuario autenticado.
- Envia datas em UTC.
- Usa `upsert(..., onConflict: 'id')` para idempotencia.

Se a despesa esta marcada como deletada (`deleted=true` ou `deletedAt != null`), o tombstone e enviado ao Supabase e o registro local e removido do Hive apos sucesso.

## Pull e merge

Depois do push, o app roda pull:

- Pull completo quando `forcePull=true` ou quando o Hive esta vazio.
- Pull incremental quando existe `lastSyncAt`.

`SyncPullService` chama `fetchExpenses(updatedAfter: lastSyncAt)`. No Supabase, a query filtra:

- `user_id == currentUser.id`
- `updated_at > lastSyncAt`, quando houver metadata local.

## Regra Server Wins

A regra implementada e Server Wins:

- Se o remoto nao existe localmente, ele e inserido no Hive.
- Se o remoto tem `deleted_at` ou `deleted=true`, o local e removido.
- Se remoto e local existem, o app compara `remote.updatedAt` contra `local.updatedAt`.
- Se o remoto for mais recente, o remoto substitui o local.
- Se o local for mais recente, o local permanece e devera ser enviado pelo push quando estiver pendente.

## updated_at

`updated_at` e o campo usado para sync incremental e resolucao de conflitos. No push, o cliente envia `updated_at` vindo do proprio `Expense`. Quando o campo esta ausente em dados legados, o datasource usa `expense.date` como fallback.

## lastSyncAt

`SyncMetadataService` guarda `last_sync_at` localmente em UTC. Esse valor reduz o volume do pull incremental. Apos um pull sem erro fatal, o valor e atualizado para `DateTime.now()`.

## Comportamento offline

Sem rede ou sem sessao, o app continua salvando no Hive. Os dados ficam pendentes com `synced=false`. Quando a conectividade volta, `startConnectivityListener()` dispara `processQueue()`.

## Observacoes atuais

O dashboard e as listas leem dados locais. Portanto, a experiencia principal permanece responsiva mesmo sem conexao.
