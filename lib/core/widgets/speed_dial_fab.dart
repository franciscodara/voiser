import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:finwise/core/constants/app_colors.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

/// FAB expandido com opções de entrada manual e por voz.
/// Gerencia o próprio estado de aberto/fechado.
class SpeedDialFab extends StatefulWidget {
  const SpeedDialFab({super.key});

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 0.375).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  void _close() {
    if (_open) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Opções (aparecem quando aberto) ─────────────────────────
        if (_open) ...[
          _SpeedDialItem(
            icon: Icons.mic_rounded,
            label: 'Entrada por voz',
            color: AppColors.catBar,
            onTap: () {
              _close();
              context.push('/voice-entry');
            },
          ).animate().fadeIn(duration: 180.ms).slideY(begin: 0.3),

          const SizedBox(height: 10),

          _SpeedDialItem(
            icon: Icons.edit_note_rounded,
            label: 'Nova despesa manual',
            color: AppColors.primaryStatusPos,
            onTap: () {
              _close();
              context.push('/add-expense');
            },
          ).animate().fadeIn(delay: 40.ms, duration: 180.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),
        ],

        // ── Botão principal ─────────────────────────────────────────
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.primaryStatusPos,
          foregroundColor: Colors.white,
          elevation: _open ? 6 : 4,
          child: RotationTransition(
            turns: _rotateAnim,
            child: const Icon(Icons.add_rounded, size: 30),
          ),
        ),
      ],
    );
  }
}

// ── Item do SpeedDial ─────────────────────────────────────────────────────────

class _SpeedDialItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SpeedDialItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Mini FAB
          Material(
            color: color,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 46,
                height: 46,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
