# Walkthrough

Este guia cobre setup, login, sync e assinatura no estado atual do Voiser.

## 1. Setup do projeto

Pre-requisitos:

- Flutter SDK compativel com `pubspec.yaml`.
- Emulador ou aparelho fisico.
- Projeto Supabase configurado.
- Stripe Payment Link configurado.

Passos:

```bash
flutter pub get
flutter doctor
```

Crie um `.env` na raiz com:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
STRIPE_PAYMENT_LINK=
```

Depois rode:

```bash
flutter run
```

## 2. Login

O app inicia em `/login`.

1. Crie uma conta com email e senha.
2. Confirme o email se o Supabase estiver configurado para exigir confirmacao.
3. Entre com email e senha.
4. Ao autenticar, o `AuthNotifier` dispara um sync inicial com `forcePull=true`.

## 3. Criar despesa ou receita

1. Acesse a tela de adicionar lancamento.
2. Informe valor, categoria, data e descricao opcional.
3. Salve.

O registro e salvo primeiro no Hive com `synced=false`. A UI atualiza imediatamente.

## 4. Fluxo de sync

Com internet:

1. `SyncQueueService` encontra pendencias locais.
2. Cada pendencia e enviada para `expenses` no Supabase por upsert.
3. O Hive marca o registro como `synced=true`.
4. O app executa pull incremental.
5. O Hive recebe alteracoes remotas mais recentes.

Sem internet:

1. O Hive continua aceitando novos registros.
2. Pendencias ficam com `synced=false`.
3. Ao recuperar conectividade, o listener dispara a fila.

Para forcar refresh manual, telas de lista podem chamar `refreshExpenses(syncRemote: true)`.

## 5. Exclusao

A exclusao e tratada como soft delete local:

1. O registro recebe `deleted=true` e `synced=false`.
2. A fila envia o tombstone para o Supabase.
3. Apos sucesso, o registro e removido do Hive.

No pull, registros remotos com `deleted_at` sao removidos localmente.

## 6. Assinatura

1. Acesse `/subscription`.
2. Toque em assinar Premium.
3. O app abre o Stripe Payment Link externo.
4. O link inclui `client_reference_id` com o ID do usuario Supabase.
5. O webhook server-side usa esse ID para atualizar `subscriptions`.
6. Ao retornar ao app, `refreshSubscription()` busca o plano atualizado.

## 7. Como testar pagamento

Ambiente de teste recomendado:

1. Use um Payment Link de teste no `STRIPE_PAYMENT_LINK`.
2. Crie uma conta de teste no app.
3. Abra checkout pela tela de assinatura.
4. Conclua pagamento no ambiente Stripe de teste.
5. Verifique se o webhook criou ou atualizou a linha em `subscriptions`.
6. Confirme que `plan=premium` e `current_period_end` esta no futuro.
7. Volte ao app e atualize a assinatura.

## 8. Validacao tecnica

Checklist:

- Login usa Supabase Auth email/senha.
- `expenses.user_id` recebe o ID Supabase.
- RLS impede leitura cruzada entre usuarios.
- Hive funciona sem rede.
- Push envia pendencias com `synced=false`.
- Pull usa `updated_at` e `lastSyncAt`.
- Server Wins prevalece quando o remoto e mais recente.
- Stripe envia `client_reference_id=user_id`.
- Webhook atualiza `subscriptions`.
- `FeatureGate` bloqueia usuarios Free e libera Premium.
