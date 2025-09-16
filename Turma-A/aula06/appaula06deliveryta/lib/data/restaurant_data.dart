import 'dart:convert'; // biblioteca para converter json
import 'package:appaula06deliveryta/model/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // biblioteca para criar os widgets do flutter


// cria classe restaurant data

class RestaurantData extends ChangeNotifier{
  // Cria uma lista para carregar os restaurantes

  List<Restaurant> _listRestaurant=[];
  List<Restaurant> get listRestaurant => _listRestaurant;

  Future<List<Restaurant>> getRestaurant()async{
    if(_listRestaurant.isNotEmpty){
      return _listRestaurant; // evita recarregar se já tiver carregado uma vez
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final Map<String,dynamic> data = json.decode(jsonString);
      final List<dynamic> restaurantData= data['restaurants'];

      _listRestaurant.addAll(restaurantData.map((e)=>Restaurant.fromMap(e)).toList());
      notifyListeners();
    }catch(e){
      debugPrint('Erro ao carregar restaurants $e');
    }
    return _listRestaurant;

  }

}