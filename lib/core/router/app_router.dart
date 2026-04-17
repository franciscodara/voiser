import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/auth/presentation/screens/login_screen.dart';
import 'package:finwise/features/home/presentation/screens/home_screen.dart';
import 'package:finwise/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:finwise/features/expenses/presentation/screens/voice_entry_screen.dart';
import 'package:finwise/features/dashboard/presentation/dashboard_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authNotifier.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (authNotifier.isLoading) return null;

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/home';

      return null;
    },
    // Intercepta URLs com scheme customizado (finwise://) que o GoRouter
    // não consegue parsear como rota interna e as redireciona corretamente.
    onException: (context, state, router) {
      final uri = state.uri;

      // finwise://voice-entry?query=... → /voice-entry?query=...
      if (uri.scheme == 'finwise') {
        final path = '/${uri.host}';
        final query = uri.queryParameters;
        final target = Uri(path: path, queryParameters: query.isEmpty ? null : query).toString();
        router.go(target);
        return;
      }

      // Fallback: "Page Not Found" seguro
      router.go('/home');
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-expense',
        builder: (context, state) {
          final amountParam = state.uri.queryParameters['amount'];
          final initialAmount = amountParam == null ? null : double.tryParse(amountParam);

          return AddExpenseScreen(
            initialAmount: initialAmount,
            initialDescription: state.uri.queryParameters['description'],
            initialCategoryName: state.uri.queryParameters['categoryName'],
            initialSubcategory: state.uri.queryParameters['subcategory'],
          );
        },
      ),
      GoRoute(
        path: '/voice-entry',
        builder: (context, state) {
          final q = state.uri.queryParameters['query'];
          return VoiceEntryScreen(initialText: q);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}
