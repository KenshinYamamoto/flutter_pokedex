import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateProvider<String?> previousUrlProvider = StateProvider(
  (ref) => '',
);

final StateProvider<String?> nextUrlProvider = StateProvider(
  (ref) => '',
);

final StateProvider<List<String>> urlsProvider = StateProvider(
  (ref) => [],
);
