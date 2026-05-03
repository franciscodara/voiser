import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/core/utils/app_feedback.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:finwise/core/widgets/brand_logo.dart';
import 'package:finwise/features/auth/presentation/providers/auth_provider.dart';
import 'package:finwise/features/subscription/presentation/providers/plan_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  Future<void> _launchStripeCheckout(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    // Idealmente você coloca seu link real no .env (STRIPE_PAYMENT_LINK)
    final baseLink = dotenv.env['STRIPE_PAYMENT_LINK']?.trim();
    if (baseLink == null ||
        baseLink.isEmpty ||
        baseLink.contains('/test_') ||
        !baseLink.startsWith('https://buy.stripe.com/')) {
      AppFeedback.error(
        context,
        'Pagamento indisponivel no momento. Tente novamente mais tarde.',
      );
      return;
    }
    // O Stripe aceita prefilled_email para já vir com o e-mail preenchido
    final url = Uri.parse('$baseLink?client_reference_id=${user.id}&prefilled_email=${user.email}');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        AppFeedback.error(
          const SnackBar(content: Text('Não foi possível abrir o link de pagamento.')),
        );
      }
    } else {
      // Quando o navegador/webview fechar (o usuário volta ao app), checamos o status novamente
      ref.read(planNotifierProvider.notifier).refreshSubscription();
      
      // Fallback: se você quiser continuar usando o upgrade falso enquanto não tem webhook real
      // ref.read(planNotifierProvider.notifier).upgradeToPremiumTemporarily();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscription = ref.watch(planNotifierProvider);
    final isPremium = subscription.isPremium;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: BrandLogo(fontSize: 20, iconSize: 24),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Plano atual ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryStatusPos.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primaryStatusPos,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? 'Plano Premium' : 'Plano Free',
                          style: AppTextStyles.title.copyWith(fontSize: 16),
                        ),
                        Text(
                          isPremium ? 'Seu plano atual' : 'Plano atual',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryStatusPos.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ativo',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryStatusPos,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Card Premium ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D28D9).withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BrandLogo(
                        fontSize: 20,
                        iconSize: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isPremium 
                        ? 'Você já possui acesso total aos recursos Premium.' 
                        : 'Desbloqueie todo o poder do Voiser e controle sua vida financeira.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._premiumFeatures.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFFA78BFA),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            f,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isPremium ? null : () => _launchStripeCheckout(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: isPremium 
                            ? Colors.white.withOpacity(0.18) 
                            : Colors.white,
                        disabledBackgroundColor: Colors.white.withOpacity(0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isPremium ? 'Você já é Premium' : 'Assinar Premium',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isPremium ? Colors.white70 : const Color(0xFF6D28D9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _premiumFeatures = [
    'Sincronização automática em tempo real',
    'Exportação para PDF e Excel',
    'Categorias e relatórios ilimitados',
    'Assistente financeiro com IA',
    'Suporte prioritário',
  ];
}
