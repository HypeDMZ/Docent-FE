import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:docent/src/kakao_webview_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onLoginButtonPressed,
              child: Text('Login'),
            ),
            _buildKakaoLoginButton(),
          ],
        ),
      ),
    );
  }
  Widget _buildKakaoLoginButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        icon: Image.network(
          'https://developers.kakao.com/assets/img/about/logos/kakaolink/kakaolink_btn_medium.png',
          height: 20,
        ),
        label: Text('카카오 로그인'),
        onPressed: _onKakaoLoginButtonPressed,
        style: ElevatedButton.styleFrom(
          primary: Color(0xFFFFE812),
          onPrimary: Colors.black,
          elevation: 1,
        ),
      ),
    );
  }
  Future<void> _onKakaoLoginButtonPressed() async {
    try {
      final response = await http.post(Uri.parse('https://bmongsmong.com/api/auth/kakao'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success']) {
          final String url = jsonResponse['data']['url'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KakaoWebViewPage(url: url),
            ),
          );
        } else {
          // 실패한 경우 에러 처리
          print(jsonResponse['message']);
        }
      } else {
        // 서버 에러 처리
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }




  void _onLoginButtonPressed() {
    // 로그인 처리 로직을 여기에 구현합니다.
    // 예시: 서버에 인증 요청을 보내고 결과에 따라 다음 페이지로 이동하거나 에러 메시지를 표시합니다.
    print('Username: ${_usernameController.text}');
    print('Password: ${_passwordController.text}');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
