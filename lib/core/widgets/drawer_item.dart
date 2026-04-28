import 'package:flutter/material.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final String? badge;
  final bool showDivider;
  final bool isDestructive;
  /// Quando true, exibe o item com fundo highlight (item ativo).
  final bool isActive;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.badge,
    this.showDivider = false,
    this.isDestructive = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = isDestructive
        ? AppColors.primaryStatusNeg
        : (iconColor ?? theme.colorScheme.primary);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Material(
            color: isActive
                ? effectiveColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              splashColor: effectiveColor.withValues(alpha: 0.12),
              highlightColor: effectiveColor.withValues(alpha: 0.08),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    // ── Ícone com fundo colorido ──────────────────────
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: effectiveColor.withValues(
                            alpha: isActive ? 0.18 : 0.10),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(icon, color: effectiveColor, size: 20),
                    ),

                    const SizedBox(width: 14),

                    // ── Label ─────────────────────────────────────────
                    Expanded(
                      child: Text(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isActive
                              ? effectiveColor
                              : isDestructive
                                  ? AppColors.primaryStatusNeg
                                  : theme.textTheme.bodyLarge?.color,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),

                    // ── Badge (ex: "Em breve") ─────────────────────────
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: effectiveColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: AppTextStyles.label.copyWith(
                            color: effectiveColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else if (!isDestructive) ...[
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isActive
                            ? effectiveColor.withValues(alpha: 0.6)
                            : theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.4),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: theme.dividerColor.withValues(alpha: 0.12),
          ),
      ],
    );
  }
}

