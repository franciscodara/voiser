import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/finwise_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha email e senha.'),
          backgroundColor: AppColors.primaryStatusNeg,
        ),
      );
      return;
    }

    if (_isSignUp) {
      ref.read(authNotifierProvider.notifier).signUp(email, password).catchError((e) {
        if (!mounted) return;
        
        final msg = e.toString().replaceAll('Exception: ', '');
        
        // Se a mensagem diz "Conta criada!", significa que foi sucesso mas precisa confirmar o e-mail.
        // Muda para o modo de login automaticamente.
        if (msg.contains('Conta criada!')) {
          setState(() {
            _isSignUp = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppColors.primaryStatusPos),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppColors.primaryStatusNeg),
          );
        }
      });
    } else {
      ref.read(authNotifierProvider.notifier).signIn(email, password).catchError((e) {
        if (!mounted) return;
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.primaryStatusNeg),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ).animate().fade(duration: 500.ms).scale(curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'Voiser',
                style: AppTextStyles.display.copyWith(
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                'Sua vida financeira na nuvem, sempre acessível.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 48),

              // Campos
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ).animate().fade(delay: 600.ms).slideY(begin: 0.2),
              const SizedBox(height: 24),

              FinwiseButton(
                text: _isSignUp ? 'Criar Conta' : 'Entrar',
                isLoading: isLoading,
                onPressed: _submit,
              ).animate().fade(delay: 700.ms, duration: 500.ms).slideY(begin: 0.5),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp ? 'Já tem uma conta? Entrar' : 'Não tem conta? Criar',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ).animate().fade(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
