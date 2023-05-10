import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:docent/src/login_page.dart';

class App extends StatelessWidget {
  final bool isDarkMode = false; // 다크 모드: true, 라이트 모드: false

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docent',
      theme: ThemeData(
        fontFamily: 'NanumGothic',
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'NanumGothic',
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // 여기에서 모드를 변경합니다.
      builder: (BuildContext context, Widget? child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
          ),
          child: Material(child: child),
        );
      },
      home: LoginPage(),
    );
  }
}