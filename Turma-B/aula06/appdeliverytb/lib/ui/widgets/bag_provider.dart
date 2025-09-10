import 'package:appdeliverytb/model/dish.dart';
import 'package:flutter/material.dart';

class BagProvider  extends ChangeNotifier{
  List<Dish>dishesOnBag=[]; // cria uma lista vazia

// metodo para adicionar itens ao carrinho
  addAllDishes(List<Dish>dishes){
    dishesOnBag.addAll(dishes);
    notifyListeners();
  }

  removeDish(Dish dish){
    dishesOnBag.remove(dish);
    notifyListeners();
  }

  @override
  String toString(){
    return 'BagProvider(dishesOnBag: $dishesOnBag)';
  }

  clearBag(){
    dishesOnBag.clear();
    notifyListeners();
  }

  Map<Dish,int> getMapByAmount(){
    Map<Dish,int>mapResult ={};
    for(Dish dish in dishesOnBag){
      if(mapResult[dish]==null){
        mapResult[dish]=1;
      }else{
        mapResult[dish]=mapResult[dish]!+1;
      }
    }
    return mapResult;
  }

}