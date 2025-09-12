// importa as bibliotecas

import 'package:appaula06deliveryta/model/dish.dart';
import 'package:appaula06deliveryta/model/restaurant.dart';
import 'package:appaula06deliveryta/ui/_core/app_colors.dart';
import 'package:appaula06deliveryta/ui/widgets/bag_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Restaurantscreen extends StatelessWidget {
  final Restaurant restaurant;  // cria variavel restaurant a partir do modelo
  const Restaurantscreen({super.key,required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App restaurant"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/${restaurant.imagePath}',width: 128,),
            SizedBox(height: 12,),
            Text('Mais pedidos',style: TextStyle(color: AppColors.mainColor, fontSize: 18,fontWeight: FontWeight.bold),),

            Column(
              children: List.generate(restaurant.dishes.length,(index){
                Dish dish = restaurant.dishes[index];
                return ListTile(
                leading:  Image.asset('assets/dishes/default.png',
                width: 48,height: 48,),
                title: Text(dish.name),
                subtitle: Text('R\$${dish.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  onPressed: (){
                    context.read()<BagProvider>().addAllDishes([dish]);
                  }, icon: Icon(Icons.add)),

                );

              })
            )
          ],
          
        ),

        
      ),
    );
  }
}