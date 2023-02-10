import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final StateProvider<bool> loadingProvider = StateProvider(
  (ref) => true,
);

final StateProvider<int> currentPageProvider = StateProvider(
  (ref) => 0,
);

final StateProvider<List<String>> urlsProvider = StateProvider(
  (ref) => [],
);

final StateProvider<List<dynamic>> individualDatasProvider = StateProvider(
  (ref) => [],
);

final StateProvider<List<dynamic>> speciesDatasProvider = StateProvider(
  (ref) => [],
);

final StateProvider<String?> previousUrlProvider = StateProvider(
  (ref) => '',
);

final StateProvider<String?> nextUrlProvider = StateProvider(
  (ref) => '',
);