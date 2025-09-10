import 'package:appdeliverytb/data/restaurant_data.dart';
import 'package:appdeliverytb/ui/_core/app_theme.dart';
import 'package:appdeliverytb/ui/widgets/bag_provider.dart';
import 'package:appdeliverytb/ui/widgets/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  RestaurantData restaurantData = RestaurantData();
  await restaurantData.getRestaurant();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
        create:(context){
          return restaurantData;
        }),
        ChangeNotifierProvider(create: (context)=>BagProvider())
      ],
    
   child:  MyApp()));
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