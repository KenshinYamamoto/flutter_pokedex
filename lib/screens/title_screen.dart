import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../providers/pokemon_provider.dart';

class TitleScreen extends ConsumerWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Dio dio = Dio();

    Future<void> fetchUrls(String url) async {
      List<String> urls = [];
      final Response<dynamic> response = await dio.get(url);
      ref.read(previousUrlProvider.notifier).state = response.data['previous'];
      ref.read(nextUrlProvider.notifier).state = response.data['next'];
      // setState(() {
      //   urls.clear();
      //   indivisualDatas.clear();
      //   speciesDatas.clear();
      // });
      for (int i = 0; i < response.data['results'].length; i++) {
        urls.add(response.data['results'][i]['url']);
      }
      ref.read(urlsProvider.notifier).state = [...urls];
    }

    fetchUrls('https://pokeapi.co/api/v2/pokemon/');
    print(ref.watch(urlsProvider.notifier).state);
    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
