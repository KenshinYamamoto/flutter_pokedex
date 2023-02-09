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
  // ポケモン個別のURLを入れる
  List urls = [];
  // ポケモン個別のデータ
  List indivisualDatas = [];
  // ポケモン個別のspeciesData
  List speciesDatas = [];
  // 前のページ
  String? previousUrl = '';
  // 後のページ
  String? nextUrl = '';

  bool isLoading = true;

  // ポケモン個別のURLをフェッチする
  Future<void> fetchUrls(String url) async {
    final Response<dynamic> response = await dio.get(url);
    previousUrl = response.data['previous'];
    nextUrl = response.data['next'];
    setState(() {
      urls.clear();
      indivisualDatas.clear();
      speciesDatas.clear();
      isLoading = true;
    });
    for (int i = 0; i < response.data['results'].length; i++) {
      urls.add(response.data['results'][i]['url']);
    }
    fetchIndividualDatas();
  }

  // 色々フェッチする
  Future<void> fetchIndividualDatas() async {
    for (int i = 0; i < urls.length; i++) {
      final fetchIndividualFiles = await dio.get(urls[i]);
      indivisualDatas.add(fetchIndividualFiles.data);
      final speciesData = await dio.get(
        fetchIndividualFiles.data['species']['url'],
      );
      speciesDatas.add(speciesData.data);
    }
    isLoading = false;
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
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1 / 1,
                      ),
                      itemCount: urls.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          child: InkWell(
                            onTap: () async {
                              final List<String> types = [];
                              String description = '';

                              // 日本語の説明文を探す
                              for (int i = 0;
                                  i <
                                      speciesDatas[index]['flavor_text_entries']
                                          .length;
                                  i++) {
                                if (speciesDatas[index]['flavor_text_entries']
                                        [i]['language']['name'] ==
                                    'ja') {
                                  description = speciesDatas[index]
                                      ['flavor_text_entries'][i]['flavor_text'];
                                }
                              }

                              // 日本語のタイプを探す
                              for (int i = 0;
                                  i < indivisualDatas[index]['types'].length;
                                  i++) {
                                final typeDatas = await dio.get(
                                  indivisualDatas[index]['types'][i]['type']
                                      ['url'],
                                );
                                for (int j = 0;
                                    j < typeDatas.data['names'].length;
                                    j++) {
                                  if (typeDatas.data['names'][j]['language']
                                          ['name'] ==
                                      'ja') {
                                    final type =
                                        typeDatas.data['names'][j]['name'];
                                    types.add(type);
                                  }
                                }
                              }
                              if (!mounted) return;
                              Navigator.of(context).pushNamed(
                                DetailScreen.routeName,
                                arguments: <String, dynamic>{
                                  // イラスト
                                  'sprite':
                                      'https://img.pokemondb.net/artwork/${indivisualDatas[index]['name']}.jpg',
                                  // 名前
                                  'name': speciesDatas[index]['names'][0]
                                      ['name'],
                                  // タイプ
                                  'types': types,
                                  // 何ポケモン
                                  'kind': speciesDatas[index]['genera'][0]
                                      ['genus'],
                                  // 説明文
                                  'description': description,
                                },
                              );
                            },
                            child: FittedBox(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.network(
                                    // indivisualDatas[index]['sprites']
                                    //     ['front_default'],
                                    'https://img.pokemondb.net/artwork/${indivisualDatas[index]['name']}.jpg',
                                    height: deviceHeight * 0.1,
                                    width: deviceWidth * 0.2,
                                    // scale: 1,
                                  ),
                                  Text(
                                    speciesDatas[index]['names'][0]['name'],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
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
      ),
    );
  }
}
