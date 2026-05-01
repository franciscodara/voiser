import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finwise/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:finwise/features/expenses/data/datasources/local/expense_hive_datasource.dart';

part 'auth_provider.g.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthStateData {
  final AuthStatus status;
  final User? user;

  const AuthStateData({
    required this.status,
    this.user,
  });
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  AuthStateData build() {
    final datasource = ref.watch(supabaseAuthDatasourceProvider);
    
    // Configurar o estado inicial antes do listener atuar
    final initialUser = datasource.currentUser;
    
    // Escuta os eventos nativos de sessão do Supabase (Login, Logout, Token Refresh, Expiração)
    _authSubscription?.cancel();
    _authSubscription = datasource.authStateChanges.listen((event) {
      final session = event.session;
      if (session != null) {
        state = AuthStateData(status: AuthStatus.authenticated, user: session.user);
      } else {
        state = const AuthStateData(status: AuthStatus.unauthenticated, user: null);
      }
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    if (initialUser != null) {
      return AuthStateData(status: AuthStatus.authenticated, user: initialUser);
    } else {
      return const AuthStateData(status: AuthStatus.unauthenticated, user: null);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = AuthStateData(status: AuthStatus.loading, user: state.user);
    try {
      await ref.read(supabaseAuthDatasourceProvider).signIn(email: email, password: password);
      // O estado será atualizado pelo listener do authStateChanges
    } on AuthException catch (e) {
      state = const AuthStateData(status: AuthStatus.unauthenticated, user: null);
      if (e.message.contains('Invalid login credentials')) {
        throw Exception("E-mail ou senha incorretos. Verifique seus dados.");
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception("Por favor, confirme seu e-mail antes de entrar.");
      }
      throw Exception(e.message);
    } catch (e) {
      state = const AuthStateData(status: AuthStatus.unauthenticated, user: null);
      throw Exception("Ocorreu um erro inesperado: $e");
    }
  }

  Future<void> signUp(String email, String password) async {
    state = AuthStateData(status: AuthStatus.loading, user: state.user);
    try {
      final response = await ref.read(supabaseAuthDatasourceProvider).signUp(email: email, password: password);
      
      // Se a sessão for nula, a conta foi criada mas precisa de confirmação de e-mail.
      if (response.session == null) {
        state = const AuthStateData(status: AuthStatus.unauthenticated, user: null);
        throw Exception("Conta criada! Verifique sua caixa de e-mail para confirmar seu cadastro.");
      }
      
      // Se tiver sessão, o listener cuidará de mudar o estado para authenticated.
    } on AuthException catch (e) {
      state = const AuthStateData(status: AuthStatus.unauthenticated, user: null);
      if (e.message.contains('User already registered')) {
        throw Exception("Este e-mail já está em uso. Tente fazer login.");
      }
      throw Exception(e.message);
    } catch (e) {
      state = const AuthStateData(status: AuthStatus.unauthenticated, user: null);
      throw Exception("Erro ao criar conta: $e");
    }
  }

  Future<void> signOut() async {
    state = AuthStateData(status: AuthStatus.loading, user: state.user);
    try {
      // 1. Faz o logout da API (invalida sessão)
      await ref.read(supabaseAuthDatasourceProvider).signOut();
      
      // 2. Segurança OFFLINE-FIRST Crítica: 
      // Limpa todo o cache de despesas do aparelho para que o próximo usuário não veja dados alheios
      await ref.read(expenseHiveDatasourceProvider).clearUserData();
      
    } catch (e) {
      debugPrint('Error during sign out: $e');
    } finally {
      state = const AuthStateData(status: AuthStatus.unauthenticated, user: null);
    }
  }
}
