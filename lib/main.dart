import 'package:flutter/material.dart';
import 'face_detection_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FaceDetectionScreen(),
    );
  }
}
