import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.iconKey,
    required this.colorValue,
    this.size = 44,
  });

  final String iconKey;
  final int colorValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(size * 0.34),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.2)),
      ),
      alignment: Alignment.center,
      child: Icon(
        AppIcons.forKey(iconKey),
        size: size * 0.48,
        color: isDark ? Color.lerp(color, Colors.white, 0.35) : color,
      ),
    );
  }
}

class TypeBadge extends StatelessWidget {
  const TypeBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class SpacePill extends StatelessWidget {
  const SpacePill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class IncomeExpenseColor {
  static Color income(BuildContext context) =>
      AppColors.incomeFor(Theme.of(context).brightness);

  static Color expense(BuildContext context) =>
      AppColors.expenseFor(Theme.of(context).brightness);

  static Color transfer(BuildContext context) =>
      AppColors.transferFor(Theme.of(context).brightness);
}
