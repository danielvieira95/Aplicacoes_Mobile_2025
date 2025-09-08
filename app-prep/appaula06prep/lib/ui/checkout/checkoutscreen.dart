import 'package:appaula06prep/model/dish.dart';
import 'package:appaula06prep/ui/_core/widgets/app_colors.dart';
import 'package:appaula06prep/ui/_core/widgets/bag_provider.dart';
import 'package:flutter/material.dart';


import 'package:provider/provider.dart';

class Checkoutscreen extends StatelessWidget {
  const Checkoutscreen({super.key});

  @override
  Widget build(BuildContext context) {
    BagProvider bagProvider = Provider.of<BagProvider>(context);

    // calcula o valor total
    double total = 0;
    bagProvider.getMapByAmount().forEach((dish, amount) {
      total += dish.price * amount;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacola'),
        actions: [
          TextButton(
            onPressed: () {
              bagProvider.clearBag();
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Pedidos', textAlign: TextAlign.center),
              Column(
                children: List.generate(
                  bagProvider.getMapByAmount().keys.length,
                  (index) {
                    Dish dish =
                        bagProvider.getMapByAmount().keys.toList()[index];
                    return ListTile(
                      leading: Image.asset(
                        'assets/dishes/default.png',
                        width: 48,
                        height: 48,
                      ),
                      title: Text(dish.name),
                      subtitle: Text('R\$${dish.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              bagProvider.removeDish(dish);
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text(bagProvider.getMapByAmount()[dish].toString()),
                          IconButton(
                            onPressed: () {
                              bagProvider.addAllDishes([dish]);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pagamento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    color: AppColors.fundoCards,
                  ),
                  Container(
                    width: 80,
                    height: 50,
                    color: AppColors.fundoCards,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/others/visa.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 100,
                    child: Text(
                      'Visa',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // total da compra
              Text(
                'Total: R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: 12),
              // botão pedir
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // aqui você define a ação do pedido
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pedido realizado!")),
                  );
                },
                child: const Text(
                  'Pedir',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
