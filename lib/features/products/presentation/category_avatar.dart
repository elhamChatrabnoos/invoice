import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/product.dart';

extension ProductCategoryIcon on ProductCategory {
  IconData get icon => switch (this) {
    ProductCategory.dairy => Icons.icecream_rounded,
    ProductCategory.snack => Icons.cookie_rounded,
    ProductCategory.beverage => Icons.local_drink_rounded,
    ProductCategory.grocery => Icons.bakery_dining_rounded,
    ProductCategory.produce => Icons.eco_rounded,
    ProductCategory.hygiene => Icons.spa_rounded,
    ProductCategory.baby => Icons.child_friendly_rounded,
    ProductCategory.breakfast => Icons.free_breakfast_rounded,
    ProductCategory.condiment => Icons.grain_rounded,
    ProductCategory.canned => Icons.soup_kitchen_rounded,
    ProductCategory.protein => Icons.egg_rounded,
    ProductCategory.nutsAndSweets => Icons.cake_rounded,
    ProductCategory.cleaning => Icons.cleaning_services_rounded,
    ProductCategory.general => Icons.inventory_2_rounded,
  };
}

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.size = 48});

  final ProductCategory category;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * .32),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          AppColors.primary.withValues(alpha: .14),
          AppColors.teal.withValues(alpha: .18),
        ],
      ),
    ),
    child: Icon(category.icon, color: AppColors.primary, size: size * .5),
  );
}
