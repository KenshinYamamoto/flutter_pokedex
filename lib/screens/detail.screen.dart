import 'package:flutter/material.dart';

import '../functions/select_color.dart';

class DetailScreen extends StatelessWidget {
  static const routeName = '/detail';
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String? sprite = args['sprite'];
    final String name = args['name'];
    final List<String> types = args['types'];
    final String kind = args['kind'];
    final String description = args['description'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('detail'),
      ),
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: FittedBox(
            child: Column(
              children: [
                sprite == null
                    ? Container(
                        height: deviceHeight,
                        width: deviceWidth,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/not_found.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Image.network(
                        sprite,
                        scale: 0.3,
                      ),
                FittedBox(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: deviceWidth * 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < types.length; i++) ...{
                      Container(
                        decoration: BoxDecoration(
                          color: SelectColor.selectColor(types[i]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          types[i],
                          style: TextStyle(
                            fontSize: deviceWidth * 0.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (i != types.length - 1) ...{
                        Text(
                          '・',
                          style: TextStyle(
                            fontSize: deviceWidth * 0.3,
                          ),
                        ),
                      },
                    },
                    Text(
                      'タイプ',
                      style: TextStyle(
                        fontSize: deviceWidth * 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: deviceHeight * 0.1,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: deviceWidth * 0.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
