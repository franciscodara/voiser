import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';
import 'package:finwise/features/subscription/presentation/providers/plan_provider.dart';

class FeatureGate extends ConsumerWidget {
  final Widget child;
  final String title;
  final String subtitle;
  
  /// Cria um gate premium sobre o widget [child], ofuscando-o e exibindo 
  /// um CTA para assinar caso o usuário não seja premium.
  const FeatureGate({
    super.key,
    required this.child,
    this.title = 'Recurso Premium',
    this.subtitle = 'Desbloqueie esse e outros recursos avançados.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(planNotifierProvider);

    if (subscription.isPremium) {
      return child;
    }

    return Stack(
      children: [
        // O conteúdo real embaixo (não interativo se bloqueado)
        IgnorePointer(child: child),

        // Blur effect e Overlay
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // ou algo genérico
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFFFBBF24),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: AppTextStyles.title.copyWith(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.push('/subscription'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6D28D9),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Desbloquear Premium'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
