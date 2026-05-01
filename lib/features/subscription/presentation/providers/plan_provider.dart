import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/subscription/domain/entities/user_subscription.dart';

part 'plan_provider.g.dart';

@Riverpod(keepAlive: true)
class PlanNotifier extends _$PlanNotifier {
  @override
  UserSubscription build() {
    // Escuta mudanças de auth (login/logout)
    final user = ref.watch(authNotifierProvider).user;
    
    // Se não há usuário, sempre é Free
    if (user == null) {
      return UserSubscription.free();
    }

    // Como é síncrono, retornamos free por padrão e buscamos em background
    // (Poderia ser AsyncNotifier, mas mantemos síncrono para simplificar UI)
    _fetchSubscription(user.id);

    return UserSubscription.free();
  }

  Future<void> _fetchSubscription(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        state = UserSubscription.fromJson(response);
      } else {
        state = UserSubscription.free();
      }
    } catch (e) {
      // Falha silenciosa para não quebrar UI; assume free
      state = UserSubscription.free();
    }
  }

  Future<void> refreshSubscription() async {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      await _fetchSubscription(user.id);
    }
  }

  void upgradeToPremiumTemporarily() {
    state = UserSubscription(
      plan: UserPlan.premium,
      // expiração simulada para testes
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  void revertToFree() {
    state = UserSubscription.free();
  }
}
