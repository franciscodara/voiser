import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finwise/core/constants/default_categories.dart';
import 'package:finwise/features/expenses/domain/entities/category.dart';

class CategorySelector extends StatelessWidget {
  final Category? selected;
  final ValueChanged<Category> onSelected;
  final bool isExpense;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    final categories = DefaultCategories.all.where((c) {
      if (isExpense) return c.id != 'income_salary';
      return c.id == 'income_salary';
    }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selected?.id == category.id;

        return _CategoryItem(
          category: category,
          isSelected: isSelected,
          onTap: () => onSelected(category),
          animationDelay: Duration(milliseconds: index * 40),
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withOpacity(isDark ? 0.35 : 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? category.color : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: category.color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                category.icon,
                size: 28,
                color: isSelected ? category.color : theme.colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? category.color : theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.2,
              ),
            ),
          ],
        ),
      )
          .animate(delay: animationDelay)
          .fade(duration: 250.ms)
          .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
    );
  }
}
