import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed, // 아이템이 4개 이상일 경우 필요합니다.
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: 'Dream'),
        BottomNavigationBarItem(icon: Icon(Icons.whatshot), label: 'Hot'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'MyPage'),
      ],
    );
  }
}