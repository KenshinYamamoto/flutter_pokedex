import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import './detail.screen.dart';

class PokedexList extends StatefulWidget {
  final String url;
  const PokedexList({super.key, required this.url});

  @override
  State<PokedexList> createState() => _PokedexListState();
}

class _PokedexListState extends State<PokedexList> {
  final Dio dio = Dio();
  List urls = [];
  List indivisualDatas = [];
  List speciesDatas = [];
  String? previousUrl = '';
  String? nextUrl = '';

  Future<void> fetchUrls(String url) async {
    final Response<dynamic> response = await dio.get(url);
    previousUrl = response.data['previous'];
    nextUrl = response.data['next'];
    setState(() {
      urls.clear();
      indivisualDatas.clear();
      speciesDatas.clear();
    });
    for (int i = 0; i < response.data['results'].length; i++) {
      urls.add(response.data['results'][i]['url']);
    }
    fetchIndividualDatas();
  }

  Future<void> fetchIndividualDatas() async {
    for (int i = 0; i < urls.length; i++) {
      final fetchIndividualFiles = await dio.get(urls[i]);
      indivisualDatas.add(fetchIndividualFiles.data);
      final speciesData = await dio.get(
        fetchIndividualFiles.data['species']['url'],
      );
      speciesDatas.add(speciesData.data);
    }
    setState(() {});
    print(urls);
    print(indivisualDatas);
  }

  @override
  void initState() {
    super.initState();
    fetchUrls(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
      ),
      backgroundColor: Colors.pinkAccent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1 / 1,
              ),
              itemCount: urls.length,
              itemBuilder: (context, index) {
                try {
                  return Card(
                    elevation: 5,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed(DetailScreen.routeName),
                      child: FittedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              indivisualDatas[index]['sprites']['front_default'],
                            ),
                            FittedBox(
                              child: Text(
                                speciesDatas[index]['names'][0]['name'],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } catch (e) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                previousUrl == null
                    ? SizedBox(
                        height: deviceHeight * 0.1,
                        width: deviceWidth * 0.45,
                      )
                    : SizedBox(
                        height: deviceHeight * 0.1,
                        width: deviceWidth * 0.45,
                        child: Card(
                          elevation: 5,
                          child: InkWell(
                            onTap: () => fetchUrls(previousUrl!),
                            child: const FittedBox(
                              child: Text('前'),
                            ),
                          ),
                        ),
                      ),
                nextUrl == null
                    ? SizedBox(
                        height: deviceHeight * 0.1,
                        width: deviceWidth * 0.45,
                      )
                    : SizedBox(
                        height: deviceHeight * 0.1,
                        width: deviceWidth * 0.45,
                        child: Card(
                          elevation: 5,
                          child: InkWell(
                            onTap: () => fetchUrls(nextUrl!),
                            child: const FittedBox(
                              child: Text('次'),
                            ),
                          ),
                        ),
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
