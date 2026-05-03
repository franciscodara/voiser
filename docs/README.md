# FinWise Docs

Esta pasta descreve o estado atual do FinWise apos a migracao para Supabase.

Documentos principais:

- [architecture.md](architecture.md): visao geral da arquitetura.
- [auth.md](auth.md): autenticacao, sessao e rotas protegidas.
- [sync.md](sync.md): fluxo offline-first, push, pull e merge.
- [database.md](database.md): tabelas, campos e RLS.
- [monetization.md](monetization.md): Stripe, webhook e assinatura.
- [feature_gate.md](feature_gate.md): bloqueio Free vs Premium.
- [frontend_backend_contract.md](frontend_backend_contract.md): contratos entre app, Supabase e Stripe.
- [env.md](env.md): variaveis de ambiente.
- [walkthrough.md](walkthrough.md): guia de setup e testes.

Documentacao historica baseada na arquitetura anterior foi removida porque nao refletia mais o codigo atual.
