import 'package:appaula06prep/model/dish.dart';
import 'package:appaula06prep/model/restaurant.dart';
import 'package:appaula06prep/ui/_core/widgets/app_colors.dart';
import 'package:appaula06prep/ui/_core/widgets/appbar.dart';
import 'package:appaula06prep/ui/_core/widgets/bag_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Restaurantscreen extends StatelessWidget {
  final Restaurant restaurant;
  const Restaurantscreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context: context, title: restaurant.name),
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Deixa os filhos centralizados verticalmente
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/${restaurant.imagePath}', width: 128),
            const SizedBox(height: 12), // espaçamento
            Text(
              'Mais pedidos',
              style: TextStyle(
                color: AppColors.mainColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(restaurant.dishes.length, (index) {
                Dish dish = restaurant.dishes[index];
                return ListTile(
                  leading: Image.asset(
                    'assets/dishes/default.png',
                    width: 48,
                    height: 48,
                  ),
                  title: Text(dish.name),
                  subtitle: Text('R\$${dish.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    onPressed: () {
                      context.read<BagProvider>().addAllDishes([dish]);
                    },
                    icon: Icon(Icons.add),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
