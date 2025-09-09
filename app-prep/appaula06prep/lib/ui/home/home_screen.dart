import 'package:appaula06prep/data/categories_data.dart';
import 'package:appaula06prep/data/restaurant_data.dart';
import 'package:appaula06prep/model/restaurant.dart';
import 'package:appaula06prep/ui/_core/widgets/app_colors.dart';
import 'package:appaula06prep/ui/_core/widgets/appbar.dart';
import 'package:appaula06prep/ui/home/widgets/category_widget.dart';
import 'package:appaula06prep/ui/home/widgets/restaurant_widget.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

//  palvra chave aula 2Widgets
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    RestaurantData restaurantData = Provider.of<RestaurantData>(context);
    return Scaffold(
      drawer: Drawer(),
      appBar: getAppBar(context: context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              spacing: 32,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/logo.png', width: 147),
                Text('Boas vindas !'),
                TextFormField(),
                Text('Escolha por categoria'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    // Lista que vai ser gerada das categories
                    spacing: 8,
                    children: List.generate(
                      CategoriesData.listCategories.length,
                      (index) {
                        return CategoryWidget(
                          category: CategoriesData.listCategories[index],
                        );
                      },
                    ),
                  ),
                ),
                Image.asset('assets/banners/banner_promo.png'),
                Text(
                  'Bem avaliados',
                  style: TextStyle(
                    color: AppColors.mainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  spacing: 16,
                  children: List.generate(
                    restaurantData.listRestaurant.length,
                    (index) {
                      Restaurant restaurant =restaurantData.listRestaurant[index];
                      return RestaurantWidget(restaurant: restaurant);
                    },
                  ),
                ),
                SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
