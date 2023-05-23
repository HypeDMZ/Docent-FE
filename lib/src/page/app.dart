import 'package:docent/src/page/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:docent/src/page/login_page.dart';
import 'package:docent/src/page/main_page.dart';
import 'package:docent/src/page/hot_page.dart';
import 'package:docent/src/widgets/bottom_navigation_bar.dart';

import 'create_page.dart';
import 'my_page.dart';

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
          child: Material(child: child ?? const SizedBox.shrink()),
        );
      },
      routes: {
        '/': (context) => LoginPage(),
        '/main': (context) => MainScreen(),
        '/create': (context) => CreatePage(),
      },
      initialRoute: '/',
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  MainScreen({this.initialIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  List<Widget> _screens = [
    MainPage(),
    SearchPage(),
    CreatePage(),
    MyPage(), // HotPage(),
    MyPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}