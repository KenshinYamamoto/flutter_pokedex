import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pokedex/providers/pokemon_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import './detail.screen.dart';

// riverpodを使いたいけどinitStateを使いたいからCousumerStatefulWidgetを使用
class PokedexList extends ConsumerStatefulWidget {
  final String url;
  const PokedexList({super.key, required this.url});

  @override
  _PokedexListState createState() => _PokedexListState();
}

class _PokedexListState extends ConsumerState<PokedexList> {
  final Dio dio = Dio();

  // ポケモン個別のURLをフェッチする
  Future<void> fetchUrls(String url) async {
    final Response<dynamic> response = await dio.get(url);
    ref.read(previousUrlProvider.notifier).state = response.data['previous'];
    ref.read(nextUrlProvider.notifier).state = response.data['next'];
    final newUrls = [];
    final nextUrl = ref.watch(nextUrlProvider);
    if (nextUrl != null) {
      final splitPage = ref.read(nextUrlProvider.notifier).state!.split('&');
      final splitPage2 = splitPage[0].split('=');
      ref.read(currentPageProvider.notifier).state =
          (int.parse(splitPage2.last) / 20).floor() - 1;
    }

    /* 初期する処理 */
    ref.read(urlsProvider.notifier).state = [];
    ref.read(individualDatasProvider.notifier).state = [];
    ref.read(loadingProvider.notifier).state = true;
    ref.read(speciesDatasProvider.notifier).state = [];
    /* ---------- */

    for (int i = 0; i < response.data['results'].length; i++) {
      newUrls.add(response.data['results'][i]['url']);
    }
    ref.read(urlsProvider.notifier).state = [...newUrls];
    fetchIndividualDatas(newUrls);
  }

  // 色々フェッチする
  Future<void> fetchIndividualDatas(List<dynamic> newUrls) async {
    final indivisualDatas = [];
    final speciesDatas = [];

    for (int i = 0; i < newUrls.length; i++) {
      final fetchIndividualFiles = await dio.get(newUrls[i]);
      indivisualDatas.add(fetchIndividualFiles.data);
      final speciesData = await dio.get(
        fetchIndividualFiles.data['species']['url'],
      );
      speciesDatas.add(speciesData.data);
    }
    ref.read(loadingProvider.notifier).state = false;
    ref.read(individualDatasProvider.notifier).state = [...indivisualDatas];
    ref.read(speciesDatasProvider.notifier).state = [...speciesDatas];
    setState(() {});
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

    // 現在いるページ番号
    int currentPage = ref.watch(currentPageProvider);
    // loading判定
    bool isLoading = ref.watch(loadingProvider);
    // 前のページ
    String? previousUrl = ref.watch(previousUrlProvider);
    // 後のページ
    String? nextUrl = ref.watch(nextUrlProvider);
    // ポケモン個別のデータ
    List indivisualDatas = ref.watch(individualDatasProvider);
    // ポケモン個別のspeciesData
    List speciesDatas = ref.watch(speciesDatasProvider);
    // ポケモン個別のURLを入れる
    List urls = ref.watch(urlsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
        actions: [
          Text(
            currentPage.toString(),
          ),
        ],
      ),
      backgroundColor: Colors.pink[100],
      body: Center(
        child: isLoading
            ? LoadingAnimationWidget.discreteCircle(
                color: Colors.white,
                secondRingColor: Colors.green,
                thirdRingColor: Colors.orange,
                size: deviceWidth * 0.3,
              )
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
                                  'sprite': indivisualDatas[index]['sprites']
                                          ['other']['official-artwork']
                                      ['front_default'],
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
                                  indivisualDatas[index]['sprites']['other']
                                                  ['official-artwork']
                                              ['front_default'] !=
                                          null
                                      ? Image.network(
                                          indivisualDatas[index]['sprites']
                                                  ['other']['official-artwork']
                                              ['front_default'],
                                          height: deviceHeight * 0.1,
                                          width: deviceWidth * 0.2,
                                          // scale: 1,
                                        )
                                      : Container(
                                          height: deviceHeight * 0.1,
                                          width: deviceWidth * 0.2,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                'assets/images/not_found.png',
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                  Text(
                                    speciesDatas[index]['names'][0]['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = currentPage;
                              i < currentPage + 10;
                              i++) ...{
                            if (i < 64)
                              TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(50, 50),
                                ),
                                onPressed: i == currentPage
                                    ? null
                                    : () {
                                        fetchUrls(
                                          'https://pokeapi.co/api/v2/pokemon/?offset=${(i) * 20}&limit=20',
                                        );
                                      },
                                child: FittedBox(
                                  child: Text(
                                    (i + 1).toString(),
                                    style: const TextStyle(
                                      fontSize: 36,
                                    ),
                                  ),
                                ),
                              ),
                          }
                        ],
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          previousUrl == null
                              ? SizedBox(
                                  height: deviceHeight * 0.1,
                                  width: deviceWidth * 0.45,
                                )
                              : Row(
                                  children: [
                                    SizedBox(
                                      height: deviceHeight * 0.1,
                                      width: deviceWidth * 0.45,
                                      child: Card(
                                        elevation: 5,
                                        child: InkWell(
                                          onTap: () => fetchUrls(
                                            'https://pokeapi.co/api/v2/pokemon/?offset=0&limit=20',
                                          ),
                                          child: FittedBox(
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Row(
                                                children: const [
                                                  Icon(
                                                    Icons.arrow_back,
                                                  ),
                                                  Text('先頭へ'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: deviceHeight * 0.1,
                                      width: deviceWidth * 0.45,
                                      child: Card(
                                        elevation: 5,
                                        child: InkWell(
                                          onTap: () => fetchUrls(previousUrl),
                                          child: FittedBox(
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Row(
                                                children: const [
                                                  Icon(
                                                    Icons.arrow_back,
                                                  ),
                                                  Text('前へ'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          nextUrl == null
                              ? SizedBox(
                                  height: deviceHeight * 0.1,
                                  width: deviceWidth * 0.45,
                                )
                              : Row(
                                  children: [
                                    SizedBox(
                                      height: deviceHeight * 0.1,
                                      width: deviceWidth * 0.45,
                                      child: Card(
                                        elevation: 5,
                                        child: InkWell(
                                          onTap: () => fetchUrls(nextUrl),
                                          child: FittedBox(
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Row(
                                                children: const [
                                                  Text('次へ'),
                                                  Icon(Icons.arrow_forward)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: deviceHeight * 0.1,
                                      width: deviceWidth * 0.45,
                                      child: Card(
                                        elevation: 5,
                                        child: InkWell(
                                          // onTap: () => fetchUrls(nextUrl!),
                                          onTap: () => fetchUrls(
                                            'https://pokeapi.co/api/v2/pokemon/?offset=1260&limit=20',
                                          ),
                                          child: FittedBox(
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Row(
                                                children: const [
                                                  Text('最後へ'),
                                                  Icon(Icons.arrow_forward)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
