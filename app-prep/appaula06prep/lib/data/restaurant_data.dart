import 'dart:convert';
import 'package:appaula06prep/model/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RestaurantData extends ChangeNotifier{
  List<Restaurant>  _listRestaurant =[];
  List<Restaurant> get listRestaurant=> _listRestaurant;

  Future<List<Restaurant>> getRestaurant() async {
    if (_listRestaurant.isNotEmpty) {
      return _listRestaurant; // Evita recarregar se já tiver carregado
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> restaurantData = data['restaurants'];

      _listRestaurant.addAll(
        restaurantData.map((e) => Restaurant.fromMap(e)).toList(),
      );

      notifyListeners(); // Notifica caso esteja usando com Provider
    } catch (e) {
      debugPrint('Erro ao carregar restaurantes: $e');
    }

    return _listRestaurant;
  }
}



