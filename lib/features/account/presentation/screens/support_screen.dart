import 'package:flutter/material.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Fale Conosco', style: AppTextStyles.title),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ───────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.headset_mic_outlined,
                    color: Colors.white70,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Estamos aqui para ajudar',
                    style: AppTextStyles.title.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nossa equipe responde em até 24 horas úteis.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'CANAIS DE ATENDIMENTO',
              style: AppTextStyles.label.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.45),
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            _SupportChannel(
              icon: Icons.email_outlined,
              label: 'E-mail',
              value: 'suporte@finwise.app',
              color: AppColors.primaryStatusPos,
              isComingSoon: true,
            ),
            const SizedBox(height: 12),
            _SupportChannel(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat ao vivo',
              value: 'Segunda a Sexta, 9h–18h',
              color: const Color(0xFF6366F1),
              isComingSoon: true,
            ),
            const SizedBox(height: 12),
            _SupportChannel(
              icon: Icons.help_outline_rounded,
              label: 'Central de ajuda',
              value: 'Artigos e tutoriais',
              color: const Color(0xFF0EA5E9),
              isComingSoon: true,
            ),

            const SizedBox(height: 28),

            Text(
              'VERSÃO',
              style: AppTextStyles.label.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.45),
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.15),
                ),
              ),
              child: Text(
                'FinWise  ·  v1.0.0',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Support Channel Card ──────────────────────────────────────────────────────

class _SupportChannel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isComingSoon;

  const _SupportChannel({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isComingSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Em breve',
                style: AppTextStyles.label.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
