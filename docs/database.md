# Database

Supabase PostgreSQL e a base remota oficial do Voiser.

## Tabela expenses

Usada para despesas e receitas sincronizadas.

Campos esperados pelo app:

- `id`: identificador unico gerado no cliente.
- `user_id`: ID do usuario Supabase. Obrigatorio.
- `date`: data da transacao.
- `category_id`: ID da categoria.
- `category_name`: nome da categoria.
- `subcategory`: subcategoria opcional.
- `description`: descricao opcional.
- `amount`: valor numerico.
- `type`: `expense` ou `income`.
- `origin`: `manual` ou `voice`.
- `created_at`: criacao do registro.
- `updated_at`: ultima alteracao usada pelo sync.
- `deleted_at`: tombstone para exclusao remota.

O cliente faz upsert por `id`. A coluna `user_id` deve ser sempre preenchida com o usuario autenticado.

## Tabela subscriptions

Usada para controle Free vs Premium.

Campos esperados pelo app:

- `user_id`: ID do usuario Supabase.
- `plan`: `free` ou `premium`.
- `current_period_end`: fim do periodo pago. Quando ausente em plano premium, o app considera premium sem expiracao local.

`PlanProvider` consulta `subscriptions` filtrando por `user_id` e usa `maybeSingle()`.

## RLS

RLS deve estar habilitado nas tabelas de dados de usuario.

Politicas recomendadas para `expenses`:

- SELECT apenas quando `auth.uid() = user_id`.
- INSERT apenas quando `auth.uid() = user_id`.
- UPDATE apenas quando `auth.uid() = user_id`.
- DELETE, se habilitado, apenas quando `auth.uid() = user_id`.

Politicas recomendadas para `subscriptions`:

- SELECT apenas quando `auth.uid() = user_id`.
- Escrita deve ser feita pelo backend server-side, webhook ou service role, nao diretamente pelo cliente.

## Contrato de datas

O app envia datas em UTC para colunas temporais. No banco, prefira `timestamptz` para `date`, `created_at`, `updated_at`, `deleted_at` e `current_period_end`.

## Indices recomendados

- `expenses(id)` unico ou chave primaria.
- `expenses(user_id, updated_at)` para pull incremental.
- `subscriptions(user_id)` unico para leitura do plano.
