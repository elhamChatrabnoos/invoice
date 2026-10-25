import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: .14),
                    AppColors.teal.withValues(alpha: .14),
                  ],
                ),
              ),
              child: Icon(icon, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.8),
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// − qty + control.
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.compact = false,
  });

  final int value;
  final int min;
  final bool compact;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 44.0;
    Widget button(IconData icon, VoidCallback? onTap, {bool filled = false}) =>
        Material(
          color: filled ? AppColors.primary : const Color(0xFFEDEBFA),
          borderRadius: BorderRadius.circular(size * .35),
          child: InkWell(
            borderRadius: BorderRadius.circular(size * .35),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                size: size * .5,
                color: filled ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.add_rounded, () => onChanged(value + 1), filled: true),
        SizedBox(
          width: compact ? 34 : 52,
          child: Text(
            fa(value),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 15 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        button(
          value - 1 <= 0 && min == 0
              ? Icons.delete_outline_rounded
              : Icons.remove_rounded,
          value > min ? () => onChanged(value - 1) : null,
        ),
      ],
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.height = 58,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? .5 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message, {IconData? icon}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1600),
        content: Row(
          children: [
            Icon(icon ?? Icons.check_circle_rounded, color: AppColors.teal),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Large amount followed by a muted "تومان" unit.
class PriceText extends StatelessWidget {
  const PriceText(
    this.amount, {
    super.key,
    this.fontSize = 20,
    this.color = AppColors.primary,
  });

  final int amount;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: money(amount),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        TextSpan(
          text: '  تومان',
          style: TextStyle(
            fontSize: fontSize * .5,
            color: color.withValues(alpha: .7),
          ),
        ),
      ],
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message, style: const TextStyle(height: 1.8)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('انصراف'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            minimumSize: const Size(88, 44),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
