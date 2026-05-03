# Auth

O FinWise usa Supabase Auth com email e senha.

## Implementacao

Arquivos principais:

- `lib/main.dart`
- `lib/features/auth/data/datasources/supabase_auth_datasource.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/core/router/app_router.dart`

`main.dart` carrega `SUPABASE_URL` e `SUPABASE_ANON_KEY` do `.env` e inicializa `Supabase.initialize`.

`SupabaseAuthDatasource` encapsula:

- `authStateChanges`
- `currentUser`
- `signInWithPassword`
- `signUp`
- `signOut`

## AuthStatus

`AuthNotifier` expoe:

- `loading`: operacao de auth em andamento.
- `authenticated`: ha uma sessao Supabase e um `User`.
- `unauthenticated`: nao ha usuario autenticado.

No build inicial, o provider le `currentUser`. Se existir usuario, o app entra como autenticado e dispara um sync inicial com `processQueue(forcePull: true)`.

## Persistencia de sessao

A persistencia da sessao e responsabilidade do `supabase_flutter`. Ao reiniciar o app, `currentUser` e `authStateChanges` restauram o estado quando a sessao ainda e valida.

## Login e cadastro

O login usa email e senha. Erros conhecidos sao traduzidos para mensagens de UI, como credenciais invalidas ou email ainda nao confirmado.

No cadastro, se `response.session == null`, o usuario precisa confirmar o email antes de entrar.

## Logout

O logout chama Supabase Auth `signOut` e depois limpa o cache local de despesas no Hive com `clearUserData`. Isso evita que um proximo usuario no mesmo aparelho veja dados anteriores.

## Rotas protegidas

`GoRouter` inicia em `/login` e usa `AuthStatus` no `redirect`:

- Usuario nao autenticado fora de `/login` vai para `/login`.
- Usuario autenticado em `/login` vai para `/home`.
- Durante `loading`, nao ha redirecionamento.

Rotas registradas:

- `/login`
- `/home`
- `/add-expense`
- `/voice-entry`
- `/dashboard`
- `/profile`
- `/settings`
- `/support`
- `/subscription`
