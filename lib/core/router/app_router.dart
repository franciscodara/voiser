import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/auth/presentation/screens/login_screen.dart';
import 'package:finwise/features/home/presentation/screens/home_screen.dart';
import 'package:finwise/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:finwise/features/expenses/presentation/screens/voice_entry_screen.dart';
import 'package:finwise/features/dashboard/presentation/dashboard_screen.dart';
import 'package:finwise/features/account/presentation/screens/profile_screen.dart';
import 'package:finwise/features/account/presentation/screens/settings_screen.dart';
import 'package:finwise/features/account/presentation/screens/support_screen.dart';
import 'package:finwise/features/account/presentation/screens/subscription_screen.dart';

part 'app_router.g.dart';

// ── Transição reutilizável ────────────────────────────────────────────────────

Page<T> _fadePage<T>(Widget child) {
  return CustomTransitionPage<T>(
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

// ── Router ────────────────────────────────────────────────────────────────────

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
        pageBuilder: (context, state) => _fadePage(const LoginScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _fadePage(const HomeScreen()),
      ),
      GoRoute(
        path: '/add-expense',
        pageBuilder: (context, state) {
          final amountParam = state.uri.queryParameters['amount'];
          final initialAmount = amountParam == null ? null : double.tryParse(amountParam);

          return _fadePage(AddExpenseScreen(
            initialAmount: initialAmount,
            initialDescription: state.uri.queryParameters['description'],
            initialCategoryName: state.uri.queryParameters['categoryName'],
            initialSubcategory: state.uri.queryParameters['subcategory'],
          ));
        },
      ),
      GoRoute(
        path: '/voice-entry',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters['query'];
          return _fadePage(VoiceEntryScreen(initialText: q));
        },
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _fadePage(const DashboardScreen()),
      ),
      // ── Rotas de conta ──────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _fadePage(const ProfileScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _fadePage(const SettingsScreen()),
      ),
      GoRoute(
        path: '/support',
        pageBuilder: (context, state) => _fadePage(const SupportScreen()),
      ),
      GoRoute(
        path: '/subscription',
        pageBuilder: (context, state) => _fadePage(const SubscriptionScreen()),
      ),
    ],
  );
}
