import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../feature/common.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (accessToken != null && refreshToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 260),
              child: Image.asset(
                'lib/src/img/docent_logo.png',
                width: 260,
              ),
            ),
            _buildKakaoLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildKakaoLoginButton() {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          _loginWithKakao();
        },
        child: Image.asset(
          'lib/src/img/kakao_login_medium_narrow.png',
        ),
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFFFE812),
          onPrimary: Colors.black,
          elevation: 1,
          padding: EdgeInsets.all(0),
        ),
      ),
    );
  }
  void _loginWithKakao() async {
    Map<String, dynamic>? loginInfo = await _loginAndGetLoginInfo();
    if (loginInfo != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('access_token', loginInfo['access_token']);
      prefs.setString('refresh_token', loginInfo['refresh_token']);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
      );

    } else {
      print('Failed to fetch login information');
    }
  }

  Future<Map<String, dynamic>?> _loginAndGetLoginInfo() async {
    OAuthToken? token;

    if (await isKakaoTalkInstalled()) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          return null;
        }
      }
    }

    if (token == null) {
      try {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
        return null;
      }
    }

    final url = 'https://bmongsmong.com/api/auth/kakao/moblie?data=${token.accessToken}';
    final headers = {'accept': 'application/json'};
    dynamic data = await fetchDataFromApi(url, headers: headers);
    return data;
  }
}
