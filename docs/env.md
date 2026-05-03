# Environment

O app usa `flutter_dotenv` e carrega `.env` em `lib/main.dart`.

## Variaveis do app Flutter

Obrigatorias no cliente:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
STRIPE_PAYMENT_LINK=
```

`SUPABASE_URL` e `SUPABASE_ANON_KEY` sao usados em `Supabase.initialize`.

`STRIPE_PAYMENT_LINK` e usado pela tela de assinatura. Em producao, deve ser um Payment Link valido iniciado por `https://buy.stripe.com/`.

## Variaveis server-side

Obrigatorias no webhook ou Edge Function:

```env
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
```

`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` e `SUPABASE_SERVICE_ROLE_KEY` nao devem ser incluidos no app Flutter.

## Observacao sobre chaves

O arquivo `.env` local pode conter chaves de desenvolvimento. Para publicacao nas lojas, gere chaves e links de producao, revise o empacotamento de assets e garanta que nenhum segredo server-side esteja no bundle do app.
