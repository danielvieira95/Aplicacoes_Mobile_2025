import 'package:appdeliverytb/model/dish.dart';
import 'package:appdeliverytb/ui/widgets/bag_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Checkoutscreen extends StatelessWidget {
  const Checkoutscreen({super.key});

  @override
  Widget build(BuildContext context) {
    BagProvider bagProvider = Provider.of<BagProvider>(context);

    // calcula o valor total
    double total =0;
    bagProvider.getMapByAmount().forEach((dish,amount){
      total +=dish.price*amount;

    });
    return Scaffold(
    appBar: AppBar(
      title: Text('Sacola'),
      actions: [
        TextButton(
          onPressed: (){
            bagProvider.clearBag();
          }, child: Text('Limpar'))
      ],
      
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pedidos',textAlign: TextAlign.center,),
          Column(
            children: 
              List.generate(
                bagProvider.getMapByAmount().keys.length,(index){
                  Dish dish = bagProvider.getMapByAmount().keys.toList()[index];
                  return ListTile(
                    leading: Image.asset('assets/dishes/default.png',
                    width: 48,height: 48,),
                    title: Text(dish.name),
                    subtitle: Text('R\$${dish.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: (){
                          bagProvider.removeDish(dish);
                        }, icon: Icon(Icons.remove)),
                        Text(bagProvider.getMapByAmount()[dish].toString()),
                        IconButton(onPressed: (){
                          bagProvider.addAllDishes([dish]);
                        }, icon: Icon(Icons.add))
                      ],
                    ),
                  );

                })
            ,
          ),
          SizedBox(height: 16,),
          Text('Pagamento',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)

        ],
        
      ),
    ),
    );
  }
}