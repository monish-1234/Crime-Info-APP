import 'package:flutter/material.dart';
import 'pages/index.dart';
import 'themes/color.dart';

// Entry point to start the app
void main() => runApp(MyApp());

// This widget provides Material Theme for app.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: primary),
      home: IndexPage(),
    );
  }
}
