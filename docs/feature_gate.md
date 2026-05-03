# Feature Gate

O controle Free vs Premium e feito no cliente por `PlanProvider`, `UserSubscription` e `FeatureGate`.

## Componentes

- `lib/features/subscription/domain/entities/user_subscription.dart`
- `lib/features/subscription/presentation/providers/plan_provider.dart`
- `lib/core/widgets/feature_gate.dart`
- `lib/features/account/presentation/screens/subscription_screen.dart`

## UserSubscription

`UserSubscription` contem:

- `plan`: `free` ou `premium`.
- `expiresAt`: data opcional de expiracao.

`isPremium` valida se o plano e premium e, quando existe expiracao, se ela ainda esta no futuro.

## PlanProvider

`PlanNotifier` observa o usuario autenticado. Quando nao ha usuario, retorna Free.

Quando ha usuario:

1. Retorna Free inicialmente para manter a UI sincronamente simples.
2. Busca `subscriptions` no Supabase por `user_id`.
3. Atualiza o estado com `UserSubscription.fromJson`.
4. Em erro, assume Free.

Tambem expoe:

- `refreshSubscription()`: reler plano no Supabase.
- `upgradeToPremiumTemporarily()`: helper de teste local.
- `revertToFree()`: helper de teste local.

## FeatureGate

`FeatureGate` recebe um `child`. Se `subscription.isPremium` for true, renderiza o conteudo normalmente.

Se o usuario for Free:

- Mantem o conteudo real visivel por baixo.
- Bloqueia interacao com `IgnorePointer`.
- Aplica blur.
- Mostra titulo, subtitulo e CTA.
- O CTA navega para `/subscription`.

## UX

A UX atual comunica bloqueio sem esconder totalmente o valor do recurso. O usuario ve uma previa desfocada e uma chamada direta para desbloquear Premium.

## Importante

O gate no cliente melhora UX, mas a autorizacao real de recursos pagos deve ser reforcada no backend sempre que houver operacoes server-side sensiveis.
