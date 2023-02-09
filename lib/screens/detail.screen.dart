import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  static const routeName = '/detail';
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    // print(args);
    final String sprite = args['sprite'];
    final String name = args['name'];
    final List<String> types = args['types'];
    print(sprite);

    return Scaffold(
      appBar: AppBar(
        title: const Text('detail'),
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: FittedBox(
            child: Column(
              children: [
                Image.network(
                  sprite,
                  scale: 0.3,
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    for (int i = 0; i < types.length; i++) ...{
                      Text(
                        types[i],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (i != types.length - 1) ...{
                        const Text('・'),
                      },
                    },
                    const Text('タイプ'),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
