import 'package:flutter/material.dart';
import 'package:docent/src/login_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docent',
      theme: ThemeData(
        fontFamily: 'NanumGothic',
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
