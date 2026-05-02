import 'package:flutter/material.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Configurações', style: AppTextStyles.title),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('APARÊNCIA'),
            const SizedBox(height: 10),
            _SettingsCard(items: [
              _SettingsItem(
                icon: Icons.dark_mode_outlined,
                label: 'Tema escuro',
                color: const Color(0xFF6366F1),
                isComingSoon: false,
                trailing: Switch(
                  value: true,
                  activeColor: AppColors.primaryStatusPos,
                  onChanged: null,
                ),
              ),
              _SettingsItem(
                icon: Icons.language_rounded,
                label: 'Idioma',
                color: const Color(0xFF0EA5E9),
                isComingSoon: true,
                subtitle: 'Português (Brasil)',
              ),
            ]),

            const SizedBox(height: 20),

            _SectionLabel('DADOS'),
            const SizedBox(height: 10),
            _SettingsCard(items: [
              _SettingsItem(
                icon: Icons.sync_rounded,
                label: 'Sincronização automática',
                color: AppColors.primaryStatusPos,
                isComingSoon: true,
              ),
              _SettingsItem(
                icon: Icons.cloud_sync_rounded,
                label: 'Configurar sincronizacao',
                color: const Color(0xFF34D399),
                isComingSoon: true,
              ),
              _SettingsItem(
                icon: Icons.download_rounded,
                label: 'Exportar dados',
                color: const Color(0xFFFBBF24),
                isComingSoon: true,
              ),
            ]),

            const SizedBox(height: 20),

            _SectionLabel('SISTEMA'),
            const SizedBox(height: 10),
            _SettingsCard(items: [
              _SettingsItem(
                icon: Icons.info_outline_rounded,
                label: 'Versão do app',
                color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                isComingSoon: false,
                subtitle: 'v1.0.0',
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.45),
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 0,
                  color: theme.dividerColor.withOpacity(0.10),
                ),
              items[i],
            ],
          );
        }),
      ),
    );
  }
}

// ── Settings Item ─────────────────────────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final bool isComingSoon;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isComingSoon,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (isComingSoon)
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
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.35),
            ),
        ],
      ),
    );
  }
}
