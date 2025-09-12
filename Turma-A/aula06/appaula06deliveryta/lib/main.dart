import 'package:appaula06deliveryta/data/restaurant_data.dart';
import 'package:appaula06deliveryta/ui/_core/app_theme.dart';
import 'package:appaula06deliveryta/ui/widgets/bag_provider.dart';
import 'package:appaula06deliveryta/ui/widgets/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // serve para carregar a tela do app sem ficar esperando o provider ou banco de dados ser carregado
  RestaurantData restaurantData = RestaurantData();
  await restaurantData.getRestaurant();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context){
          return RestaurantData();
        }),
        ChangeNotifierProvider(create: (context)=>BagProvider())
      ],
      child: MyApp(),
      ));
    
    
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      home: SplashScreen(),
    );
  }
}