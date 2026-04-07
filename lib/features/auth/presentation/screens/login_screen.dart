import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/finwise_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao autenticar: ${next.error}'),
            backgroundColor: AppColors.primaryStatusNeg,
          ),
        );
      }
    });

    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ).animate().fade(duration: 500.ms).scale(curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'FinWise',
                style: AppTextStyles.display.copyWith(
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Gestão inteligente por voz para o seu orçamento no Google Sheets.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2),
              const Spacer(flex: 3),
              FinwiseButton(
                text: 'Entrar com Google',
                isLoading: isLoading,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signIn();
                },
              ).animate().fade(delay: 600.ms, duration: 500.ms).slideY(begin: 0.5),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
