import 'package:flutter/material.dart';
import 'package:finwise/core/theme/app_text_styles.dart';

class BrandLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color? color;
  final bool showText;
  final MainAxisAlignment mainAxisAlignment;

  const BrandLogo({
    super.key,
    this.iconSize = 24,
    this.fontSize = 20,
    this.color,
    this.showText = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).textTheme.displayLarge?.color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Icon(
          Icons.account_balance_wallet_rounded,
          size: iconSize,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'Voiser',
            style: AppTextStyles.title.copyWith(
              fontSize: fontSize,
              color: themeColor,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
