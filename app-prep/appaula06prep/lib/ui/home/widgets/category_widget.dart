import 'package:flutter/material.dart';
import 'package:appaula06prep/ui/_core/widgets/app_colors.dart'; // ajuste o import se necessário

class CategoryWidget extends StatelessWidget {
  final String category;
  final VoidCallback? onTap;

  const CategoryWidget({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      child: Ink(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.lightBackgroundColor,
          borderRadius: radius,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/categories/${category.toLowerCase()}.png',
                height: 48,
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
