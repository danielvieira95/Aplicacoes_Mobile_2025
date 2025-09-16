
import 'package:appaula06prep/data/restaurant_data.dart';
import 'package:appaula06prep/model/dish.dart';
import 'package:appaula06prep/model/restaurant.dart';
import 'package:appaula06prep/ui/_core/widgets/appbar.dart';
import 'package:appaula06prep/ui/_core/widgets/bag_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeveragesScreen extends StatefulWidget {
  const BeveragesScreen({super.key});

  @override
  State<BeveragesScreen> createState() => _BeveragesScreenState();
}

class _BeveragesScreenState extends State<BeveragesScreen> {
  late Future<List<Restaurant>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<RestaurantData>().getRestaurant();
  }

  // Palavras-chave simples para identificar bebidas pelo nome
  static const _bevKeywords = [
    'suco',
    'detox',
    'refri',
    'refrigerante',
    'chá',
    'cafe',
    'café',
    'água',
    'agua',
    'soda',
    'shake',
    'vitamina'
  ];

  bool _isBeverage(Dish d) {
    final s = d.name.toLowerCase();
    return _bevKeywords.any((k) => s.contains(k));
  }

  // Se nada bater com keywords, a gente cai num fallback:
  // pega pratos dos restaurantes que possuem a categoria "Bebidas"
  List<Dish> _fallbackFromRestaurants(List<Restaurant> rs) {
    final all = <Dish>[];
    for (final r in rs) {
      if (r.categories.any((c) => c.toLowerCase() == 'bebidas')) {
        all.addAll(r.dishes);
      }
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context: context, title: 'Bebidas'),
      body: FutureBuilder<List<Restaurant>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro ao carregar: ${snap.error}'));
          }
          final restaurants = snap.data ?? const <Restaurant>[];

          // Achata todos os pratos e filtra por bebidas
          final beverages = <Dish>[];
          for (final r in restaurants) {
            for (final d in r.dishes) {
              if (_isBeverage(d)) beverages.add(d);
            }
          }

          final list = beverages.isNotEmpty
              ? beverages
              : _fallbackFromRestaurants(restaurants); // fallback

          if (list.isEmpty) {
            return const Center(child: Text('Nenhuma bebida encontrada'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final dish = list[i];
              return ListTile(
                leading: Image.asset(
                  'assets/categories/bebidas.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
                title: Text(dish.name),
                subtitle:
                    Text('R\$ ${dish.price.toDouble().toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.read<BagProvider>().addAllDishes([dish]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${dish.name} adicionado à sacola')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
