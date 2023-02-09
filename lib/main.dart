import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './screens/pokedex_list_screen.dart';
import './screens/detail.screen.dart';
import './screens/title_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PokedexList(url: 'https://pokeapi.co/api/v2/pokemon/'),
      // home: const TitleScreen(),
      routes: {
        DetailScreen.routeName: (context) => const DetailScreen(),
      },
    );
  }
}
