import 'package:flutter/material.dart';

class SelectColor {
  static Color selectColor(String type) {
    switch (type) {
      case 'ノーマル':
        return Colors.grey;
      case 'ほのお':
        return Colors.red;
      case 'みず':
        return Colors.blue;
      case 'でんき':
        return Colors.yellow;
      case 'くさ':
        return Colors.green;
      case 'こおり':
        return Colors.cyan;
      case 'かくとう':
        return Colors.orange;
      case 'どく':
        return Colors.purple;
      case 'じめん':
        return Colors.brown;
      case 'ひこう':
        return Colors.lightBlue[200]!;
      case 'エスパー':
        return Colors.pinkAccent;
      case 'むし':
        return Colors.lime;
      case 'いわ':
        return Colors.brown[200]!;
      case 'ゴースト':
        return Colors.deepPurple;
      case 'ドラゴン':
        return Colors.blue[800]!;
      case 'あく':
        return Colors.black54;
      case 'はがね':
        return Colors.blueGrey;
      case 'フェアリー':
        return Colors.pink[200]!;
    }
    return Colors.black;
  }
}
