# Monetization

O Voiser usa Stripe Payment Link no cliente e tabela `subscriptions` no Supabase para refletir o plano ativo.

## Cliente Flutter

Arquivo principal:

- `lib/features/account/presentation/screens/subscription_screen.dart`

O app le `STRIPE_PAYMENT_LINK` do `.env`. O link precisa comecar com `https://buy.stripe.com/`.

Ao abrir o checkout, o app adiciona:

- `client_reference_id=<supabase_user_id>`
- `prefilled_email=<user_email>`

Esse `client_reference_id` e o vinculo entre o pagamento Stripe e o usuario Supabase.

## Webhook

O webhook deve rodar server-side, preferencialmente como Supabase Edge Function. Ele deve validar a assinatura Stripe com `STRIPE_WEBHOOK_SECRET`, consultar o evento pago e atualizar `subscriptions`.

Eventos esperados:

- Checkout concluido: ativar plano premium.
- Renovacao ou pagamento confirmado: atualizar `current_period_end`.
- Cancelamento ou expiracao: rebaixar para free ou manter premium ate `current_period_end`.

## Tabela subscriptions

O app espera uma linha por usuario:

- `user_id`: ID Supabase vindo de `client_reference_id`.
- `plan`: `premium` ou `free`.
- `current_period_end`: data de expiracao do periodo atual.

`UserSubscription.isPremium` retorna true quando:

- `plan == premium`; e
- `current_period_end` esta ausente ou ainda esta no futuro.

## Atualizacao no app

Depois de abrir o checkout externo, o app chama `refreshSubscription()` quando o usuario retorna. A UI assume Free em caso de falha de leitura, para nao liberar recursos premium sem confirmacao do backend.

## Segredos

`STRIPE_SECRET_KEY` e `STRIPE_WEBHOOK_SECRET` pertencem ao servidor ou Edge Function. Eles nao devem ser empacotados no app Flutter.
