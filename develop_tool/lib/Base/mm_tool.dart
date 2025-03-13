import 'dart:math';
import 'package:flutter/material.dart';

class MMTool {

  static Color getRandomColor() {
    return Color.fromARGB(
      255, // Alpha 通常固定为 255，确保颜色不透明
      Random().nextInt(256), // Red (0-255)
      Random().nextInt(256), // Green (0-255)
      Random().nextInt(256), // Blue (0-255)
    );
  }
}
