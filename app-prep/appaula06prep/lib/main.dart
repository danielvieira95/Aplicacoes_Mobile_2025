import 'package:appaula06prep/data/restaurant_data.dart';
import 'package:appaula06prep/ui/_core/widgets/app_theme.dart';
import 'package:appaula06prep/ui/_core/widgets/bag_provider.dart';
import 'package:appaula06prep/ui/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RestaurantData restaurantsData = RestaurantData();
  await restaurantsData.getRestaurant();
  //List<Restaurant> listRestaurant = await RestaurantsData().getRestaurant();
  //print(listRestaurant);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return restaurantsData;
          },
        ),
        ChangeNotifierProvider(create: (context) => BagProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// Cria um novo widget

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
